import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/missioncontrol_system.dart';
import 'health_dot.dart';

class VmRingCard extends StatelessWidget {
  final VmStatus vm;

  const VmRingCard({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final values = [vm.cpuPercent, vm.ramPercent, vm.diskPercent];
    final hasAnyData = values.any((v) => v > 0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: hasAnyData
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(width: 92, height: 92, child: CircularProgressIndicator(value: (values[2] / 100).clamp(0.0, 1.0), strokeWidth: 8, strokeCap: StrokeCap.round, backgroundColor: AppTheme.surface.withValues(alpha: 0.4), valueColor: AlwaysStoppedAnimation<Color>(AppTheme.green))),
                        SizedBox(width: 72, height: 72, child: CircularProgressIndicator(value: (values[1] / 100).clamp(0.0, 1.0), strokeWidth: 8, strokeCap: StrokeCap.round, backgroundColor: AppTheme.surface.withValues(alpha: 0.4), valueColor: AlwaysStoppedAnimation<Color>(AppTheme.gold))),
                        SizedBox(width: 52, height: 52, child: CircularProgressIndicator(value: (values[0] / 100).clamp(0.0, 1.0), strokeWidth: 8, strokeCap: StrokeCap.round, backgroundColor: AppTheme.surface.withValues(alpha: 0.4), valueColor: AlwaysStoppedAnimation<Color>(AppTheme.blue))),
                      ],
                    )
                  : const Center(child: Icon(Icons.circle_outlined, size: 48, color: Colors.white12)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      HealthDot(status: vm.status, size: 8),
                      const SizedBox(width: 8),
                      Expanded(child: Text(vm.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _legend('CPU', values[0], AppTheme.blue),
                  _legend('RAM', values[1], AppTheme.gold),
                  _legend('Disk', values[2], AppTheme.green),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legend(String label, double pct, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          SizedBox(width: 26, child: Text(label, style: TextStyle(fontSize: 11, color: Colors.white54))),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(value: pct / 100, minHeight: 5, backgroundColor: AppTheme.surface, valueColor: AlwaysStoppedAnimation<Color>(color)),
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(width: 34, child: Text('${pct.toStringAsFixed(0)}%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color), textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}
