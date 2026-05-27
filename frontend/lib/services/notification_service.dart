import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../config/theme.dart';

final _notifications = FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const linuxSettings = LinuxInitializationSettings(defaultActionName: 'Open');
  const initSettings = InitializationSettings(
    android: androidSettings,
    linux: linuxSettings,
  );
  await _notifications.initialize(initSettings);
}

Future<void> showCriticalNotification(String title, String body) async {
  const androidDetails = AndroidNotificationDetails(
    'missioncontrol_critical',
    'Critical Alerts',
    channelDescription: 'Health check failures and critical issues',
    importance: Importance.high,
    priority: Priority.high,
    color: AppTheme.red,
  );
  const details = NotificationDetails(android: androidDetails);
  await _notifications.show(0, title, body, details);
}

class HealthCheckPoller {
  final Dio _dio;
  Timer? _timer;

  HealthCheckPoller(this._dio);

  void start(String location) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 5), (_) {
      _check(location);
    });
    _check(location);
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _check(String location) async {
    try {
      final issues = await checkOnce(location);
      if (issues.isNotEmpty) {
        await showCriticalNotification('Mission Control Alert', issues.join('\n'));
      }
    } catch (_) {}
  }

  Future<List<String>> checkOnce(String location) async {
    final issues = <String>[];
    try {
      final liveResp = await _dio.get(ApiConfig.liveUrl(location));
      final healthResp = await _dio.get(ApiConfig.healthUrl(location));

      final heartbeats = (liveResp.data as Map)['heartbeats'] as List? ?? [];
      final checks = (liveResp.data as Map)['service_checks'] as List? ?? [];
      final score = (healthResp.data as Map)['score'] as int? ?? 100;

      final criticalSystems =
          heartbeats.where((h) => h['status'] == 'critical').map((h) => h['system']).toList();
      final offlineServices =
          checks.where((s) => s['online'] == false).map((s) => s['service']).toList();

      if (score < 50) issues.add('Health Score: $score');
      if (criticalSystems.isNotEmpty) issues.add('Offline: ${criticalSystems.join(', ')}');
      if (offlineServices.isNotEmpty) issues.add('Services down: ${offlineServices.join(', ')}');
    } catch (_) {}
    return issues;
  }
}
