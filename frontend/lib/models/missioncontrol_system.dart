class VmStatus {
  final String name;
  final String status;
  final double cpuPercent;
  final double ramPercent;
  final double diskPercent;
  final int uptimeDays;

  const VmStatus({
    required this.name,
    required this.status,
    required this.cpuPercent,
    required this.ramPercent,
    required this.diskPercent,
    required this.uptimeDays,
  });

  factory VmStatus.fromJson(Map<String, dynamic> json) {
    return VmStatus(
      name: json['name'] as String,
      status: json['status'] as String? ?? 'unknown',
      cpuPercent: (json['cpu_percent'] as num?)?.toDouble() ?? 0,
      ramPercent: (json['ram_percent'] as num?)?.toDouble() ?? 0,
      diskPercent: (json['disk_percent'] as num?)?.toDouble() ?? 0,
      uptimeDays: json['uptime_days'] as int? ?? 0,
    );
  }
}

class ServiceStatus {
  final String name;
  final bool online;
  final int port;
  final String host;

  const ServiceStatus({
    required this.name,
    required this.online,
    required this.port,
    this.host = '',
  });

  factory ServiceStatus.fromJson(Map<String, dynamic> json) {
    return ServiceStatus(
      name: json['name'] as String,
      online: json['online'] as bool? ?? false,
      port: json['port'] as int? ?? 0,
      host: json['host'] as String? ?? '',
    );
  }
}

class ProxmoxHost {
  final double cpuPercent;
  final double ramPercent;
  final String uptime;
  final String kernelVersion;
  final bool updatesPending;

  const ProxmoxHost({
    required this.cpuPercent,
    required this.ramPercent,
    required this.uptime,
    required this.kernelVersion,
    required this.updatesPending,
  });

  factory ProxmoxHost.fromJson(Map<String, dynamic> json) {
    return ProxmoxHost(
      cpuPercent: (json['cpu_percent'] as num?)?.toDouble() ?? 0,
      ramPercent: (json['ram_percent'] as num?)?.toDouble() ?? 0,
      uptime: json['uptime'] as String? ?? '',
      kernelVersion: json['kernel_version'] as String? ?? '',
      updatesPending: json['updates_pending'] as bool? ?? false,
    );
  }
}

class BackupStatus {
  final String vmName;
  final DateTime lastBackup;
  final bool success;
  final String detail;

  const BackupStatus({
    required this.vmName,
    required this.lastBackup,
    required this.success,
    required this.detail,
  });

  factory BackupStatus.fromJson(Map<String, dynamic> json) {
    DateTime parsedBackup;
    try {
      parsedBackup = DateTime.parse(json['last_backup'] as String);
    } catch (_) {
      parsedBackup = DateTime.now();
    }
    return BackupStatus(
      vmName: json['vm_name'] as String? ?? '',
      lastBackup: parsedBackup,
      success: json['success'] as bool? ?? false,
      detail: json['detail'] as String? ?? '',
    );
  }
}

class SysUpdate {
  final String system;
  final int updatesPending;
  final bool rebootNeeded;
  final String kernel;
  final List<String> autoFixes;
  final List<String> warnings;
  final List<String> details;

  const SysUpdate({
    required this.system,
    required this.updatesPending,
    required this.rebootNeeded,
    required this.kernel,
    required this.autoFixes,
    required this.warnings,
    required this.details,
  });

  factory SysUpdate.fromJson(Map<String, dynamic> json) {
    return SysUpdate(
      system: json['system'] as String? ?? '',
      updatesPending: json['updates_pending'] as int? ?? 0,
      rebootNeeded: json['reboot_needed'] as bool? ?? false,
      kernel: json['kernel'] as String? ?? '',
      autoFixes: (json['auto_fixes'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      warnings: (json['warnings'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      details: (json['details'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    );
  }
}

class MissioncontrolSystem {
  final ProxmoxHost host;
  final List<VmStatus> vms;
  final List<ServiceStatus> services;
  final List<BackupStatus> backups;
  final List<SysUpdate> updates;

  const MissioncontrolSystem({
    required this.host,
    required this.vms,
    required this.services,
    required this.backups,
    required this.updates,
  });

  factory MissioncontrolSystem.fromJson(Map<String, dynamic> json) {
    return MissioncontrolSystem(
      host: ProxmoxHost.fromJson(json['host'] as Map<String, dynamic>? ?? {}),
      vms: (json['vms'] as List<dynamic>?)
              ?.map((e) => VmStatus.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      services: (json['services'] as List<dynamic>?)
              ?.map((e) => ServiceStatus.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      backups: (json['backups'] as List<dynamic>?)
              ?.map((e) => BackupStatus.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      updates: (json['updates'] as List<dynamic>?)
              ?.map((e) => SysUpdate.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  factory MissioncontrolSystem.placeholder() {
    return const MissioncontrolSystem(
      host: ProxmoxHost(
        cpuPercent: 0,
        ramPercent: 0,
        uptime: '',
        kernelVersion: '',
        updatesPending: false,
      ),
      vms: [],
      services: [],
      backups: [],
      updates: [],
    );
  }
}
