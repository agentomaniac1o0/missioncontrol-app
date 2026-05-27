import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/missioncontrol_system.dart';
import 'health_dot.dart';

class VmDetailCard extends StatelessWidget {
  final VmStatus vm;
  final SysUpdate? update;

  const VmDetailCard({super.key, required this.vm, this.update});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
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
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
                if (update != null && update!.updatesPending > 0)
                  _tag('${update!.updatesPending} Updates', AppTheme.gold),
                if (update != null && update!.rebootNeeded)
                  _tag('Reboot', AppTheme.red),
              ],
            ),
            const SizedBox(height: 10),
            _metricBar('CPU', vm.cpuPercent, AppTheme.blue),
            _metricBar('RAM', vm.ramPercent, AppTheme.gold),
            _metricBar('Disk', vm.diskPercent, AppTheme.green),
            if (update != null && update!.autoFixes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.auto_fix_high, size: 13, color: AppTheme.green),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      update!.autoFixes.take(2).join(' · '),
                      style: const TextStyle(fontSize: 10, color: Colors.white54),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _metricBar(String label, double percent, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(width: 30, child: Text(label, style: TextStyle(fontSize: 10, color: Colors.white38))),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: percent / 100,
                minHeight: 7,
                backgroundColor: AppTheme.surface,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 35,
            child: Text(
              '${percent.toStringAsFixed(0)}%',
              style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
              textAlign: TextAlign.right,
            ),
          ),
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
