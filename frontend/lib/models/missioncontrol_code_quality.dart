class Finding {
  final String severity;
  final String title;
  final String description;
  final bool autoFixed;

  const Finding({
    required this.severity,
    required this.title,
    required this.description,
    required this.autoFixed,
  });

  factory Finding.fromJson(Map<String, dynamic> json) {
    return Finding(
      severity: json['severity'] as String? ?? 'info',
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      autoFixed: json['auto_fixed'] as bool? ?? false,
    );
  }
}

class OpenPort {
  final int port;
  final String service;
  final bool expected;

  const OpenPort({
    required this.port,
    required this.service,
    required this.expected,
  });

  factory OpenPort.fromJson(Map<String, dynamic> json) {
    return OpenPort(
      port: json['port'] as int,
      service: json['service'] as String? ?? '',
      expected: json['expected'] as bool? ?? true,
    );
  }
}

class MissioncontrolCodeQuality {
  final List<Finding> findings;
  final List<OpenPort> openPorts;
  final int hardcodedSecrets;
  final int bareExcepts;
  final List<String> autoFixResults;

  const MissioncontrolCodeQuality({
    required this.findings,
    required this.openPorts,
    required this.hardcodedSecrets,
    required this.bareExcepts,
    required this.autoFixResults,
  });

  factory MissioncontrolCodeQuality.fromJson(Map<String, dynamic> json) {
    return MissioncontrolCodeQuality(
      findings: (json['findings'] as List<dynamic>?)
              ?.map((e) => Finding.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      openPorts: (json['open_ports'] as List<dynamic>?)
              ?.map((e) => OpenPort.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      hardcodedSecrets: json['hardcoded_secrets'] as int? ?? 0,
      bareExcepts: json['bare_excepts'] as int? ?? 0,
      autoFixResults: (json['auto_fix_results'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  factory MissioncontrolCodeQuality.placeholder() {
    return const MissioncontrolCodeQuality(
      findings: [],
      openPorts: [],
      hardcodedSecrets: 0,
      bareExcepts: 0,
      autoFixResults: [],
    );
  }
}
