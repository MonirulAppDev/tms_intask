import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:app_scheduler/features/scheduler/domain/entities/schedule.dart';
import 'package:app_scheduler/features/scheduler/domain/repositories/schedule_repository.dart';
import 'package:app_scheduler/features/scheduler/domain/usecases/get_schedules.dart';

class MockScheduleRepository extends Mock implements ScheduleRepository {}

void main() {
  late GetSchedules usecase;
  late MockScheduleRepository mockRepository;

  setUp(() {
    mockRepository = MockScheduleRepository();
    usecase = GetSchedules(mockRepository);
  });

  final tSchedules = [
    Schedule(
      id: '1',
      appName: 'Test App',
      packageName: 'com.test.app',
      scheduledTime: DateTime(2025, 1, 1),
    ),
  ];

  test('should get schedules from the repository', () async {
    // arrange
    when(
      () => mockRepository.getSchedules(),
    ).thenAnswer((_) async => Right(tSchedules));

    // act
    final result = await usecase.execute();

    // assert
    expect(result, Right(tSchedules));
    verify(() => mockRepository.getSchedules());
    verifyNoMoreInteractions(mockRepository);
  });
}
