import 'dart:convert';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';

const _taskName = 'missioncontrol_health_check';
const _baseUrl = 'http://100.103.32.107:8000';
const _livePath = '/api/missioncontrol/home-lab/live';
const _healthPath = '/api/missioncontrol/home-lab/health';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName == _taskName) {
      await _checkHealth();
    }
    return true;
  });
}

Future<void> _checkHealth() async {
  try {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 15);

    final liveData = await _getJson(client, _livePath);
    final healthData = await _getJson(client, _healthPath);

    client.close();

    final heartbeats = (liveData['heartbeats'] as List?) ?? [];
    final checks = (liveData['service_checks'] as List?) ?? [];
    final score = (healthData['score'] as int?) ?? 100;

    final criticalSystems = heartbeats
        .where((h) => h['status'] == 'critical')
        .map((h) => h['system'] as String)
        .toList();
    final offlineServices = checks
        .where((s) => s['online'] == false)
        .map((s) => s['service'] as String)
        .toList();

    final issues = <String>[];
    if (score < 50) issues.add('Health Score: $score');
    if (criticalSystems.isNotEmpty) issues.add('Offline: ${criticalSystems.join(', ')}');
    if (offlineServices.isNotEmpty) issues.add('Services down: ${offlineServices.join(', ')}');

    if (issues.isNotEmpty) {
      final notifications = FlutterLocalNotificationsPlugin();
      await notifications.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@android:drawable/ic_dialog_info'),
        ),
      );
      await notifications.show(
        0,
        'Mission Control Alert',
        issues.join('\n'),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'missioncontrol_critical',
            'Critical Alerts',
            channelDescription: 'Health check failures',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    }
  } catch (_) {}
}

Future<Map<String, dynamic>> _getJson(HttpClient client, String path) async {
  final request = await client.getUrl(Uri.parse('$_baseUrl$path'));
  final response = await request.close();
  final body = await response.transform(utf8.decoder).join();
  return json.decode(body) as Map<String, dynamic>;
}
