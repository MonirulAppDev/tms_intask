import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:app_scheduler/features/scheduler/domain/entities/schedule.dart';
import 'package:app_scheduler/features/scheduler/domain/repositories/schedule_repository.dart';
import 'package:app_scheduler/features/scheduler/domain/usecases/save_schedule.dart';
import 'package:app_scheduler/core/error/failures.dart';

class MockScheduleRepository extends Mock implements ScheduleRepository {}

class FakeSchedule extends Fake implements Schedule {}

void main() {
  late SaveSchedule usecase;
  late MockScheduleRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeSchedule());
  });

  setUp(() {
    mockRepository = MockScheduleRepository();
    usecase = SaveSchedule(mockRepository);
  });

  final tSchedule = Schedule(
    id: '1',
    appName: 'Test App',
    packageName: 'com.test.app',
    scheduledTime: DateTime(2025, 1, 1),
  );

  test('should save schedule to the repository', () async {
    // arrange
    when(
      () => mockRepository.saveSchedule(any()),
    ).thenAnswer((_) async => const Right(null));

    // act
    final result = await usecase.execute(tSchedule);

    // assert
    expect(result, const Right(null));
    verify(() => mockRepository.saveSchedule(tSchedule));
    verifyNoMoreInteractions(mockRepository);
  });

  test(
    'should return ConflictFailure when saving duplicate schedule',
    () async {
      // arrange
      const tFailure = ConflictFailure('Conflict detected');
      when(
        () => mockRepository.saveSchedule(any()),
      ).thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase.execute(tSchedule);

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.saveSchedule(tSchedule));
      verifyNoMoreInteractions(mockRepository);
    },
  );
}
