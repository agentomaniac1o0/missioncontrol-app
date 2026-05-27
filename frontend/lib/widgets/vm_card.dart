import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/missioncontrol_system.dart';
import 'health_dot.dart';

class VmCard extends StatelessWidget {
  final VmStatus vm;

  const VmCard({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                HealthDot(status: vm.status, size: 8),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    vm.name,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(vm.status.toUpperCase(), style: TextStyle(fontSize: 10, color: Colors.white38)),
              ],
            ),
            const SizedBox(height: 8),
            _metricRow('CPU', vm.cpuPercent),
            _metricRow('RAM', vm.ramPercent),
            _metricRow('Disk', vm.diskPercent),
          ],
        ),
      ),
    );
  }

  Widget _metricRow(String label, double percent) {
    final color = percent >= 90
        ? AppTheme.red
        : percent >= 70
            ? AppTheme.gold
            : AppTheme.green;
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          SizedBox(width: 28, child: Text(label, style: TextStyle(fontSize: 10, color: Colors.white38))),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: percent / 100,
                minHeight: 4,
                backgroundColor: AppTheme.surface,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Text('${percent.toStringAsFixed(0)}%', style: TextStyle(fontSize: 10, color: Colors.white54)),
        ],
      ),
    );
  }
}
