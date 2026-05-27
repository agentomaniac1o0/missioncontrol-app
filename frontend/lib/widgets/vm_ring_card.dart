import 'dart:math';
import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/missioncontrol_system.dart';
import 'health_dot.dart';

class VmRingCard extends StatelessWidget {
  final VmStatus vm;

  const VmRingCard({super.key, required this.vm});

  static const _ringDefs = [
    (label: 'CPU', color: AppTheme.blue),
    (label: 'RAM', color: AppTheme.gold),
    (label: 'Disk', color: AppTheme.green),
  ];

  @override
  Widget build(BuildContext context) {
    final values = [vm.cpuPercent, vm.ramPercent, vm.diskPercent];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: CustomPaint(
                painter: _TreeRingPainter(values: values),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
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
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(3, (i) {
                    final pct = values[i];
                    final def = _ringDefs[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: def.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(def.label, style: TextStyle(fontSize: 11, color: Colors.white54)),
                          const SizedBox(width: 4),
                          Text(
                            '${pct.toStringAsFixed(0)}%',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: def.color),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TreeRingPainter extends CustomPainter {
  final List<double> values;

  _TreeRingPainter({required this.values});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = size.width / 2 - 2;
    const ringW = 10.0;
    const gap = 2.0;
    final colors = VmRingCard._ringDefs.map((d) => d.color).toList();

    for (int i = 0; i < 3; i++) {
      final radius = maxR - (i * (ringW + gap)) - 2;
      final pct = (values[i] / 100).clamp(0.0, 1.0);
      final color = colors[i];

      final bgPaint = Paint()
        ..color = AppTheme.surface.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = ringW
        ..strokeCap = StrokeCap.butt;

      canvas.drawCircle(center, radius, bgPaint);

      if (pct > 0.005) {
        final fillPaint = Paint()
          ..color = color.withValues(alpha: 0.95)
          ..style = PaintingStyle.stroke
          ..strokeWidth = ringW
          ..strokeCap = pct > 0.98 ? StrokeCap.butt : StrokeCap.round;

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          -pi / 2,
          pct * 2 * pi,
          false,
          fillPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}
