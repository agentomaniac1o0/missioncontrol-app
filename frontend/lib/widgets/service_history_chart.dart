import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/missioncontrol_service_history.dart';

class ServiceHistoryChart extends StatelessWidget {
  const ServiceHistoryChart({super.key, required this.data});

  final ServiceHistoryResponse data;

  @override
  Widget build(BuildContext context) {
    final services = data.services.where((s) => s.history.isNotEmpty).toList();
    if (services.isEmpty) return const SizedBox.shrink();

    final allTs = <int>{};
    for (final s in services) {
      for (final h in s.history) {
        allTs.add(DateTime.parse(h.timestamp).millisecondsSinceEpoch);
      }
    }
    final tsList = allTs.toList()..sort();
    if (tsList.isEmpty) return const SizedBox.shrink();

    final tsMap = {for (var i = 0; i < tsList.length; i++) tsList[i]: i};

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 12, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 4),
            _buildChart(services, tsList, tsMap),
            const SizedBox(height: 6),
            _buildLegend(services),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
      child: Row(
        children: [
          const Icon(Icons.timeline, size: 14, color: AppTheme.textSecondary),
          const SizedBox(width: 6),
          const Text('Service Response History',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
          const Spacer(),
          Text(
            data.collectedAt.isNotEmpty
                ? _formatDate(DateTime.parse(data.collectedAt))
                : '',
            style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(List<ServiceHistorySeries> services, List<int> tsList, Map<int, int> tsMap) {
    return SizedBox(
      height: 150,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (v) =>
                const FlLine(color: AppTheme.gridLine, strokeWidth: 0.5),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: (tsList.length / 4).ceilToDouble(),
              getTitlesWidget: (v, _) {
                final i = v.toInt();
                if (i < 0 || i >= tsList.length) return const SizedBox.shrink();
                final dt = DateTime.fromMillisecondsSinceEpoch(tsList[i]);
                return Text(
                  '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 8, color: AppTheme.textMuted),
                );
              },
            )),
            leftTitles: AxisTitles(sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: 10,
              getTitlesWidget: (v, _) => Text(
                '${v.toInt()}ms',
                style: const TextStyle(fontSize: 8, color: AppTheme.textMuted),
              ),
            )),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          minY: 0,
          maxY: services.map((s) => s.maxMs.toDouble()).reduce((a, b) => a > b ? a : b) + 10,
          lineBarsData: services.asMap().entries.map((entry) {
            final idx = entry.key;
            final s = entry.value;
            final color = AppTheme.chartColors[idx % AppTheme.chartColors.length];
            return LineChartBarData(
              spots: s.history
                  .where((h) => tsMap.containsKey(DateTime.parse(h.timestamp).millisecondsSinceEpoch))
                  .map((h) {
                final x = tsMap[DateTime.parse(h.timestamp).millisecondsSinceEpoch]!.toDouble();
                return FlSpot(x, h.responseTimeMs.toDouble());
              }).toList(),
              isCurved: true,
              curveSmoothness: 0.2,
              color: color,
              barWidth: 1.5,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            );
          }).toList(),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) => spots.map((s) {
                final svc = services.length > spots.indexOf(s) ? services[spots.indexOf(s)] : services.first;
                return LineTooltipItem(
                  '${svc.name}: ${s.y.toInt()}ms',
                  const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(List<ServiceHistorySeries> services) {
    return Wrap(
      spacing: 12,
      runSpacing: 2,
      children: services.asMap().entries.map((e) {
        final color = AppTheme.chartColors[e.key % AppTheme.chartColors.length];
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 10, height: 3, color: color),
            const SizedBox(width: 4),
            Text(e.value.name,
                style: const TextStyle(fontSize: 9, color: AppTheme.textHint)),
            const SizedBox(width: 2),
            Text('${e.value.avgMs}ms',
                style: TextStyle(fontSize: 9, color: color)),
          ],
        );
      }).toList(),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}. ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
