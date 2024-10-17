import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sample_app/utils.dart';
import 'package:flutter_sample_app/video_call.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;


void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: "Sample App",
    theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.deepPurple, colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.pinkAccent)),
    home: const MyApp(),
    routes: <String, WidgetBuilder>{
      '/Conference': (context) => MyConfApp(
        token: _State.token,
      )
    },
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _State createState() => _State();
}

class _State extends State<MyApp> {
  /*Your webservice host URL, Keet the defined host when kTry = true */
  static const String kBaseURL = "https://demo.enablex.io/";
  /* To try the app with Enablex hosted service you need to set the kTry = true */
  static bool kTry = true;
  /*Use enablec portal to create your app and get these following credentials*/

  static const String kAppId = "App-id";
  static const String kAppkey = "App-key";

  var header = (kTry)
      ? {
    "x-app-id": kAppId,
    "x-app-key": kAppkey,
    "Content-Type": "application/json"
  }
      : {"Content-Type": "application/json"};

  TextEditingController nameController = TextEditingController();
  TextEditingController roomIdController = TextEditingController();
  static String token = "";

  Future<void> createRoomvalidations() async {
    if (nameController.text.isEmpty) {
      isValidated = false;
      Fluttertoast.showToast(
          msg: "Please Enter your name",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      isValidated = true;
    }
  }


  Future<void> permissionAccess() async {
    bool isPermissionGranted =
    await handlePermissionsForCall(context);

    if (isPermissionGranted) {
      joinRoomValidations();
    }
  }

  Future<void> joinRoomValidations() async {
    // await _handleCameraAndMic();
    if (nameController.text.isEmpty) {
      Fluttertoast.showToast(
          msg: "Please Enter your name",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      isValidated = false;
    } else if (roomIdController.text.isEmpty) {
      Fluttertoast.showToast(
          msg: "Please Enter your roomId",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      isValidated = false;
    } else {
      isValidated = true;
    }
  }

  Future<String> createRoom() async {
    var response = await http.post(
        Uri.parse(
            "${kBaseURL}createRoom"), // replace FQDN with Your Server API URL
        headers: header);
    if (response.statusCode == 200) {
      Map<String, dynamic> user = jsonDecode(response.body);
      if(user['result']==403){
        Fluttertoast.showToast(
            msg: "${user['desc']}",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);

      }else{
        Map<String, dynamic> room = user['room'];
        setState(() => roomIdController.text = room['room_id'].toString());
        if (kDebugMode) {
          print(response.body);
        }
      }
     print(user);

      return response.body;
    } else {
      throw Exception('Failed to load post');
    }
  }

  Future<String> createToken() async {
    var value = {
      'user_ref': "2236",
      "roomId": roomIdController.text,
      "role": "participant",
      "name": nameController.text
    };
    if (kDebugMode) {
      print(jsonEncode(value));
    }
    var response = await http.post(
        Uri.parse(
            "${kBaseURL}createToken"), // replace FQDN with Your Server API URL
        headers: header,
        body: jsonEncode(value));

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print(response.body);
      }
      Map<String, dynamic> user = jsonDecode(response.body);
      if (user["result"]==0) {
        setState(() => token = user['token'].toString());
        Navigator.pushNamed(context, '/Conference');
      } else {
        Fluttertoast.showToast(
            msg: " ${user['error']} or ${user['desc']} ",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);

      }

      if (kDebugMode) {
        print(token);
      }

      return response.body;
    } else {
      throw Exception('Failed to load post');
    }
  }

  TextStyle style = const TextStyle(fontFamily: 'Montserrat', fontSize: 16.0);

  bool isValidated = false;
  bool permissionError = false;
  @override
  Widget build(BuildContext context) {
    final usernameField = TextField(
      obscureText: false,
      style: style,
      controller: nameController,
      decoration: InputDecoration(
          contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Username",
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0),
            borderSide: BorderSide(
            color: Colors.blue, // Change the color as needed
            width: 1.5,
          ),),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32.0),
          borderSide: BorderSide(
            color: Colors.grey, // Border color when not focused
            width: 1.5, // Set the border width
          ),
        ),),

    );
    final roomIdField = TextField(
      obscureText: false,
      controller: roomIdController,
      style: style,
      decoration: InputDecoration(
          contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Room Id",
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32.0),
          borderSide: BorderSide(
            color: Colors.grey, // Border color when not focused
            width: 1.5, // Set the border width
          ),
        ),),
    );
    final createRoomButon = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Colors.deepPurple,
      child: MaterialButton(
        // minWidth: MediaQuery.of(context).size.width / 2,
        minWidth: 100,
        padding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () async{
          bool isPermissionGranted =
          await handlePermissionsForCall(context);
          if(isPermissionGranted) {
            createRoomvalidations();
          }
          if (isValidated) {
            createRoom();
          }
        },
        child: Text("Create Room",
            textAlign: TextAlign.center,
            style: style.copyWith(
                color: Colors.white, fontWeight: FontWeight.normal)),
      ),
    );

    final joinButon = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Colors.deepPurple,
      child: MaterialButton(
        minWidth: 100,
        // minWidth: MediaQuery.of(context).size.width / 2,
        padding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () {
          joinRoomValidations();
          if (isValidated) {
            createToken();
          }
        },
        child: Text("Join",
            textAlign: TextAlign.center,
            style: style.copyWith(
                color: Colors.white, fontWeight: FontWeight.normal)),
      ),
    );
    return Scaffold(
        appBar: AppBar(
          title: const Text('Sample App'),
        ),
        body: Padding(
            padding: const EdgeInsets.all(10),
            child: ListView(
              children: <Widget>[
                Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(10),
                    child: const Text(
                      'Enablex',
                      style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w500,
                          fontSize: 30),
                    )),
                Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(10),
                    child: const Text(
                      'Welcome !',
                      style: TextStyle(fontSize: 20),
                    )),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: usernameField,
                ),
                Container(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: roomIdField),
                Container(
                    alignment: Alignment.center,
                    height: 100,
                    width: 100,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                            flex: 1,
                            child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: createRoomButon)),
                        Expanded(
                            flex: 1,
                            child: Padding(
                                padding: const EdgeInsets.all(10), child: joinButon)),
                      ],
                    ))
              ],
            )));
  }
}
