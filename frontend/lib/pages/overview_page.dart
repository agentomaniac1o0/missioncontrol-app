import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../models/missioncontrol_health.dart';
import '../models/missioncontrol_overview.dart';
import '../providers/live_provider.dart';
import '../providers/missioncontrol_provider.dart';
import '../widgets/disk_bar.dart';
import '../widgets/health_dot.dart';
import '../widgets/health_score_card.dart';
import '../widgets/refresh_badge.dart';
import '../widgets/service_matrix.dart';
import '../widgets/vm_ring_card.dart';

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
          _buildHealthTrend(ref, location),
          const SizedBox(height: 12),
          _buildStatusStrip(overviewAsync),
          _buildDiskSection(overviewAsync),
          const SizedBox(height: 14),
          _buildVmSectionOverview(overviewAsync, systemAsync),
          const SizedBox(height: 14),
          _buildServiceSectionOverview(overviewAsync, systemAsync),
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

  Widget _buildHealthTrend(WidgetRef ref, String location) {
    final trendAsync = ref.watch(healthTrendProvider(location));
    return trendAsync.when(
      data: (points) {
        if (points.length < 2) return const SizedBox.shrink();
        final maxY = points.map((p) => p.score.toDouble()).reduce((a, b) => a > b ? a : b);
        final minY = points.map((p) => p.score.toDouble()).reduce((a, b) => a < b ? a : b);
        return Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Text('Health Trend', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white54)),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  height: 100,
                  child: LineChart(
                    LineChartData(
                      minY: (minY - 5).clamp(0, 100).toDouble(),
                      maxY: (maxY + 5).clamp(0, 100).toDouble(),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (v) => FlLine(color: Colors.white10, strokeWidth: 0.5),
                      ),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 20,
                          interval: 3,
                          getTitlesWidget: (v, _) {
                            final i = v.toInt();
                            if (i < 0 || i >= points.length) return const SizedBox.shrink();
                            return Text(points[i].date.substring(5), style: const TextStyle(fontSize: 8, color: Colors.white24));
                          },
                        )),
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: points.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.score.toDouble())).toList(),
                          isCurved: true,
                          color: AppTheme.green,
                          barWidth: 2,
                          dotData: FlDotData(show: true, getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(radius: 2, color: AppTheme.green, strokeWidth: 0)),
                          belowBarData: BarAreaData(show: true, color: AppTheme.green.withValues(alpha: 0.08)),
                        ),
                      ],
                    ),
                  ),
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

  Widget _buildDiskSection(AsyncValue<MissioncontrolOverview> async) {
    return async.when(
      data: (overview) {
        if (overview.diskUsage.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: 'Disk Usage', frequency: RefreshFrequency.daily, subtitle: 'aus Report', lastReport: _fmtIso(overview.lastReport)),
            Card(
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
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildVmSectionOverview(AsyncValue<MissioncontrolOverview> overviewAsync, AsyncValue systemAsync) {
    final overview = overviewAsync.asData?.value;
    return systemAsync.when(
      data: (system) {
        if (system.vms.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: 'VMs & LXCs', frequency: RefreshFrequency.daily, subtitle: 'aus Report', lastReport: overview != null ? _fmtIso(overview.lastReport) : null),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: system.vms.length,
              itemBuilder: (_, i) => VmRingCard(vm: system.vms[i]),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildServiceSectionOverview(AsyncValue<MissioncontrolOverview> overviewAsync, AsyncValue systemAsync) {
    final overview = overviewAsync.asData?.value;
    return systemAsync.when(
      data: (system) {
        if (system.services.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: 'Services', frequency: RefreshFrequency.daily, subtitle: 'aus Report', lastReport: overview != null ? _fmtIso(overview.lastReport) : null),
            ServiceMatrix(services: system.services),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  String _fmtIso(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}T${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:00';
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
                  lastReport: _fmtIso(overview.lastReport),
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
