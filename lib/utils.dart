import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> handlePermissionsForCall(BuildContext context) async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.camera,
    Permission.microphone,

  ].request();
/*

   if (statuses[Permission.camera]!.isPermanentlyDenied) {
    showCustomDialog(context, "Permission Required",
        "Camera Permission Required for Video Call", () {
          Navigator.pop(context);
          openAppSettings();
        });
    return false;
  }
   else if (statuses[Permission.microphone]!.isPermanentlyDenied) {
    showCustomDialog(context, "Permission Required",
        "Microphone Permission Required for Video Call", () {
          Navigator.pop(context);
          openAppSettings();
        });
    return false;
  }
*/

  if (statuses[Permission.camera]!.isDenied) {
    return false;
  } else if (statuses[Permission.microphone]!.isDenied) {
    return false;
  }
  return true;
}

void showCustomDialog(BuildContext context, String title, String message,
    Function okPressed) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      // return object of type Dialog

      return AlertDialog(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        title: Text(
            title
        ),
        content:  Text(
            message

        ),
        actions: <Widget>[
          ElevatedButton(
            child:
            const Text("OK"),
            onPressed: okPressed(),
          ),
        ],
      );
    },
  );
}