class ServiceHistoryPoint {
  final String timestamp;
  final int responseTimeMs;
  final bool online;

  const ServiceHistoryPoint({
    required this.timestamp,
    required this.responseTimeMs,
    required this.online,
  });

  factory ServiceHistoryPoint.fromJson(Map<String, dynamic> json) {
    return ServiceHistoryPoint(
      timestamp: json['timestamp'] as String? ?? '',
      responseTimeMs: json['response_time_ms'] as int? ?? 0,
      online: json['online'] as bool? ?? false,
    );
  }
}

class ServiceHistorySeries {
  final String name;
  final String host;
  final int port;
  final List<ServiceHistoryPoint> history;

  const ServiceHistorySeries({
    required this.name,
    required this.host,
    required this.port,
    required this.history,
  });

  factory ServiceHistorySeries.fromJson(Map<String, dynamic> json) {
    return ServiceHistorySeries(
      name: json['name'] as String? ?? '',
      host: json['host'] as String? ?? '',
      port: json['port'] as int? ?? 0,
      history: (json['history'] as List<dynamic>?)
              ?.map((e) =>
                  ServiceHistoryPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  int get avgMs =>
      history.isEmpty ? 0 : (history.map((h) => h.responseTimeMs).reduce((a, b) => a + b) ~/ history.length);

  int get maxMs =>
      history.isEmpty ? 0 : history.map((h) => h.responseTimeMs).reduce((a, b) => a > b ? a : b);

  bool get isOnline => history.isNotEmpty && history.last.online;
}

class ServiceHistoryResponse {
  final List<ServiceHistorySeries> services;
  final String collectedAt;

  const ServiceHistoryResponse({
    required this.services,
    required this.collectedAt,
  });

  factory ServiceHistoryResponse.fromJson(Map<String, dynamic> json) {
    return ServiceHistoryResponse(
      services: (json['services'] as List<dynamic>?)
              ?.map((e) =>
                  ServiceHistorySeries.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      collectedAt: json['collected_at'] as String? ?? '',
    );
  }
}
