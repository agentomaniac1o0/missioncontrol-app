import 'dart:math';
import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/missioncontrol_system.dart';
import 'health_dot.dart';

class VmGaugeCard extends StatelessWidget {
  final VmStatus vm;

  const VmGaugeCard({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                HealthDot(status: vm.status, size: 8),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    vm.name,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, constraints) {
                final radius = (constraints.maxWidth - 16) / 3;
                return SizedBox(
                  height: radius * 1.3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _miniGauge('CPU', vm.cpuPercent, AppTheme.blue, radius),
                      _miniGauge('RAM', vm.ramPercent, AppTheme.gold, radius),
                      _miniGauge('Disk', vm.diskPercent, AppTheme.green, radius),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniGauge(String label, double percent, Color color, double size) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: percent / 100,
                  strokeWidth: 4,
                  backgroundColor: AppTheme.surface,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Text(
                '${percent.toStringAsFixed(0)}%',
                style: TextStyle(fontSize: size * 0.22, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
        ),
        const SizedBox(height: 3),
        Text(label, style: TextStyle(fontSize: 9, color: Colors.white38)),
      ],
    );
  }
}
