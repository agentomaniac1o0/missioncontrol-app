import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'app.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initNotifications();

  final poller = HealthCheckPoller(Dio());

  if (!Platform.isAndroid) {
    poller.start('home-lab');
  }

  runApp(
    const ProviderScope(
      child: MissionControlApp(),
    ),
  );
}
