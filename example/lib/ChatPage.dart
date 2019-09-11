import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_bluetooth_serial/BluetoothConnectionAsPackets.dart';

class ChatPacketType {
  static const PushMessage    = 0x01; // Also allows for edit the message

  // TODO: Implement whole example, instead of just one package type.
  // For now it is only `PushMessage` and only one client.

  static const MessageSeen    = 0x02;
  static const RemoveMessage  = 0x03;

  static const BlockUser    = 0x21;
  static const UnblockUser  = 0x22;

  static const UserInfo = 0xA1;
  static const UserInfoRequest = 0xA2;
  //...
}

class ChatPage extends StatefulWidget {
  final BluetoothDevice server;
  
  const ChatPage({this.server});
  
  @override
  _ChatPage createState() => new _ChatPage();
}

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

class _ChatPage extends State<ChatPage> {
  static final clientID = 0;

  BluetoothConnectionAsPackets _connection;

  List<_Message> messages = List<_Message>();

  final TextEditingController textEditingController = new TextEditingController();
  final ScrollController listScrollController = new ScrollController();

  bool isConnecting = true;
  bool get isConnected => _connection != null && _connection.isConnected;

  bool isDisconnecting = false;

  @override
  void initState() {
    super.initState();

    BluetoothConnection.toAddress(widget.server.address).then((connection) {
      this._connection = BluetoothConnectionAsPackets.fromConnection(connection);
      this._connection.onPacket(_onDataReceived);
      this._connection.onDone(() {
        // Example: Detect which side closed the connection
        // There should be `isDisconnecting` flag to show are we are (locally)
        // in middle of disconnecting process, should be set before calling
        // `dispose`, `finish` or `close`, which all causes to disconnect.
        // If we except the disconnection, `onDone` should be fired as result.
        // If we didn't except this (no flag set), it means closing by remote.
        if (isDisconnecting) {
          print('Disconnecting locally!');
        }
        else {
          print('Disconnected remotely!');
        }
        if (this.mounted) {
          setState(() {});
        }
      });
      print('Connected to the device');
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected) {
      isDisconnecting = true;
      _connection.dispose();
      _connection = null;
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Row> list = messages.map((_message) {
      return Row(
        children: <Widget>[
          Container(
            child: Text((text) {
              return text == '/shrug' ? '¯\\_(ツ)_/¯' : text;
            } (_message.text.trim()), style: TextStyle(color: Colors.white)),
            padding: EdgeInsets.all(12.0),
            margin: EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
            width: 222.0,
            decoration: BoxDecoration(color: _message.whom == clientID ? Colors.blueAccent : Colors.grey, borderRadius: BorderRadius.circular(7.0)),
          ),
        ],
        mainAxisAlignment: _message.whom == clientID ? MainAxisAlignment.end : MainAxisAlignment.start,
      );
    }).toList();
    
    return Scaffold(
      appBar: AppBar(
        title: (
          isConnecting ? Text('Connecting chat to ' + widget.server.name + '...') :
          isConnected ? Text('Live chat with ' + widget.server.name) :
          Text('Chat log with ' + widget.server.name)
        )
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Flexible(
              child: ListView(
                padding: const EdgeInsets.all(12.0),
                controller: listScrollController,
                children: list
              )
            ),
            Row(
              children: <Widget>[
                Flexible(
                  child: Container(
                    margin: const EdgeInsets.only(left: 16.0),
                    child: TextField(
                      style: const TextStyle(fontSize: 15.0),
                      controller: textEditingController,
                      decoration: InputDecoration.collapsed(
                        hintText: (
                          isConnecting ? 'Wait until connected...' : 
                          isConnected ? 'Type your message...' : 
                          'Chat got disconnected'
                        ),
                        hintStyle: const TextStyle(color: Colors.grey),
                      ),
                      enabled: isConnected,
                    )
                  )
                ),
                Container(
                  margin: const EdgeInsets.all(8.0),
                  child: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: isConnected ? () => _sendMessage(textEditingController.text) : null
                  ),
                ),
              ]
            )
          ]
        )
      )
    );
  }

  void _onDataReceived(int type, Iterable<int> data) {
    switch (type) {
      case ChatPacketType.PushMessage:
        setState(() {
          messages.add(_Message(1, utf8.decode(data.toList())));
        });
        break;

      default:
        print('Error: Unhandled packet type: $type');
        break;
    }
  }

  void _sendMessage(String text) async {
    text = text.trim();
    textEditingController.clear();

    if (text.length > 0)  {
      try {
        await this._connection.sendPacket(ChatPacketType.PushMessage, utf8.encode(text));

        setState(() {
          messages.add(_Message(clientID, text));
        });

        Future.delayed(Duration(milliseconds: 111)).then((_) {
          listScrollController.animateTo(listScrollController.position.maxScrollExtent, duration: Duration(milliseconds: 333), curve: Curves.easeOut);
        });
      }
      catch (e) {
        // Ignore error, but notify state
        setState(() {});
      }
    }
  }
}
