import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/schedule.dart';
import 'domain_providers.dart';
import '../../../../core/services/alarm_service.dart';

class ScheduleState {
  final List<Schedule> schedules;
  final bool isLoading;
  final String? error;

  ScheduleState({
    this.schedules = const [],
    this.isLoading = false,
    this.error,
  });

  ScheduleState copyWith({
    List<Schedule>? schedules,
    bool? isLoading,
    String? error,
  }) {
    return ScheduleState(
      schedules: schedules ?? this.schedules,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ScheduleNotifier extends StateNotifier<ScheduleState> {
  final Ref ref;

  ScheduleNotifier(this.ref) : super(ScheduleState()) {
    loadSchedules();
  }

  Future<void> loadSchedules() async {
    state = state.copyWith(isLoading: true, error: null);
    final usecase = ref.read(getSchedulesProvider);
    final result = await usecase.execute();

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (schedules) {
        // Sort by upcoming time
        schedules.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
        state = state.copyWith(
          isLoading: false,
          schedules: schedules,
          error: null,
        );
      },
    );
  }

  Future<bool> addSchedule(Schedule schedule) async {
    state = state.copyWith(isLoading: true, error: null);

    // Check time
    if (schedule.frequency == ScheduleFrequency.once &&
        schedule.scheduledTime.isBefore(DateTime.now())) {
      state = state.copyWith(
        isLoading: false,
        error: 'Cannot schedule in the past.',
      );
      return false;
    }

    Schedule? conflictingSchedule;
    final hasConflict = state.schedules.any((existing) {
      if (existing.id == schedule.id) return false;
      if (existing.isExecuted || !existing.isEnabled) return false;

      final eTime = existing.scheduledTime;
      final sTime = schedule.scheduledTime;
      final sameTime = eTime.hour == sTime.hour && eTime.minute == sTime.minute;

      bool conflict = false;
      if (schedule.frequency == ScheduleFrequency.daily ||
          existing.frequency == ScheduleFrequency.daily) {
        conflict = sameTime;
      } else {
        conflict =
            sameTime &&
            eTime.year == sTime.year &&
            eTime.month == sTime.month &&
            eTime.day == sTime.day;
      }

      if (conflict) {
        conflictingSchedule = existing;
        return true;
      }
      return false;
    });

    if (hasConflict && conflictingSchedule != null) {
      final timeStr = DateFormat.jm().format(
        conflictingSchedule!.scheduledTime,
      );
      state = state.copyWith(
        isLoading: false,
        error:
            'Conflict: Another schedule exists at $timeStr (${conflictingSchedule!.appName})',
      );
      return false;
    }

    final usecase = ref.read(saveScheduleProvider);
    final result = await usecase.execute(schedule);

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (_) async {
        // Schedule Android Alarm
        await AlarmService.scheduleAlarm(schedule);
        await loadSchedules();
        return true;
      },
    );
  }

  Future<void> deleteSchedule(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    final usecase = ref.read(deleteScheduleProvider);
    final result = await usecase.execute(id);

    await result.fold(
      (failure) async =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (_) async {
        await AlarmService.cancelAlarm(id);
        await loadSchedules();
      },
    );
  }
}

final scheduleNotifierProvider =
    StateNotifierProvider<ScheduleNotifier, ScheduleState>((ref) {
      return ScheduleNotifier(ref);
    });
