# 1-to-1 RTC: A Sample Flutter App with EnableX Flutter Toolkit

This is a Sample Flutter App demonstrates the use of EnableX (https://www.enablex.io) platform Server APIs and Flutter Toolkit to build 1-to-1 RTC (Real Time Communication) Application. It allows developers to ramp up on app development by hosting on their own devices.

This App creates a virtual Room on the fly hosted on the Enablex platform using REST calls and uses the Room credentials (i.e. Room Id) to connect to the virtual Room as a mobile client. The same Room credentials can be shared with others to join the same virtual Room to carry out a RTC session.

> EnableX Developer Center: https://developer.enablex.io/

## 1. Getting Started

### 1.1 Pre-Requisites

#### 1.1.1 App Id and App Key

- Register with EnableX [https://www.enablex.io]
- Login to the EnableX Portal
- Create your Application Key
- Get your App ID and App Key delivered to your Email

#### 1.1.2 Sample Flutter Client

- Clone or download this Repository [https://github.com/EnableX/One-to-One-Video-Call-Webrtc-Application-Sample-for-Flutter.git]

#### 1.1.3 Test Application Server

You need to setup an Application Server to provision Web Service API for your Android Application to communicate enabling Video Session.

To help you to try our Android Application quickly, without having to setup Applciation Server, this Application is shipped pre-configured to work in a "try" mode with EnableX hosted Application Server i.e. https://demo.enablex.io.

Our Application Server restricts a single Session Duation to 10 minutes, and allows 1 moderator and note more than 3 Participant in a Session.

Once you tried EnableX Android Sample Application, you may need to setup your own Application Server and verify your Application to work with your Application Server. More on this, read Point 2 later in the Document.

#### 1.1.4 Configure Flutter Client

- Open the App
- Go to Main.dart and change the following:

```
 /* To try the App with Enablex Hosted Service you need to set the kTry = true When you setup your own Application Service, set kTry = false */

     public  static  final  boolean kTry = true;

 /* Your Web Service Host URL. Keet the defined host when kTry = true */

     String kBaseURL = "https://demo.enablex.io/"

 /* Your Application Credential required to try with EnableX Hosted Service
     When you setup your own Application Service, remove these */

     String kAppId = ""
     String kAppkey = ""

```

### 1.2 Test

#### 1.2.1 Open the App

- Open the App in your Device. You get a form to enter Credentials i.e. Name & Room Id.
- You need to create a Room by clicking the "Create Room" button.
- Once the Room Id is created, you can use it and share with others to connect to the Virtual Room to carry out a RTC Session.

## 2 Server API

EnableX Server API is a Rest API service meant to be called from Partners' Application Server to provision video enabled
meeting rooms. API Access is given to each Application through the assigned App ID and App Key. So, the App ID and App Key
are to be used as Username and Password respectively to pass as HTTP Basic Authentication header to access Server API.

For this application, the following Server API calls are used:

- https://developer.enablex.io/latest/server-api/rooms-route/#get-rooms - To get list of Rooms
- https://developer.enablex.io/latest/server-api/rooms-route/#get-room-info - To get information of the given Room
- https://developer.enablex.io/latest/server-api/rooms-route/#create-token - To create Token for the given Room

To know more about Server API, go to:
https://developer.enablex.io/latest/server-api/

## 3 Flutter Toolkit

Flutter Sample App to use Flutter Toolkit to communicate with EnableX Servers to initiate and manage Real Time Communications.

- Documentation: https://developer.enablex.io/latest/client-api/flutter-toolkit/
- Download: https://developer.enablex.io/resources/downloads/#flutter-toolkit

## 4 Application Walk-through

### 4.1 Create Token

We create a Token for a Room Id to get connected to EnableX Platform to connect to the Virtual Room to carry out a RTC Session.

To create Token, we make use of Server API. Refer following documentation:
https://developer.enablex.io/latest/server-api/rooms-route/#create-token

### 4.2 Connect to a Room, Initiate & Publish Stream

We use the Token to get connected to the Virtual Room. Once connected, we intiate local stream and publish into the room. Refer following documentation for this process:
https://developer.enablex.io/latest/client-api/flutter-toolkit/enxrtc/

### 4.3 Play Stream

We play the Stream into EnxPlayerWidget Object. You can pass local true for localStream player, and local false for remote stream Players.
Add import for EnxPlayerWideget

```
import 'package:enx_flutter_plugin/enx_player_widget.dart';

EnxPlayerWidget(0, local: true)
```

### 4.4 Handle Server Events

EnableX Platform will emit back many events related to the ongoing RTC Session as and when they occur implicitly or explicitly as a result of user interaction. We use Call Back Methods to handle all such events.

Add import to handle callbacks and methods:

```

import 'package:enx_flutter_plugin/enx_flutter_plugin.dart';

/* Example of Call Back Methods */

/* Call Back Method: onRoomConnected
Handles successful connection to the Virtual Room */

EnxFlutterPlugin.onRoomConnected = (Map<dynamic, dynamic> map) {
       /* You may initiate and publish stream */
        print('onRoomConnectedFlutter' + jsonEncode(map));
    };

/* Call Back Method: onRoomError
 Error handler when room connection fails */
 EnxFlutterPlugin.onRoomError = (Map<dynamic, dynamic> map) {

    };

/* Call Back Method: onStreamAdded
 To handle any new stream added to the Virtual Room */

 EnxFlutterPlugin.onStreamAdded = (Map<dynamic, dynamic> map) {
      print('onStreamAdded' + jsonEncode(map));
       /* Subscribe Remote Stream */
}


/* Call Back Method: onActiveTalkerList
 To handle any time Active Talker list is updated */

 EnxFlutterPlugin.onActiveTalkerList = (Map<dynamic, dynamic> map) {
     /* Handle Stream Players */
}
```
