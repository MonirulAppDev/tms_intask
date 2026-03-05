import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/schedule.dart';
import '../repositories/schedule_repository.dart';

class GetHistory {
  final ScheduleRepository repository;

  GetHistory(this.repository);

  Future<Either<Failure, List<Schedule>>> execute() {
    return repository.getHistory();
  }
}
