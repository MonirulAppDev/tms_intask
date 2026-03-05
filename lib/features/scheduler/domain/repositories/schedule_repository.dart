import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/schedule.dart';

abstract class ScheduleRepository {
  Future<Either<Failure, List<Schedule>>> getSchedules();
  Future<Either<Failure, void>> saveSchedule(Schedule schedule);
  Future<Either<Failure, void>> deleteSchedule(String id);
  Future<Either<Failure, List<Schedule>>> getHistory();
  Future<Either<Failure, void>> clearHistory();
  Future<Either<Failure, void>> logExecution(Schedule schedule, bool success);
}
