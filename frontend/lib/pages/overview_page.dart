import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/missioncontrol_health.dart';
import '../models/missioncontrol_overview.dart';
import '../providers/live_provider.dart';
import '../providers/missioncontrol_provider.dart';
import '../widgets/disk_bar.dart';
import '../widgets/health_dot.dart';
import '../widgets/health_score_card.dart';
import '../widgets/refresh_badge.dart';
import '../widgets/service_matrix.dart';
import '../widgets/vm_card.dart';

class OverviewPage extends ConsumerWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = ref.watch(locationProvider);
    final overviewAsync = ref.watch(missioncontrollerOverviewProvider(location));
    final healthAsync = ref.watch(missioncontrollerHealthProvider(location));
    final systemAsync = ref.watch(missioncontrollerSystemProvider(location));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(missioncontrollerOverviewProvider(location));
        ref.invalidate(missioncontrollerHealthProvider(location));
        ref.invalidate(missioncontrollerSystemProvider(location));
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHealthScore(healthAsync),
          const SizedBox(height: 12),
          _buildStatusStrip(overviewAsync),
          const SizedBox(height: 14),
          SectionHeader(title: 'Disk Usage', frequency: RefreshFrequency.daily, subtitle: 'aus Report'),
          _buildDiskOverview(overviewAsync),
          const SizedBox(height: 14),
          SectionHeader(title: 'VMs & LXCs', frequency: RefreshFrequency.daily, subtitle: 'aus Report'),
          _buildVmGrid(systemAsync),
          const SizedBox(height: 14),
          SectionHeader(title: 'Services', frequency: RefreshFrequency.daily, subtitle: 'aus Report'),
          _buildServiceMatrix(systemAsync),
          const SizedBox(height: 14),
          _buildAlerts(overviewAsync),
        ],
      ),
    );
  }

  Widget _buildHealthScore(AsyncValue<MissioncontrolHealth> healthAsync) {
    return healthAsync.when(
      data: (health) => HealthScoreCard(health: health),
      loading: () => const HealthScoreCard(health: null),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildStatusStrip(AsyncValue<MissioncontrolOverview> async) {
    return async.when(
      data: (overview) => Row(
        children: [
          HealthDot(status: overview.status),
          const SizedBox(width: 8),
          Text(
            overview.status.toUpperCase(),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          Text(
            'Letzter Report: ${_formatDate(overview.lastReport)}',
            style: const TextStyle(fontSize: 11, color: Colors.white38),
          ),
        ],
      ),
      loading: () => const Text('Lade Dashboard...'),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildDiskOverview(AsyncValue<MissioncontrolOverview> async) {
    return async.when(
      data: (overview) {
        if (overview.diskUsage.isEmpty) return const SizedBox.shrink();
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...overview.diskUsage.entries.map(
                  (e) => DiskBar(label: e.key, percent: e.value),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildVmGrid(AsyncValue async) {
    return async.when(
      data: (system) {
        if (system.vms.isEmpty) return const SizedBox.shrink();
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.6,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: system.vms.length,
          itemBuilder: (_, i) => VmCard(vm: system.vms[i]),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildServiceMatrix(AsyncValue async) {
    return async.when(
      data: (system) {
        if (system.services.isEmpty) return const SizedBox.shrink();
        return ServiceMatrix(services: system.services);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildAlerts(AsyncValue<MissioncontrolOverview> async) {
    return async.when(
      data: (overview) {
        if (overview.activeAlerts.isEmpty) return const SizedBox.shrink();
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(
                  title: 'Aktive Alerts',
                  frequency: RefreshFrequency.daily,
                  subtitle: 'aus Report',
                ),
                ...overview.activeAlerts.map((a) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(a, style: const TextStyle(fontSize: 12)),
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

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}. ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
