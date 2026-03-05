import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import '../../features/scheduler/domain/entities/schedule.dart';
import 'background_service.dart';

class AlarmService {
  static Future<void> initialize() async {
    await AndroidAlarmManager.initialize();
  }

  static Future<bool> scheduleAlarm(Schedule schedule) async {
    // We use the ID hashcode as an int ID for the alarm.
    final int alarmId = schedule.id.hashCode;

    return await AndroidAlarmManager.oneShotAt(
      schedule.scheduledTime,
      alarmId,
      BackgroundService.alarmCallback,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
      params: {
        'packageName': schedule.packageName,
        'scheduleId': schedule.id,
        'appName': schedule.appName,
        'label': schedule.label,
        'scheduledTime': schedule.scheduledTime.millisecondsSinceEpoch,
      },
    );
  }

  static Future<bool> cancelAlarm(String scheduleId) async {
    final int alarmId = scheduleId.hashCode;
    return await AndroidAlarmManager.cancel(alarmId);
  }
}
