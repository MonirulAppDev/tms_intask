import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  static Future<bool> requestExactAlarmPermission() async {
    final status = await Permission.scheduleExactAlarm.status;
    if (status.isGranted) return true;

    final result = await Permission.scheduleExactAlarm.request();
    return result.isGranted;
  }

  static Future<bool> checkExactAlarmPermission() async {
    return await Permission.scheduleExactAlarm.isGranted;
  }
}
