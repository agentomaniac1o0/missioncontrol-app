class MissioncontrolHealth {
  final int score;
  final String level;
  final double vmHealth;
  final double serviceHealth;
  final double auditHealth;
  final DateTime calculatedAt;

  const MissioncontrolHealth({
    required this.score,
    required this.level,
    required this.vmHealth,
    required this.serviceHealth,
    required this.auditHealth,
    required this.calculatedAt,
  });

  factory MissioncontrolHealth.fromJson(Map<String, dynamic> json) {
    return MissioncontrolHealth(
      score: json['score'] as int? ?? 0,
      level: json['level'] as String? ?? 'unknown',
      vmHealth: (json['vm_health'] as num?)?.toDouble() ?? 0,
      serviceHealth: (json['service_health'] as num?)?.toDouble() ?? 0,
      auditHealth: (json['audit_health'] as num?)?.toDouble() ?? 0,
      calculatedAt: json['calculated_at'] != null
          ? DateTime.parse(json['calculated_at'] as String)
          : DateTime.now(),
    );
  }
}
