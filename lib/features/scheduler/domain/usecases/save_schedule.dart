import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/schedule.dart';
import '../repositories/schedule_repository.dart';

class SaveSchedule {
  final ScheduleRepository repository;

  SaveSchedule(this.repository);

  Future<Either<Failure, void>> execute(Schedule schedule) {
    return repository.saveSchedule(schedule);
  }
}
