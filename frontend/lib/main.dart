import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'app.dart';
import 'config/api_config.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (ApiConfig.baseUrl.isEmpty) {
    debugPrint('ERROR: API_BASE_URL not set. Pass --dart-define=API_BASE_URL=http://HOST:PORT');
  }

  if (!Platform.isAndroid) {
    try {
      await initNotifications();
      HealthCheckPoller(Dio()).start('home-lab');
    } catch (e) {
      debugPrint('Notification/poller init failed: $e');
    }
  }

  runApp(
    const ProviderScope(
      child: MissionControlApp(),
    ),
  );
}
