import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestPermissions() async {
    // Request camera and microphone permissions
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    // Check if both permissions are granted
    bool cameraGranted = statuses[Permission.camera] == PermissionStatus.granted;
    bool micGranted = statuses[Permission.microphone] == PermissionStatus.granted;

    if (cameraGranted && micGranted) {
      return true;
    } else {
      // Check if permissions are permanently denied
      if (statuses[Permission.camera] == PermissionStatus.permanentlyDenied ||
          statuses[Permission.microphone] == PermissionStatus.permanentlyDenied) {
        // Open app settings
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