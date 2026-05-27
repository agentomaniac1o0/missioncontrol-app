import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:workmanager/workmanager.dart';
import 'app.dart';
import 'services/notification_service.dart';

const _taskName = 'missioncontrol_health_check';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName == _taskName) {
      final dio = Dio();
      final poller = HealthCheckPoller(dio);
      await poller.checkOnce('home-lab');
    }
    return true;
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await initNotifications();
  } catch (_) {}

  try {
    if (Platform.isAndroid) {
      await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
      await Workmanager().registerPeriodicTask(
        _taskName,
        _taskName,
        frequency: const Duration(minutes: 15),
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
      );
    } else {
      final poller = HealthCheckPoller(Dio());
      poller.start('home-lab');
    }
  } catch (_) {}

  runApp(
    const ProviderScope(
      child: MissionControlApp(),
    ),
  );
}
