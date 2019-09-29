import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_bluetooth_serial/BluetoothConnectionAsPackets.dart';

import './ChatPacketType.dart';

class _MessageData {
  int id;
  int clientId;
  String content;
  bool seen;

  _MessageData(this.content, {this.id = 0, this.clientId = 0, this.seen = false});
}

class _ClientInformationData {
  String name;
  Color color;
}

class ChatPage extends StatefulWidget {
  final BluetoothDevice server;

  const ChatPage({this.server});

  @override
  _ChatPage createState() => new _ChatPage();
}

class _ChatPage extends State<ChatPage> {
  /* Connectivity */
  BluetoothConnectionAsPackets _connection;

  bool isConnecting = true;
  bool get isConnected => _connection != null && _connection.isConnected;

  bool isDisconnecting = false;

  /* Chat context */
  int localClientId = 0;

  Map<int, _ClientInformationData> clients = <int, _ClientInformationData>{};
  List<_MessageData> messages = <_MessageData>[];

  /* User interface */
  final TextEditingController textEditingController = new TextEditingController();
  final ScrollController listScrollController = new ScrollController();


  @override
  void initState() {
    super.initState();

    BluetoothConnection.toAddress(widget.server.address).then((connection) {
      this._connection = BluetoothConnectionAsPackets.fromConnection(connection);
      this._connection.onPacket(_onPacketReceived);
      this._connection.onDone(() async {
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
      this._connection.sendPacket(ChatPacketType.UserIdentification);
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
              child: ListView.builder(
                padding: const EdgeInsets.all(12.0),
                controller: listScrollController,
                itemCount: messages.length,
                itemBuilder: (BuildContext context, int index) {
                  final _MessageData message = messages[index];
                  return Row(
                    children: <Widget>[
                      GestureDetector(
                        onHorizontalDragEnd: (DragEndDetails details) {
                          if (details.primaryVelocity > 17.0) {
                            _removeMessage(index);
                          }
                        },
                        child: Container(
                          child: Text(message.content == '/shrug' ? '¯\\_(ツ)_/¯' : message.content, 
                            style: TextStyle(color: Colors.white)),
                          padding: EdgeInsets.all(12.0),
                          margin: EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
                          width: 222.0,
                          decoration: BoxDecoration(
                            color: clients[message.clientId]?.color ?? Colors.grey, 
                            borderRadius: BorderRadius.circular(7.0)
                          ),
                        ),
                      )
                    ],
                    mainAxisAlignment: message.clientId == localClientId ? MainAxisAlignment.end : MainAxisAlignment.start,
                  );
                },
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
                    onPressed: isConnected ? () => _pushMessage(textEditingController.text) : null
                  ),
                ),
              ]
            )
          ]
        )
      )
    );
  }

  void _onPacketReceived(int type, Iterable<int> data) {
    switch (type) {
      case ChatPacketType.Message:
        setState(() {
          // There is no `utf8.decode` working on `Iterator<int>` :C
          final List prefix = data.take(3).toList();
          final int clientId = prefix[0];
          final int messageId = prefix[1] * 0xFF + prefix[2];
          final String content = utf8.decode(data.skip(2).toList());
          messages.add(_MessageData(content, id: messageId, clientId: clientId));
        });
        break;

      case ChatPacketType.MessageSeen:
        // TODO: Multiple packet type still not implemented
        throw 'not implemented';

      case ChatPacketType.MessageRemoved:
        setState(() {
          List<int> prefix = data.take(2).toList();
          final messageId = prefix[0] * 0xFF + prefix[1];
          final int index = messages.indexWhere((message) => message.id == messageId);
          if (index != -1) {
            messages.removeAt(index); // TODO: Maybe reduce message to "Message removed" or something?
          }
        });
        break;

      case ChatPacketType.MessageRedacted:
        // TODO: Multiple packet type still not implemented
        throw 'not implemented';

      case ChatPacketType.UserJoined:
        setState(() {
          final clientId = data.first;
          if (localClientId == 0) {
            localClientId = clientId;
            return;
          }
          // TODO: Add some nice centered message about new user
        });
        break;

      case ChatPacketType.UserLeft:
      case ChatPacketType.UserKicked:
      case ChatPacketType.UserMuted:
      case ChatPacketType.UserUnmuted:
      case ChatPacketType.AskUserIdentification:
      case ChatPacketType.InvalidOperation:
      case ChatPacketType.NoPermissions:
      case ChatPacketType.FloodWarning:
        // TODO: Multiple packet type still not implemented
        throw 'not implemented';

      case ChatPacketType.MessageIdAssigned:
        if (messages.last.id != 0) {
          // TODO: warning: id was already assigned
        }
        List<int> prefix = data.take(2).toList();
        final messageId = prefix[0] * 0xFF + prefix[1];
        if (messageId == 0) {
          // TODO: warning: server rejected message
          return;
        }
        messages.last.id = messageId;
        break;

      default:
        print('Warning: Unhandled packet type: $type');
        break;
    }
  }

  void _pushMessage(String text) async {
    text = text.trim();
    textEditingController.clear();

    if (text.length > 0)  {
      try {
        await this._connection.sendPacket(ChatPacketType.PushMessage, utf8.encode(text));

        setState(() {
          messages.add(_MessageData(text, clientId: localClientId));
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

  void _removeMessage(int index) async {
    final int messageId = messages[index].id;
    await this._connection.sendPacket(ChatPacketType.RemoveMessage, Uint8List.fromList([
      messageId ~/ 0xFF,
      messageId % 0xFF
    ]));
  }
}
