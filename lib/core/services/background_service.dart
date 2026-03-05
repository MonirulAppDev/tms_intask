import 'package:device_apps/device_apps.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';
import 'alarm_service.dart';
import '../../features/scheduler/data/models/schedule_model.dart';
import 'package:uuid/uuid.dart';

class BackgroundService {
  @pragma('vm:entry-point')
  static Future<void> alarmCallback(int id, Map<String, dynamic> params) async {
    final String packageName = params['packageName'] as String;
    final String scheduleId = params['scheduleId'] as String;
    final String appName = params['appName'] as String;
    final String? label = params['label'] as String?;
    final int scheduledTimeMs = params['scheduledTime'] as int;

    // Launch app via DeviceApps
    bool success = false;
    try {
      success = await DeviceApps.openApp(packageName);
    } catch (_) {
      success = false;
    }

    // Initialize Hive in the background isolate
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ScheduleModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ScheduleFrequencyModelAdapter());
    }

    final schedulesBox = await Hive.openBox<ScheduleModel>(
      AppConstants.hiveBoxSchedules,
    );
    final historyBox = await Hive.openBox<ScheduleModel>(
      AppConstants.hiveBoxHistory,
    );

    // Get the schedule
    ScheduleModel? scheduleModel = schedulesBox.get(scheduleId);
    if (scheduleModel != null) {
      final frequency = scheduleModel.frequency ?? ScheduleFrequencyModel.once;
      if (frequency == ScheduleFrequencyModel.daily) {
        // Reschedule for next day
        final nextTime = scheduleModel.scheduledTime.add(
          const Duration(days: 1),
        );
        final updatedModel = ScheduleModel(
          id: scheduleModel.id,
          appName: scheduleModel.appName,
          packageName: scheduleModel.packageName,
          scheduledTime: nextTime,
          label: scheduleModel.label,
          frequency: scheduleModel.frequency,
          isEnabled: true,
          isExecuted: false,
        );
        await schedulesBox.put(scheduleId, updatedModel);

        // Also reschedule the alarm
        await AlarmService.scheduleAlarm(updatedModel.toEntity());
      } else {
        // Mark as executed and disabled if one-time
        final executedSchedule = ScheduleModel(
          id: scheduleModel.id,
          appName: scheduleModel.appName,
          packageName: scheduleModel.packageName,
          scheduledTime: scheduleModel.scheduledTime,
          label: scheduleModel.label,
          frequency: scheduleModel.frequency,
          isExecuted: true,
          isEnabled: false,
        );
        await schedulesBox.put(scheduleId, executedSchedule);
      }
    }

    // Log the history record
    final logId = const Uuid().v4();
    final historyRecord = ScheduleModel(
      id: logId,
      appName: appName,
      packageName: packageName,
      scheduledTime: DateTime.fromMillisecondsSinceEpoch(scheduledTimeMs),
      label: label,
      isExecuted: true,
      isEnabled:
          success, // We use this field in history to denote 'success' of launch.
    );
    await historyBox.put(logId, historyRecord);

    await schedulesBox.close();
    await historyBox.close();
  }
}
