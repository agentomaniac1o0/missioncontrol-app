import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'app.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!Platform.isAndroid) {
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
