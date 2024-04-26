
import 'dart:convert';
import 'package:enx_flutter_plugin/base.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:enx_flutter_plugin/enx_player_widget.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:enx_flutter_plugin/enx_flutter_plugin.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MyConfApp extends StatefulWidget {
  MyConfApp({super.key, required this.token});
  final String token;
  @override
  Conference createState() => Conference();
}

class Conference extends State<MyConfApp> {
  bool isAudioMuted = false;
  bool isVideoMuted = false;
  bool isRoomConnected=false;

  @override
  void initState() {
    super.initState();
    print('here 1');
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
    Map<String, dynamic> localInfo = {
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

    Map<String, dynamic> roomInfo = {
      'allow_reconnect': true,
      'number_of_attempts': 3,
      'timeout_interval': 15,
    };

    print('here 2');
    await EnxRtc.joinRoom(widget.token, localInfo, roomInfo, []);
    print('here 3');
  }

  void _addEnxrtcEventHandlers() {
    print('here 4');
    EnxRtc.onRoomConnected = (Map<dynamic, dynamic> map) {
      setState(() {
        isRoomConnected=true;
        print('onRoomConnectedFlutter' + jsonEncode(map));

      });
      EnxRtc.publish();
    };
    print('here 5');
    EnxRtc.onPublishedStream = (Map<dynamic, dynamic> map) {
      setState(() {
        print('onPublishedStream' + jsonEncode(map));
        EnxRtc.setupVideo(0, 0, true, 300, 200);
      });
    };
    print('here 6');
    EnxRtc.onStreamAdded = (Map<dynamic, dynamic> map) {
      print('onStreamAdded' + jsonEncode(map));
      print('onStreamAdded Id' + map['streamId']);
      String streamId='';
      setState(() {
        streamId = map['streamId'];
      });
      EnxRtc.subscribe(streamId);
    };
    print('here 7');
    EnxRtc.onRoomError = (Map<dynamic, dynamic> map) {
      setState(() {
        print('onRoomError' + jsonEncode(map));
      });
    };
    EnxRtc.onNotifyDeviceUpdate = (String deviceName) {
      print('onNotifyDeviceUpdate' + deviceName);
    };
    print('here 8');
    EnxRtc.onActiveTalkerList = (Map<dynamic, dynamic> map) {
      print('onActiveTalkerList ' + map.toString());
      print('here 9');
      final items = (map['activeList'] as List)
          .map((i) => new ActiveListModel.fromJson(i));
      if (items.length > 0) {
        print('here 10');
        setState(() {
          for (final item in items) {
            if(!_remoteUsers.contains(item.streamId)){
              print('_remoteUsers ' + map.toString());
              _remoteUsers.add(item.streamId);
            }
          }
        });
      }
    };
    print('here 11');
    EnxRtc.onEventError = (Map<dynamic, dynamic> map) {
      setState(() {
        print('onEventError' + jsonEncode(map));
      });
    };
    print('here 12');
    EnxRtc.onEventInfo = (Map<dynamic, dynamic> map) {
      setState(() {
        print('onEventInfo' + jsonEncode(map));
      });
    };
    print('here 13');
    EnxRtc.onUserConnected = (Map<dynamic, dynamic> map) {
      setState(() {
        print('onUserConnected' + jsonEncode(map));
      });
    };
    EnxRtc.onUserDisConnected = (Map<dynamic, dynamic> map) {
      setState(() {
        print('onUserDisConnected' + jsonEncode(map));
      });
    };
    print('here 14');
    EnxRtc.onRoomDisConnected = (Map<dynamic, dynamic> map) {
      Navigator.pop(context, '/Conference');
      // setState(() {
      //   print('onRoomDisConnected' + jsonEncode(map));
      //   Navigator.pop(context, '/Conference');
      // });
    };
    print('here 15');
    EnxRtc.onAudioEvent = (Map<dynamic, dynamic> map) {
      print('onAudioEvent' + jsonEncode(map));
      setState(() {
        if (map['msg'].toString() == "Audio Off") {
          isAudioMuted = true;
        } else {
          isAudioMuted = false;
        }
      });
    };
    print('here 16');
    EnxRtc.onVideoEvent = (Map<dynamic, dynamic> map) {
      print('onVideoEvent' + jsonEncode(map));
      setState(() {
        if (map['msg'].toString() == "Video Off") {
          isVideoMuted = true;
        } else {
          isVideoMuted = false;
        }
      });
    };
    print('here 17');
  }

  void _setMediaDevice(String value) {
    Navigator.of(context, rootNavigator: true).pop();
    EnxRtc.switchMediaDevice(value);
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
    EnxRtc.disconnect();
    Navigator.pop(context);
  }

  void _toggleAudio() {
    if (isAudioMuted) {
      EnxRtc.muteSelfAudio(false);
    } else {
      EnxRtc.muteSelfAudio(true);
    }
  }

  void _toggleVideo() {
    if (isVideoMuted) {
      EnxRtc.muteSelfVideo(false);
    } else {
      EnxRtc.muteSelfVideo(true);
    }
  }

  void _toggleSpeaker() async {
    List<dynamic> list = await EnxRtc.getDevices();
    setState(() {
      deviceList = list;
    });
    if(kIsWeb){
      Map<String, dynamic> device = convertMapToMap(list[0]) ;
      print("mic and  ${device["micList"]}");
      List<dynamic> micList = device["micList"];
      deviceList = micList.map((device) => device["label"]).toList();
      print("mic and  $deviceList");
    }
    print(deviceList);
    createDialog();
  }
// Function to convert LinkedMap<Object?, Object?> to Map<String, dynamic>
  Map<String, dynamic> convertMapToMap(Map<Object?, Object?> map) {
    // Create an empty Map<String, dynamic>
    Map<String, dynamic> resultMap = {};

    // Iterate through the entries of the Map
    map.entries.forEach((entry) {
      // Check if the key is a String and value is dynamic
      if (entry.key is String && entry.value is dynamic) {
        // Add the entry to the resultMap with appropriate types
        resultMap[entry.key as String] = entry.value;
      } else {
        // Handle cases where the key is not a String or value is not dynamic
        // You can choose to skip these entries or handle them differently
        // For simplicity, we'll skip them in this example
      }
    });

    // Return the resulting Map<String, dynamic>
    return resultMap;
  }
  Future<dynamic> _toggleCamera() async{
    var camList=[];
    if(kIsWeb){

      List<dynamic> list = await EnxRtc.getDevices();
      Map<String, dynamic> device = convertMapToMap(list[0]) ;

      if(device['camList'].length==1){

        Fluttertoast.showToast(
            msg: "Only one camera available",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }else{
        await EnxRtc.switchCamera();

      }
    }else{
      await EnxRtc.switchCamera();
    }

  }

  int remoteView = -1;
  late List<dynamic> deviceList;

  Widget viewFlutter(int crossAxisCount){
    return kIsWeb?_buildWebGrid():_viewRows(crossAxisCount);
  }
  Widget _buildWebGrid() {
    // Web grid with 4 columns

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    int crossAxisCount;
    double itemWidth;
    double itemHeight;

      if (_remoteUsers.length <= 3) {
        crossAxisCount = _remoteUsers.length;
        itemWidth = screenWidth / crossAxisCount;
        itemHeight = screenHeight / 2;
      } else if (_remoteUsers.length <= 5) {
        crossAxisCount = 3;
        itemWidth = screenWidth / crossAxisCount;
        itemHeight = screenHeight / (_remoteUsers.length / crossAxisCount);
      } else {
        crossAxisCount = 4; // Adjust as needed
        itemWidth = screenWidth / crossAxisCount;
        itemHeight = screenHeight / (_remoteUsers.length / crossAxisCount);
      }


    return GridView.builder(
      gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: itemWidth / itemHeight,
      ),
      itemCount: _remoteUsers.length,
      itemBuilder: (BuildContext context, int index) {
        return  AspectRatio(
         aspectRatio: 4/3,
          child: Align(
            alignment: Alignment.center,
            child: EnxPlayerWidget(_remoteUsers[index], local: false,mScalingType: ScalingType.SCALE_ASPECT_BALANCED,height: 400,
                width: 400),
          ),
        );
      },
    );
  }
  Widget _viewRows(int crossAxisCount) {

    return GridView.count(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 4.0,
      mainAxisSpacing: 4.0,

      childAspectRatio: 1.1,
      children: <Widget>[
        for (final widget in _renderWidget)
          SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: widget
          ),

      ],
    );
  }

