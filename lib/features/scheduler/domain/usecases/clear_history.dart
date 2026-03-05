import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/schedule_repository.dart';

class ClearHistory {
  final ScheduleRepository repository;

  ClearHistory(this.repository);

  Future<Either<Failure, void>> execute() {
    return repository.clearHistory();
  }
}
