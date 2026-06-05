import 'package:flutter/foundation.dart';

class MissioncontrolOverview {
  final String status;
  final DateTime lastReport;
  final int healthScore;
  final Map<String, double> diskUsage;
  final String crewStatus;
  final List<String> activeAlerts;

  const MissioncontrolOverview({
    required this.status,
    required this.lastReport,
    required this.healthScore,
    required this.diskUsage,
    required this.crewStatus,
    required this.activeAlerts,
  });

  factory MissioncontrolOverview.fromJson(Map<String, dynamic> json) {
    DateTime parsedReport;
    try {
      parsedReport = DateTime.parse(json['last_report'] as String);
    } catch (e) {
      debugPrint('Overview timestamp parse failed: $e');
      parsedReport = DateTime.now();
    }
    return MissioncontrolOverview(
      status: json['status'] as String? ?? 'unknown',
      lastReport: parsedReport,
      healthScore: json['health_score'] as int? ?? 0,
      diskUsage: (json['disk_usage'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, (v as num).toDouble()),
          ) ??
          {},
      crewStatus: json['crew_status'] as String? ?? 'unknown',
      activeAlerts: (json['active_alerts'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

}
