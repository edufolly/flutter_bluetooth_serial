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

  _MessageData(this.content, {this.id = 0, this.clientId = 0});
}

class _ClientInformationData {
  _ClientInformationData(int colorId) {
    switch(colorId) {
      case 0x00: color = Colors.pinkAccent;       break;
      case 0x01: color = Colors.redAccent;        break;
      case 0x02: color = Colors.deepOrangeAccent; break;
      case 0x03: color = Colors.orangeAccent;     break;
      case 0x04: color = Colors.amberAccent;      break;
      case 0x05: color = Colors.yellowAccent;     break;
      case 0x06: color = Colors.limeAccent;       break;
      case 0x07: color = Colors.lightGreenAccent; break;
      case 0x08: color = Colors.greenAccent;      break;
      case 0x09: color = Colors.tealAccent;       break;
      case 0x0A: color = Colors.cyanAccent;       break;
      case 0x0B: color = Colors.lightBlueAccent;  break;
      case 0x0C: color = Colors.blueAccent;       break;
      case 0x0D: color = Colors.indigoAccent;     break;
      case 0x0E: color = Colors.purpleAccent;     break;
      case 0x0F: color = Colors.deepPurpleAccent; break;
      case 0x10: color = Colors.brown;            break;
      default:   color = Colors.grey;
    }
  }

  Color color;
  //String name;

  bool muted = false;

  // NOTE(psychox): I was too lazy... Colors would be fine in example app :F
  String get name {
    /**/ if (color == Colors.pinkAccent)        return 'Pinky';
    else if (color == Colors.redAccent)         return 'RED';
    else if (color == Colors.deepOrangeAccent)  return 'More oranges';
    else if (color == Colors.orangeAccent)      return 'Oranges';
    else if (color == Colors.amberAccent)       return 'Amber';
    else if (color == Colors.yellowAccent)      return 'Sun yellow';
    else if (color == Colors.limeAccent)        return 'Limes';
    else if (color == Colors.lightGreenAccent)  return 'GREEN';
    else if (color == Colors.greenAccent)       return 'Grass';
    else if (color == Colors.tealAccent)        return 'Tealed';
    else if (color == Colors.cyanAccent)        return 'Cyan';
    else if (color == Colors.lightBlueAccent)   return 'Sky blue';
    else if (color == Colors.blueAccent)        return 'Sea blue';
    else if (color == Colors.indigoAccent)      return 'Indigo';
    else if (color == Colors.purpleAccent)      return 'Purple King';
    else if (color == Colors.deepPurpleAccent)  return 'Purple Queen';
    else if (color == Colors.brown)             return 'Mush-brown';
    else return 'Unknown';
  }
}

