import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_apps/device_apps.dart';

final installedAppsProvider = FutureProvider<List<Application>>((ref) async {
  List<Application> apps = await DeviceApps.getInstalledApplications(
    includeAppIcons: true,
    includeSystemApps: false,
    onlyAppsWithLaunchIntent: true,
  );

  apps.sort(
    (a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()),
  );
  return apps;
});

final appsSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredAppsProvider = Provider<AsyncValue<List<Application>>>((ref) {
  final appsAsyncValue = ref.watch(installedAppsProvider);
  final searchQuery = ref.watch(appsSearchQueryProvider).toLowerCase();

  return appsAsyncValue.whenData((apps) {
    if (searchQuery.isEmpty) return apps;
    return apps
        .where((app) => app.appName.toLowerCase().contains(searchQuery))
        .toList();
  });
});
