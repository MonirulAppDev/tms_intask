import 'package:hive/hive.dart';
import '../../domain/entities/schedule.dart';

part 'schedule_model.g.dart';

@HiveType(typeId: 1)
enum ScheduleFrequencyModel {
  @HiveField(0)
  once,
  @HiveField(1)
  daily,
}

@HiveType(typeId: 0)
class ScheduleModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String appName;

  @HiveField(2)
  final String packageName;

  @HiveField(3)
  final DateTime scheduledTime;

  @HiveField(4)
  final String? label;

  @HiveField(5)
  final bool isExecuted;

  @HiveField(6)
  final bool isEnabled;

  @HiveField(7)
  final ScheduleFrequencyModel? frequency;

  ScheduleModel({
    required this.id,
    required this.appName,
    required this.packageName,
    required this.scheduledTime,
    this.label,
    this.isExecuted = false,
    this.isEnabled = true,
    this.frequency,
  });

  factory ScheduleModel.fromEntity(Schedule entity) {
    return ScheduleModel(
      id: entity.id,
      appName: entity.appName,
      packageName: entity.packageName,
      scheduledTime: entity.scheduledTime,
      label: entity.label,
      isExecuted: entity.isExecuted,
      isEnabled: entity.isEnabled,
      frequency: ScheduleFrequencyModel.values.byName(entity.frequency.name),
    );
  }

  Schedule toEntity() {
    return Schedule(
      id: id,
      appName: appName,
      packageName: packageName,
      scheduledTime: scheduledTime,
      label: label,
      isExecuted: isExecuted,
      isEnabled: isEnabled,
      frequency: frequency != null
          ? ScheduleFrequency.values.byName(frequency!.name)
          : ScheduleFrequency.once,
    );
  }
}