void _showDialog(context, text, {title = 'Warning'}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(text),
        actions: <Widget>[
          FlatButton(
            child: const Text("Close"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
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
  Map<int, _ClientInformationData> clients = <int, _ClientInformationData>{
    0: _ClientInformationData(-1),
  };
  int localClientId = 0;

  List<_MessageData> messages = <_MessageData>[];
  int lastSeenMessageIndex = -1;
  int lastSeenMessageIndexReported = -2;
  int lastSeenUserMessageIndex = -1;

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
      this._connection.sendPacket(ChatPacketType.UserIdentification, );
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

    textEditingController.dispose();
    listScrollController.dispose();

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
      body: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerMove: (_) {
          // On any user gesture on app, mark last message as seen.
          _notifySeen();
        },
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Flexible(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12.0),
                  controller: listScrollController,
                  itemCount: messages.length,
                  itemBuilder: (BuildContext context, int index) {
                    final _MessageData message = messages[index];
                    if (message.clientId == 0) {
                      // Server message
                      return Row(
                        children: <Widget>[
                          Container(
                            child: Text(message.content, 
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey[700], 
                                fontWeight: FontWeight.w300
                              )
                            ),
                            padding: EdgeInsets.all(12.0),
                            margin: EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
                            width: 300.0,
                          ),
                        ],
                        mainAxisAlignment: MainAxisAlignment.center,
                      );
                    } 
                    else {
                      // Users message
                      Color backgroundColor = clients[message.clientId]?.color ?? Colors.grey;
                      Color foregroundColor = backgroundColor.computeLuminance() >= 0.5 ? Colors.black : Colors.white;
                      return Column(
                        children: <Widget>[
                          GestureDetector(
                            onHorizontalDragEnd: (DragEndDetails details) {
                              if (details.primaryVelocity > 17.0) {
                                _removeMessage(index);
                              }
                            },
                            child: Container(
                              child: Text(message.content.length == 0 ? 'Message removed' : message.content, 
                                style: TextStyle(
                                  color: foregroundColor, 
                                  fontStyle: message.content.length == 0 ? FontStyle.italic : null,
                                  fontWeight: message.content.length == 0 ? FontWeight.w300 : null,
                                )
                              ),
                              padding: EdgeInsets.all(10.0),
                              margin: EdgeInsets.only(bottom: 4.0, left: 4.0, right: 4.0),
                              width: 200.0,
                              decoration: BoxDecoration(
                                color: backgroundColor, 
                                borderRadius: BorderRadius.circular(8.0)
                              ),
                            ),
                          ),
                          (
                            lastSeenUserMessageIndex == index ?
                              Container(
                                child: Text('Seen by all',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w300,
                                  ),
                                  textScaleFactor: 0.85,
                                ),
                                margin: EdgeInsets.only(right: 8.0),
                              ) : Container()
                          )
                        ],
                        crossAxisAlignment: (
                          message.clientId == localClientId ?
                            CrossAxisAlignment.end :
                            CrossAxisAlignment.start
                        )
                      );
                    }
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
                            !isConnected ? 'Chat got disconnected' : 
                            clients[localClientId].muted ? 'You are muted.' : 
                            'Type your message...'
                          ),
                          hintStyle: const TextStyle(color: Colors.grey),
                        ),
                        enabled: isConnected && !clients[localClientId].muted,
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
      )
    );
  }

  void _onPacketReceived(int type, Iterable<int> data) {
    switch (type) {
      case ChatPacketType.Message: {
          // There is no `utf8.decode` working on `Iterator<int>` :C
          final List prefix = data.take(3).toList();
          final int clientId = prefix[0];
          final int messageId = prefix[1] * 0xFF + prefix[2];
          final String content = utf8.decode(data.skip(3).toList());
          setState(() {
            messages.add(_MessageData(content, id: messageId, clientId: clientId));
          });
          break;
        }

      case ChatPacketType.MessageSeen: {
        List<int> prefix = data.take(2).toList();
        final messageId = prefix[0] * 0xFF + prefix[1];
        final int index = messages.lastIndexWhere((message) => message.id == messageId);
        if (index != -1) {
          setState(() {
            if (index > lastSeenMessageIndex) {
              lastSeenMessageIndex = index;
              if (messages[index].clientId == 0) {
                lastSeenUserMessageIndex = messages.lastIndexWhere((message) =>
                  (message.clientId != 0) &&
                  (message.id < messageId)
                );
              }
              else {
                lastSeenUserMessageIndex = index;
              }
            }
          });
        }
        break;
      }

      case ChatPacketType.MessageRemoved: {
        List<int> prefix = data.take(2).toList();
        final messageId = prefix[0] * 0xFF + prefix[1];
        final int index = messages.lastIndexWhere((message) => message.id == messageId);
        if (index != -1) {
          setState(() {
            //messages.removeAt(index);
            messages[index].content = '';
          });
        }
        break;
      }

      case ChatPacketType.MessageRedacted:
        // TODO: Multiple packet type still not implemented
        throw 'not implemented';

      case ChatPacketType.UserJoined: {
        List<int> prefix = data.take(2).toList();
        final clientId = prefix[0];
        final colorId = prefix[1];
        if (localClientId == 0) {
          localClientId = clientId;
          // Note: For now there is no `name` in `_ClientInformationData` (see this class for details)
          clients[clientId] = _ClientInformationData(colorId);
          return;
        }
        final name = clients[clientId].name;
        setState(() {
          messages.add(_MessageData('User $name joined to the server!', clientId: 0));
        });
        break;
      }

      case ChatPacketType.UserLeft: {
        final clientId = data.first;
        final name = clients[clientId].name;
        setState(() {
          messages.add(_MessageData('User $name left the server!', clientId: 0));
        });
        //clients.remove(clientId); // For now data still used to preseve messages colors.
        break;
      }

      case ChatPacketType.UserKicked: {
        final clientId = data.first;
        if (clientId == localClientId) {
          setState(() {
            messages.add(_MessageData('You were kicked from the server!', clientId: 0));
          });
          // The connection will be closed by remote server, so chat will got
          // disconnected and there will be proper message in text box.
        }
        else {
          setState(() {
            messages.add(_MessageData('User ${clients[clientId].name} was kicked from server!', clientId: 0));
          });
        }
        break;
      }

      case ChatPacketType.UserMuted: {
        final clientId = data.first;
        _ClientInformationData client = clients[clientId];
        client.muted = true;
        if (clientId == localClientId) {
          textEditingController.clear();
          setState(() {
            messages.add(_MessageData('You were muted on the server!', clientId: 0));
          });
        }
        else {
          setState(() {
            messages.add(_MessageData('User ${client.name} was muted on the server!', clientId: 0));
          });
        }
        break;
      }

      case ChatPacketType.UserUnmuted: {
        final clientId = data.first;
        _ClientInformationData client = clients[clientId];
        client.muted = false;
        if (clientId == localClientId) {
          setState(() {
            messages.add(_MessageData('You were unmuted on the server!', clientId: 0));
          });
        }
        else {
          setState(() {
            messages.add(_MessageData('User ${client.name} was unmuted on the server!', clientId: 0));
          });
        }
        break;
      }

      case ChatPacketType.AskUserIdentification:
        // TODO: Multiple packet type still not implemented
        throw 'not implemented';

      case ChatPacketType.InvalidOperation:
        _showDialog(context, 'Invalid operation!');
        break;

      case ChatPacketType.NoPermissions: 
        _showDialog(context, 'No permissions!');
        break;

      case ChatPacketType.FloodWarning:
        _showDialog(context, 'Please do not spam!');
        messages.removeLast();
        break;

      case ChatPacketType.MessageIdAssigned:
        if (messages.last.id != 0) {
          // Warning: Message ID was already assigned.
          // Ignored, since its example app. In real world each message should 
          // have client side indentifier that which would be used by server 
          // to assign the message right global message id.
        }
        List<int> prefix = data.take(2).toList();
        final messageId = prefix[0] * 0xFF + prefix[1];
        if (messageId == 0) {
          // Warning: Server rejected message.
          // See above note too; In real world, below message to be removed 
          // also should be 'confirmed' by server using client side message ID.
          messages.removeLast();
          _showDialog(context, 'Message was rejected by server!');
          return;
        }
        messages.last.id = messageId;
        setState(() {
          lastSeenUserMessageIndex = lastSeenMessageIndex = messages.length - 1; 
        });
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
      if (text.startsWith('/shrug')) {
        text = text.length > 7 ? '¯\\_(ツ)_/¯' + text.substring(7) : '¯\\_(ツ)_/¯';
      }

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
    if (!this._connection.isConnected) {
      // Ignore, if not connected.
      return;
    }
    final int messageId = messages[index].id;
    await this._connection.sendPacket(ChatPacketType.RemoveMessage, Uint8List.fromList([
      messageId ~/ 0xFF,
      messageId % 0xFF
    ]));
  }

  void _notifySeen() {
    if (!this._connection.isConnected) {
      // Ignore, if not connected.
      return;
    }
    if (lastSeenMessageIndex <= lastSeenMessageIndexReported) {
      return;
    }
    if (messages.length - 1 <= lastSeenMessageIndex) {
      return;
    }
    lastSeenMessageIndexReported = lastSeenMessageIndex;
    final int messageId = messages.last.id;
    this._connection.sendPacket(ChatPacketType.NotifyMessageSeen, Uint8List.fromList([
      messageId ~/ 0xFF,
      messageId % 0xFF
    ]));
  }
}
