import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/schedule.dart';
import '../repositories/schedule_repository.dart';

class GetSchedules {
  final ScheduleRepository repository;

  GetSchedules(this.repository);

  Future<Either<Failure, List<Schedule>>> execute() {
    return repository.getSchedules();
  }
}
