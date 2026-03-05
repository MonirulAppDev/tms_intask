import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/datasources/schedule_local_data_source.dart';
import '../../data/models/schedule_model.dart';
import '../../data/repositories/schedule_repository_impl.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../../domain/usecases/clear_history.dart';
import '../../domain/usecases/delete_schedule.dart';
import '../../domain/usecases/get_history.dart';
import '../../domain/usecases/get_schedules.dart';
import '../../domain/usecases/log_execution.dart';
import '../../domain/usecases/save_schedule.dart';

final scheduleBoxProvider = Provider<Box<ScheduleModel>>((ref) {
  return Hive.box<ScheduleModel>(AppConstants.hiveBoxSchedules);
});

final historyBoxProvider = Provider<Box<ScheduleModel>>((ref) {
  return Hive.box<ScheduleModel>(AppConstants.hiveBoxHistory);
});

final localDataSourceProvider = Provider<ScheduleLocalDataSource>((ref) {
  return ScheduleLocalDataSourceImpl(
    scheduleBox: ref.read(scheduleBoxProvider),
    historyBox: ref.read(historyBoxProvider),
  );
});

final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  return ScheduleRepositoryImpl(
    localDataSource: ref.read(localDataSourceProvider),
  );
});

final getSchedulesProvider = Provider<GetSchedules>((ref) {
  return GetSchedules(ref.read(scheduleRepositoryProvider));
});

final saveScheduleProvider = Provider<SaveSchedule>((ref) {
  return SaveSchedule(ref.read(scheduleRepositoryProvider));
});

final deleteScheduleProvider = Provider<DeleteSchedule>((ref) {
  return DeleteSchedule(ref.read(scheduleRepositoryProvider));
});

final getHistoryProvider = Provider<GetHistory>((ref) {
  return GetHistory(ref.read(scheduleRepositoryProvider));
});

final clearHistoryProvider = Provider<ClearHistory>((ref) {
  return ClearHistory(ref.read(scheduleRepositoryProvider));
});

final logExecutionProvider = Provider<LogExecution>((ref) {
  return LogExecution(ref.read(scheduleRepositoryProvider));
});
