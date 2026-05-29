import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../models/missioncontrol_system.dart';
import '../providers/missioncontrol_provider.dart';
import '../widgets/health_dot.dart';
import '../widgets/refresh_badge.dart';
import '../widgets/vm_detail_card.dart';

class SystemPage extends ConsumerWidget {
  const SystemPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = ref.watch(locationProvider);
    final systemAsync = ref.watch(missioncontrollerSystemProvider(location));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(missioncontrollerSystemProvider(location));
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHostSection(systemAsync),
          const SizedBox(height: 12),
          _buildVmSection(systemAsync),
          const SizedBox(height: 12),
          _buildServiceSection(systemAsync),
          const SizedBox(height: 12),
          _buildBackupSection(systemAsync),
          const SizedBox(height: 12),
          _buildUpdateSection(systemAsync),
        ],
      ),
    );
  }

  Widget _buildHostSection(AsyncValue async) {
    return async.when(
      data: (system) {
        final host = system.host;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(title: 'Proxmox Host', frequency: RefreshFrequency.daily, lastReport: system.lastReport),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _gaugeChart('CPU', host.cpuPercent, AppTheme.blue)),
                    Expanded(child: _gaugeChart('RAM', host.ramPercent, AppTheme.gold)),
                  ],
                ),
                const SizedBox(height: 12),
                _infoRow('Uptime', host.uptime),
                _infoRow('Kernel', host.kernelVersion),
                _infoRow('Updates', host.updatesPending ? 'pending' : 'up-to-date'),
              ],
            ),
          ),
        );
      },
      loading: () => const Card(child: SizedBox(height: 160, child: Center(child: CircularProgressIndicator()))),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _gaugeChart(String label, double percent, Color color) {
    return Column(
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: percent / 100,
                  strokeWidth: 6,
                  backgroundColor: AppTheme.surface,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Text(
                '${percent.toStringAsFixed(0)}%',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.white54)),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(width: 60, child: Text(label, style: const TextStyle(fontSize: 11, color: Colors.white38))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildVmSection(AsyncValue async) {
    return async.when(
      data: (system) {
        if (system.vms.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: 'VMs & LXCs', frequency: RefreshFrequency.daily, lastReport: system.lastReport),
            const SizedBox(height: 8),
            ...system.vms.map((vm) {
              final vmNum = RegExp(r'\d+').firstMatch(vm.name)?.group(0);
              SysUpdate? upd;
              for (final u in system.updates) {
                final upNum = RegExp(r'\d+').firstMatch(u.system)?.group(0);
                if (vmNum != null && upNum != null && vmNum == upNum) {
                  upd = u;
                  break;
                }
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: VmDetailCard(vm: vm, update: upd),
              );
            }),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildServiceSection(AsyncValue async) {
    return async.when(
      data: (system) {
        if (system.services.isEmpty) return const SizedBox.shrink();
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(title: 'Services', frequency: RefreshFrequency.daily, lastReport: system.lastReport),
                ...system.services.map((s) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          HealthDot(status: s.online ? 'online' : 'offline', size: 8),
                          const SizedBox(width: 8),
                          Expanded(child: Text(s.name, style: const TextStyle(fontSize: 12))),
                          if (s.port > 0)
                            Text(
                              'Port ${s.port}',
                              style: const TextStyle(fontSize: 10, color: Colors.white38),
                            ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildBackupSection(AsyncValue async) {
    return async.when(
      data: (system) {
        if (system.backups.isEmpty) return const SizedBox.shrink();
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(title: 'Backups', frequency: RefreshFrequency.daily, lastReport: system.lastReport),
                ...system.backups.map((b) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                b.success ? Icons.check_circle : Icons.error,
                                size: 16,
                                color: b.success ? AppTheme.green : AppTheme.red,
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(b.vmName, style: const TextStyle(fontSize: 12))),
                              Text(
                                '${b.lastBackup.day}.${b.lastBackup.month}.',
                                style: const TextStyle(fontSize: 10, color: Colors.white38),
                              ),
                            ],
                          ),
                          if (b.detail.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(left: 24, top: 1),
                              child: Text(b.detail, style: const TextStyle(fontSize: 10, color: Colors.white30)),
                            ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildUpdateSection(AsyncValue async) {
    return async.when(
      data: (system) {
        if (system.updates.isEmpty) return const SizedBox.shrink();
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(title: 'Updates & Wartung', frequency: RefreshFrequency.daily, lastReport: system.lastReport),
                const SizedBox(height: 8),
                ...system.updates.map((u) => _updateRow(u)),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _updateRow(SysUpdate u) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(u.system, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ),
          if (u.updatesPending > 0)
            _tag('${u.updatesPending} Updates', AppTheme.gold)
          else
            _tag('aktuell', AppTheme.green),
          const SizedBox(width: 6),
          if (u.rebootNeeded)
            _tag('Reboot nötig', AppTheme.red),
          const Spacer(),
          if (u.autoFixes.isNotEmpty)
            Icon(Icons.auto_fix_high, size: 14, color: AppTheme.green),
        ],
      ),
    );
  }

  Widget _tag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text, style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w600)),
    );
  }
}
