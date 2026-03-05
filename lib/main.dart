import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'features/scheduler/data/models/schedule_model.dart';
import 'features/scheduler/presentation/pages/home_page.dart';
import 'core/services/alarm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(ScheduleModelAdapter());
  await Hive.openBox<ScheduleModel>(AppConstants.hiveBoxSchedules);
  await Hive.openBox<ScheduleModel>(AppConstants.hiveBoxHistory);

  // Initialize background alarm manager
  await AlarmService.initialize();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomePage(),
    );
  }
}
