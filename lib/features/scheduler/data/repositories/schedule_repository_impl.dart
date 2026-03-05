import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/schedule.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../datasources/schedule_local_data_source.dart';
import '../models/schedule_model.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  final ScheduleLocalDataSource localDataSource;

  ScheduleRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Schedule>>> getSchedules() async {
    try {
      final models = await localDataSource.getSchedules();
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return const Left(UnknownFailure('Unknown error occurred'));
    }
  }

  @override
  Future<Either<Failure, void>> saveSchedule(Schedule schedule) async {
    try {
      final model = ScheduleModel.fromEntity(schedule);
      await localDataSource.saveSchedule(model);
      return const Right(null);
    } on ConflictException catch (e) {
      return Left(ConflictFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return const Left(UnknownFailure('Unknown error occurred'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSchedule(String id) async {
    try {
      await localDataSource.deleteSchedule(id);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return const Left(UnknownFailure('Unknown error occurred'));
    }
  }

  @override
  Future<Either<Failure, List<Schedule>>> getHistory() async {
    try {
      final models = await localDataSource.getHistory();
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return const Left(UnknownFailure('Unknown error occurred'));
    }
  }

  @override
  Future<Either<Failure, void>> clearHistory() async {
    try {
      await localDataSource.clearHistory();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return const Left(UnknownFailure('Unknown error occurred'));
    }
  }

  @override
  Future<Either<Failure, void>> logExecution(
    Schedule schedule,
    bool success,
  ) async {
    try {
      final model = ScheduleModel.fromEntity(schedule);
      await localDataSource.logExecution(model, success);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return const Left(UnknownFailure('Unknown error occurred'));
    }
  }
}