  Iterable<Widget> get _renderWidget sync* {
    for (final streamId in _remoteUsers) {
      double width = MediaQuery.of(context).size.width;
      yield EnxPlayerWidget(streamId, local: false,width:width.toInt(),height:380);
    }
  }

  final _remoteUsers = <int>[];


  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    // Define the number of columns based on the platform
    final int crossAxisCount = isMobile ? 2 : 4;
    return Scaffold(
      appBar: kIsWeb?null: AppBar(
        title: const Text('Meet'),
      ),
      body: Container(
        color: Colors.black,
        child: Stack(
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
                      child: _remoteUsers.isNotEmpty?Container(
                          child:viewFlutter(crossAxisCount)
                      ):   const Center(
                        child: Text(
                          'Waiting for some one to join',
                          style: TextStyle(color: Colors.redAccent,
                              fontWeight: FontWeight.w500,
                              fontSize: 20),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.white,
                // height: 100,
                width: MediaQuery.of(context).size.width,
                child: Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 5,
                      child: MaterialButton(
                          onPressed: _toggleAudio,
                          child: isAudioMuted
                              ?const ImageIcon(AssetImage("assets/mute_audio.png"))

                              :const ImageIcon(AssetImage("assets/unmute_audio.png"))
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 5,
                      child: MaterialButton(
                        onPressed: () async {
                          await _toggleCamera();
                        },
                        child: Image.asset(
                          'assets/camera_switch.png',
                          fit: BoxFit.cover,
                          height: 30,
                          width: 30,
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width / 5,
                      child: MaterialButton(
                        onPressed: _toggleVideo,
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
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width / 5,
                      child: MaterialButton(
                        onPressed: _toggleSpeaker,
                        child: Image.asset(
                          'assets/unmute_speaker.png',
                          fit: BoxFit.cover,
                          height: 30,
                          width: 30,
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width / 5,
                      child: MaterialButton(
                        onPressed: _disconnectRoom,
                        child: Image.asset(
                          'assets/disconnect.png',
                          fit: BoxFit.cover,
                          height: 30,
                          width: 30,
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ),
            kIsWeb?SizedBox(
              height: 140,
              width: 180,
              child: EnxPlayerWidget(0, local: true,width: 150, height: 150,mScalingType: ScalingType.SCALE_ASPECT_BALANCED),
            ): isRoomConnected? Container(
                alignment: Alignment.topRight,
                height: 90,
                width: MediaQuery.of(context).size.width,
                child: Container(
                  color: Colors.black,
                  height: 100,
                  width: 100,
                  child: EnxPlayerWidget(0, local: true,width: 100, height: 100),
                )):const Text(
              'Connecting',
              style: TextStyle(color: Colors.redAccent,
                  fontWeight: FontWeight.w500,
                  fontSize: 20),
            ),
          ],
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
  int streamId;
  String clientId;
  String videoaspectratio;
  String mediatype;
  bool videomuted;

  ActiveListModel(this.name, this.streamId, this.clientId,
      this.videoaspectratio, this.mediatype, this.videomuted);

  // convert Json to an exercise object
  factory ActiveListModel.fromJson(Map<dynamic, dynamic> json) {
    int sId = int.parse(json['streamId'].toString());
    return ActiveListModel(
      json['name'] as String,
      sId,
//      json['streamId'] as int,
      json['clientId'] as String,
      json['videoaspectratio'] as String,
      json['mediatype'] as String,
      json['videomuted'] as bool,
    );
  }
}
