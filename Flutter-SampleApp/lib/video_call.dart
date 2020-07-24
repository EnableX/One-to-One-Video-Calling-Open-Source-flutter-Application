import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:enx_flutter_plugin/enx_player_widget.dart';

import 'package:enx_flutter_plugin/enx_flutter_plugin.dart';

class MyConfApp extends StatefulWidget {
  MyConfApp({this.token});
  final String token;
  @override
  Conference createState() => Conference();
}

class Conference extends State<MyConfApp> {
  bool isAudioMuted = false;
  bool isVideoMuted = false;

  @override
  void initState() {
    super.initState();
    initEnxRtc();
    _addEnxrtcEventHandlers();
  }

  Future<void> initEnxRtc() async {
    Map<String, dynamic> map2 = {
      'minWidth': 320,
      'minHeight': 180,
      'maxWidth': 1280,
      'maxHeight': 720
    };
    Map<String, dynamic> map1 = {
      'audio': true,
      'video': true,
      'data': true,
      'framerate': 30,
      'maxVideoBW': 1500,
      'minVideoBW': 150,
      'audioMuted': false,
      'videoMuted': false,
      'name': 'flutter',
      'videoSize': map2
    };
    await EnxFlutterPlugin.joinRoom(widget.token, map1, null, null);
  }

  void _addEnxrtcEventHandlers() {
    EnxFlutterPlugin.onRoomConnected = (Map<dynamic, dynamic> map) {
      setState(() {
        print('onRoomConnectedFlutter' + jsonEncode(map));
      });
      EnxFlutterPlugin.publish();
    };

    EnxFlutterPlugin.onPublishedStream = (Map<dynamic, dynamic> map) {
      setState(() {
        print('onPublishedStream' + jsonEncode(map));
        EnxFlutterPlugin.setupVideo(0, 0, true, 300, 200);
      });
    };

    EnxFlutterPlugin.onStreamAdded = (Map<dynamic, dynamic> map) {
      print('onStreamAdded' + jsonEncode(map));
      print('onStreamAdded Id' + map['streamId']);
      String streamId;
      setState(() {
        streamId = map['streamId'];
      });
      EnxFlutterPlugin.subscribe(streamId);
    };

    EnxFlutterPlugin.onRoomError = (Map<dynamic, dynamic> map) {
      setState(() {
        print('onRoomError' + jsonEncode(map));
      });
    };
    EnxFlutterPlugin.onNotifyDeviceUpdate = (String deviceName) {
      print('onNotifyDeviceUpdate' + deviceName);
    };

    EnxFlutterPlugin.onActiveTalkerList = (Map<dynamic, dynamic> map) {
      final items = (map['activeList'] as List)
          .map((i) => new ActiveListModel.fromJson(i));
      if (items.length > 0) {
        setState(() {
          for (final item in items) {
            _remoteUsers.add(int.parse(item.streamId));
            break;
          }
        });
      }
    };

    EnxFlutterPlugin.onEventError = (Map<dynamic, dynamic> map) {
      setState(() {
        print('onEventError' + jsonEncode(map));
      });
    };

    EnxFlutterPlugin.onEventInfo = (Map<dynamic, dynamic> map) {
      setState(() {
        print('onEventInfo' + jsonEncode(map));
      });
    };
    EnxFlutterPlugin.onUserConnected = (Map<dynamic, dynamic> map) {
      setState(() {
        print('onUserConnected' + jsonEncode(map));
      });
    };
    EnxFlutterPlugin.onUserDisConnected = (Map<dynamic, dynamic> map) {
      setState(() {
        print('onUserDisConnected' + jsonEncode(map));
      });
    };
    EnxFlutterPlugin.onRoomDisConnected = (Map<dynamic, dynamic> map) {
      setState(() {
        print('onRoomDisConnected' + jsonEncode(map));
        Navigator.pop(context, '/Conference');
      });
    };
    EnxFlutterPlugin.onAudioEvent = (Map<dynamic, dynamic> map) {
      print('onAudioEvent' + jsonEncode(map));
      setState(() {
        if (map['msg'].toString() == "Audio Off") {
          isAudioMuted = true;
        } else {
          isAudioMuted = false;
        }
      });
    };
    EnxFlutterPlugin.onVideoEvent = (Map<dynamic, dynamic> map) {
      print('onVideoEvent' + jsonEncode(map));
      setState(() {
        if (map['msg'].toString() == "Video Off") {
          isVideoMuted = true;
        } else {
          isVideoMuted = false;
        }
      });
    };
  }

  void _setMediaDevice(String value) {
    Navigator.of(context, rootNavigator: true).pop();
    EnxFlutterPlugin.switchMediaDevice(value);
  }

  createDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text('Media Devices'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: deviceList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: Text(deviceList[index].toString()),
                          onTap: () =>
                              _setMediaDevice(deviceList[index].toString()),
                        );
                      },
                    ),
                  )
                ],
              ));
        });
  }

  void _disconnectRoom() {
    EnxFlutterPlugin.disconnect();
  }

  void _toggleAudio() {
    if (isAudioMuted) {
      EnxFlutterPlugin.muteSelfAudio(false);
    } else {
      EnxFlutterPlugin.muteSelfAudio(true);
    }
  }

  void _toggleVideo() {
    if (isVideoMuted) {
      EnxFlutterPlugin.muteSelfVideo(false);
    } else {
      EnxFlutterPlugin.muteSelfVideo(true);
    }
  }

  void _toggleSpeaker() async {
    List<dynamic> list = await EnxFlutterPlugin.getDevices();
    setState(() {
      deviceList = list;
    });
    print('deviceList');
    print(deviceList);
    createDialog();
  }

  void _toggleCamera() {
    EnxFlutterPlugin.switchCamera();
  }

  int remoteView = -1;
  List<dynamic> deviceList;

   Widget _viewRows() {
    return Column(
      children: <Widget>[
        for (final widget in _renderWidget)
          Expanded(
            child: Container(
              child: widget,
            ),
          )
      ],
    );
  }

  Iterable<Widget> get _renderWidget sync* {
    for (final streamId in _remoteUsers) {
      double width = MediaQuery.of(context).size.width;
     yield EnxPlayerWidget(streamId, local: false,width:width.toInt(),height:380);
    }
  }

  final _remoteUsers = List<int>();


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Sample App",
      theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: Colors.deepPurple,
          accentColor: Colors.pinkAccent),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Conference'),
        ),
        body: Container(
          color: Colors.black,
          child: Column(
            children: [
              Container(
                  alignment: Alignment.topRight,
                  height: 100,
                  width: MediaQuery.of(context).size.width,
                  child: Container(
                    color: Colors.black,
                    height: 100,
                    width: 100,
                    child: EnxPlayerWidget(0, local: true,width: 100, height: 100),
                  )),
              Stack(
                children: <Widget>[
                  Card(
                    color: Colors.black,
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      height: MediaQuery.of(context).size.height - 200,
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              child: _viewRows()
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 30,
                    left: 20,
                    right: 20,
                    child: Container(
                      color: Colors.white,
                      // height: 100,
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width / 6,
                            child: MaterialButton(
                              child: isAudioMuted
                                  ? Image.asset(
                                      'assets/mute_audio.png',
                                      fit: BoxFit.cover,
                                      height: 30,
                                      width: 30,
                                    )
                                  : Image.asset(
                                      'assets/unmute_audio.png',
                                      fit: BoxFit.cover,
                                      height: 30,
                                      width: 30,
                                    ),
                              onPressed: _toggleAudio,
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width / 6,
                            child: MaterialButton(
                              child: Image.asset(
                                'assets/camera_switch.png',
                                fit: BoxFit.cover,
                                height: 30,
                                width: 30,
                              ),
                              onPressed: _toggleCamera,
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width / 6,
                            child: MaterialButton(
                              child: isVideoMuted
                                  ? Image.asset(
                                      'assets/mute_video.png',
                                      fit: BoxFit.cover,
                                      height: 30,
                                      width: 30,
                                    )
                                  : Image.asset(
                                      'assets/unmute_video.png',
                                      fit: BoxFit.cover,
                                      height: 30,
                                      width: 30,
                                    ),
                              onPressed: _toggleVideo,
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width / 6,
                            child: MaterialButton(
                              child: Image.asset(
                                'assets/unmute_speaker.png',
                                fit: BoxFit.cover,
                                height: 30,
                                width: 30,
                              ),
                              onPressed: _toggleSpeaker,
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width / 6,
                            child: MaterialButton(
                              child: Image.asset(
                                'assets/disconnect.png',
                                fit: BoxFit.cover,
                                height: 30,
                                width: 30,
                              ),
                              onPressed: _disconnectRoom,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ActiveList {
  bool active;
  List<ActiveListModel> activeList = [];
  String event;

  ActiveList(this.active, this.activeList, this.event);

  factory ActiveList.fromJson(Map<dynamic, dynamic> json) {
    return ActiveList(
      json['active'] as bool,
      (json['activeList'] as List).map((i) {
        return ActiveListModel.fromJson(i);
      }).toList(),
      json['event'] as String,
    );
  }
}

class ActiveListModel {
  String name;
  String streamId;
  String clientId;
  String videoaspectratio;
  String mediatype;
  bool videomuted;
  String reason;

  ActiveListModel(this.name, this.streamId, this.clientId,
      this.videoaspectratio, this.mediatype, this.videomuted, this.reason);

  // convert Json to an exercise object
  factory ActiveListModel.fromJson(Map<dynamic, dynamic> json) {
    return ActiveListModel(
      json['name'] as String,
      json['streamId'] as String,
      json['clientId'] as String,
      json['videoaspectratio'] as String,
      json['mediatype'] as String,
      json['videomuted'] as bool,
      json['reason'] as String,
    );
  }
}