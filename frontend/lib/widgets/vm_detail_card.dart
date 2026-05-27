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
                if (update != null && update!.rebootNeeded)
                  _tag('Reboot nötig', AppTheme.red),
              ],
            ),
            const SizedBox(height: 10),
            _metricBar('CPU', vm.cpuPercent, AppTheme.blue),
            _metricBar('RAM', vm.ramPercent, AppTheme.gold),
            _metricBar('Disk', vm.diskPercent, AppTheme.green),
            if (update != null) ...[
              if (update!.kernel.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.memory, size: 12, color: Colors.white38),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        update!.kernel,
                        style: const TextStyle(fontSize: 10, color: Colors.white54, fontFamily: 'monospace'),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              if (update!.autoFixes.isNotEmpty) ...[
                const SizedBox(height: 4),
                const Divider(height: 1, color: Colors.white12),
                const SizedBox(height: 4),
                ...update!.autoFixes.take(3).map((f) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle_outline, size: 11, color: AppTheme.green),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(f, style: const TextStyle(fontSize: 10, color: Colors.white54)),
                          ),
                        ],
                      ),
                    )),
                if (update!.autoFixes.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Text(
                      '+ ${update!.autoFixes.length - 3} weitere',
                      style: const TextStyle(fontSize: 9, color: Colors.white30),
                    ),
                  ),
              ],
              if (update!.warnings.isNotEmpty) ...[
                const SizedBox(height: 4),
                const Divider(height: 1, color: Colors.white12),
                const SizedBox(height: 4),
                ...update!.warnings.take(2).map((w) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.warning_amber, size: 11, color: AppTheme.gold),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(w, style: const TextStyle(fontSize: 10, color: Colors.white54)),
                          ),
                        ],
                      ),
                    )),
              ],
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
      margin: const EdgeInsets.only(left: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text, style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w600)),
    );
  }
}
