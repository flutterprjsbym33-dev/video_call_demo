import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestPermissions() async {

    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();


    bool cameraGranted = statuses[Permission.camera] == PermissionStatus.granted;
    bool micGranted = statuses[Permission.microphone] == PermissionStatus.granted;

    if (cameraGranted && micGranted) {
      return true;
    } else {

      if (statuses[Permission.camera] == PermissionStatus.permanentlyDenied ||
          statuses[Permission.microphone] == PermissionStatus.permanentlyDenied) {

        openAppSettings();
      }
      return false;
    }
  }

  static Future<bool> checkPermissions() async {
    bool cameraGranted = await Permission.camera.isGranted;
    bool micGranted = await Permission.microphone.isGranted;
    return cameraGranted && micGranted;
  }
}