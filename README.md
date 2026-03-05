# App Scheduler

A production-ready Flutter application built using Clean Architecture and Riverpod. 
App Scheduler allows users to schedule installed Android applications to automatically launch at a designated future time.

## Architecture

The application strictly adheres to Clean Architecture principles:
- **Presentation Layer**: UI, Widgets, and Riverpod StateNotifiers.
- **Domain Layer**: Core Business Logic, Entities, and Repository Interfaces.
- **Data Layer**: API/Local Implementations using Hive, `device_apps`, and `android_alarm_manager_plus`.

## Key Features
- **App Discovery**: View all installed apps and search through them quickly.
- **Scheduling**: Schedule any app to launch automatically at a specified date and time in the future. Conflict detection is supported.
- **Schedule Management**: View upcoming schedules and delete them if you change your mind.
- **Execution History**: View the historical logs of previously executed scheduled apps.
- **Background Execution**: Works seamlessly in the background utilizing Android's AlarmManager, even if the flutter application is completely killed.

## Dependencies highlights
- `flutter_riverpod` & `riverpod_annotation`
- `hive` & `hive_flutter`
- `device_apps`
- `android_alarm_manager_plus`
- `dartz`
- `equatable`

## Installation
1. Clone the repository.
2. Run `flutter pub get`
3. Make sure you are testing on an Android Device or Emulator.
4. Run `flutter run`.

### Permissions Note
Since Android 12+, scheduling exact alarms requires the `SCHEDULE_EXACT_ALARM` and `USE_EXACT_ALARM` permissions. This app seamlessly hooks into Android's native alarms. If permissions are restricted on some custom OS versions, make sure to allow the app to run in the background.

## Known Limitations
- The application currently supports Android only since it relies on native Android App Intents and Android Alarm Manager.
