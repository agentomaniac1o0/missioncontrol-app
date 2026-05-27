import 'dart:math';
import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/missioncontrol_system.dart';
import 'health_dot.dart';

class VmRingCard extends StatelessWidget {
  final VmStatus vm;

  const VmRingCard({super.key, required this.vm});

  static const _colors = [
    _RingInfo('CPU', AppTheme.blue),
    _RingInfo('RAM', AppTheme.gold),
    _RingInfo('Disk', AppTheme.green),
  ];

  @override
  Widget build(BuildContext context) {
    final values = [vm.cpuPercent, vm.ramPercent, vm.diskPercent];

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Row(
          children: [
            SizedBox(
              width: 68,
              height: 68,
              child: CustomPaint(
                painter: _TreeRingPainter(values: values),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      HealthDot(status: vm.status, size: 7),
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
                  const SizedBox(height: 6),
                  ...List.generate(3, (i) {
                    final pct = values[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: _colors[i].color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_colors[i].label} ${pct.toStringAsFixed(0)}%',
                            style: TextStyle(fontSize: 10, color: Colors.white54),
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

class _RingInfo {
  final String label;
  final Color color;
  const _RingInfo(this.label, this.color);
}

class _TreeRingPainter extends CustomPainter {
  final List<double> values;

  _TreeRingPainter({required this.values});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2 - 2;
    final ringCount = VmRingCard._colors.length;
    final ringWidth = (outerRadius - 6) / ringCount;

    for (int i = 0; i < ringCount; i++) {
      final innerR = 4 + (i * ringWidth);
      final outerR = innerR + ringWidth;
      final pct = (values[i] / 100).clamp(0.0, 1.0);
      final color = VmRingCard._colors[i].color;

      // Background ring (dark)
      final bgPaint = Paint()
        ..color = AppTheme.surface
        ..style = PaintingStyle.stroke
        ..strokeWidth = ringWidth - 1;

      canvas.drawCircle(center, innerR + ringWidth / 2, bgPaint);

      // Filled arc
      if (pct > 0.01) {
        final fillPaint = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = ringWidth - 1
          ..strokeCap = StrokeCap.round;

        final rect = Rect.fromCircle(center: center, radius: innerR + ringWidth / 2);
        canvas.drawArc(
          rect,
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
