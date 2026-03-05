import 'package:hive/hive.dart';
import '../../../../core/error/exceptions.dart';
import '../models/schedule_model.dart';
import 'package:uuid/uuid.dart';

abstract class ScheduleLocalDataSource {
  Future<List<ScheduleModel>> getSchedules();
  Future<void> saveSchedule(ScheduleModel schedule);
  Future<void> deleteSchedule(String id);
  Future<List<ScheduleModel>> getHistory();
  Future<void> clearHistory();
  Future<void> logExecution(ScheduleModel schedule, bool success);
}

class ScheduleLocalDataSourceImpl implements ScheduleLocalDataSource {
  final Box<ScheduleModel> scheduleBox;
  final Box<ScheduleModel> historyBox;

  ScheduleLocalDataSourceImpl({
    required this.scheduleBox,
    required this.historyBox,
  });

  @override
  Future<List<ScheduleModel>> getSchedules() async {
    try {
      return scheduleBox.values.toList();
    } catch (e) {
      throw CacheException(message: 'Failed to get schedules');
    }
  }

  @override
  Future<void> saveSchedule(ScheduleModel schedule) async {
    try {
      // Conflict detection logic
      final existingSchedules = scheduleBox.values.toList();
      for (var s in existingSchedules) {
        if (s.id != schedule.id &&
            s.scheduledTime.isAtSameMomentAs(schedule.scheduledTime)) {
          throw ConflictException(
            message: 'Another schedule already exists at this exact time.',
          );
        }
      }

      await scheduleBox.put(schedule.id, schedule);
    } on ConflictException {
      rethrow;
    } catch (e) {
      throw CacheException(message: 'Failed to save schedule');
    }
  }

  @override
  Future<void> deleteSchedule(String id) async {
    try {
      await scheduleBox.delete(id);
    } catch (e) {
      throw CacheException(message: 'Failed to delete schedule');
    }
  }

  @override
  Future<List<ScheduleModel>> getHistory() async {
    try {
      return historyBox.values.toList();
    } catch (e) {
      throw CacheException(message: 'Failed to get history');
    }
  }

  @override
  Future<void> clearHistory() async {
    try {
      await historyBox.clear();
    } catch (e) {
      throw CacheException(message: 'Failed to clear history');
    }
  }

  @override
  Future<void> logExecution(ScheduleModel schedule, bool success) async {
    try {
      final logId = const Uuid().v4();
      final historyRecord = ScheduleModel(
        id: logId,
        appName: schedule.appName,
        packageName: schedule.packageName,
        scheduledTime: schedule.scheduledTime,
        label: schedule.label,
        isExecuted: true,
        isEnabled:
            success, // We can reuse isEnabled to represent success in history simply, or add a field.
      );

      await historyBox.put(logId, historyRecord);
    } catch (e) {
      throw CacheException(message: 'Failed to log execution');
    }
  }
}
