import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/schedule.dart';
import '../repositories/schedule_repository.dart';

class LogExecution {
  final ScheduleRepository repository;

  LogExecution(this.repository);

  Future<Either<Failure, void>> execute(Schedule schedule, bool success) {
    return repository.logExecution(schedule, success);
  }
}
