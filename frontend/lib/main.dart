import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:workmanager/workmanager.dart';
import 'app.dart';
import 'services/notification_service.dart';
import 'services/workmanager_service.dart';

const _taskName = 'missioncontrol_health_check';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
    await Workmanager().registerPeriodicTask(
      _taskName,
      _taskName,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  } else {
    try {
      await initNotifications();
      HealthCheckPoller(Dio()).start('home-lab');
    } catch (_) {}
  }

  runApp(
    const ProviderScope(
      child: MissionControlApp(),
    ),
  );
}
