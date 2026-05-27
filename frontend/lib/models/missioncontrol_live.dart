class MissioncontrolLive {
  final List<LiveHeartbeat> heartbeats;
  final List<LiveServiceCheck> serviceChecks;
  final DateTime timestamp;

  const MissioncontrolLive({
    required this.heartbeats,
    required this.serviceChecks,
    required this.timestamp,
  });

  factory MissioncontrolLive.fromJson(Map<String, dynamic> json) {
    return MissioncontrolLive(
      heartbeats: (json['heartbeats'] as List<dynamic>?)
              ?.map((e) => LiveHeartbeat.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      serviceChecks: (json['service_checks'] as List<dynamic>?)
              ?.map(
                  (e) => LiveServiceCheck.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  bool get hasCritical =>
      heartbeats.any((h) => h.status == 'critical') ||
      serviceChecks.any((s) => !s.online);
}

class LiveHeartbeat {
  final String system;
  final String status;

  const LiveHeartbeat({required this.system, required this.status});

  factory LiveHeartbeat.fromJson(Map<String, dynamic> json) {
    return LiveHeartbeat(
      system: json['system'] as String,
      status: json['status'] as String? ?? 'unknown',
    );
  }
}

class LiveServiceCheck {
  final String service;
  final bool online;
  final int responseTimeMs;

  const LiveServiceCheck({
    required this.service,
    required this.online,
    required this.responseTimeMs,
  });

  factory LiveServiceCheck.fromJson(Map<String, dynamic> json) {
    return LiveServiceCheck(
      service: json['service'] as String,
      online: json['online'] as bool? ?? false,
      responseTimeMs: json['response_time_ms'] as int? ?? 0,
    );
  }
}

class LiveCriticalCount {
  final int heartbeatCritical;
  final int servicesOffline;
  final int total;

  const LiveCriticalCount({
    required this.heartbeatCritical,
    required this.servicesOffline,
    required this.total,
  });

  factory LiveCriticalCount.fromJson(Map<String, dynamic> json) {
    return LiveCriticalCount(
      heartbeatCritical: json['heartbeat_critical'] as int? ?? 0,
      servicesOffline: json['services_offline'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
    );
  }
}

class HealthTrendPoint {
  final String date;
  final int score;

  const HealthTrendPoint({required this.date, required this.score});

  factory HealthTrendPoint.fromJson(Map<String, dynamic> json) {
    return HealthTrendPoint(
      date: json['date'] as String? ?? '',
      score: json['score'] as int? ?? 0,
    );
  }
}
