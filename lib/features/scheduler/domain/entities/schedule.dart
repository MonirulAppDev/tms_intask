import 'package:equatable/equatable.dart';

enum ScheduleFrequency { once, daily }

class Schedule extends Equatable {
  final String id;
  final String appName;
  final String packageName;
  final DateTime scheduledTime;
  final String? label;
  final bool isExecuted;
  final bool isEnabled;
  final ScheduleFrequency frequency;

  const Schedule({
    required this.id,
    required this.appName,
    required this.packageName,
    required this.scheduledTime,
    this.label,
    this.isExecuted = false,
    this.isEnabled = true,
    this.frequency = ScheduleFrequency.once,
  });

  Schedule copyWith({
    String? id,
    String? appName,
    String? packageName,
    DateTime? scheduledTime,
    String? label,
    bool? isExecuted,
    bool? isEnabled,
    ScheduleFrequency? frequency,
  }) {
    return Schedule(
      id: id ?? this.id,
      appName: appName ?? this.appName,
      packageName: packageName ?? this.packageName,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      label: label ?? this.label,
      isExecuted: isExecuted ?? this.isExecuted,
      isEnabled: isEnabled ?? this.isEnabled,
      frequency: frequency ?? this.frequency,
    );
  }

  @override
  List<Object?> get props => [
    id,
    appName,
    packageName,
    scheduledTime,
    label,
    isExecuted,
    isEnabled,
    frequency,
  ];
}
