import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  final PermissionHandler _permissionHandler = PermissionHandler();

  Future<bool> _requestPermission() async {
    var result = await _permissionHandler.requestPermissions([
      PermissionGroup.microphone,
      PermissionGroup.storage,
      PermissionGroup.camera
    ]);
    if (result == PermissionStatus.granted) {
      return true;
    }
    return false;
  }

  Future<bool> requestPermission({Function onPermissionDenied}) async {
    var granted = await _requestPermission();
    if (!granted) {
      onPermissionDenied();
    }
    return granted;
  }

  Future<bool> hasPhonePermission() async {
    return hasPermission(PermissionGroup.phone);
  }

  Future<bool> hasPermission(PermissionGroup permission) async {
    var permissionStatus =
        await _permissionHandler.checkPermissionStatus(permission);
    return permissionStatus == PermissionStatus.granted;
  }
}
