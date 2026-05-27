import 'dart:math';
import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/missioncontrol_system.dart';
import 'health_dot.dart';

class VmRingCard extends StatelessWidget {
  final VmStatus vm;

  const VmRingCard({super.key, required this.vm});

  static const _colors = [
    ('CPU', AppTheme.blue),
    ('RAM', AppTheme.gold),
    ('Disk', AppTheme.green),
  ];

  @override
  Widget build(BuildContext context) {
    final values = [vm.cpuPercent, vm.ramPercent, vm.diskPercent];
    final hasData = values.any((v) => v > 0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        child: Row(
          children: [
            SizedBox(
              width: 64,
              height: 64,
              child: CustomPaint(
                painter: _RingPainter(values: values),
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
                  Wrap(
                    spacing: 8,
                    runSpacing: 2,
                    children: List.generate(3, (i) {
                      final pct = values[i];
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: _colors[i].$2,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${_colors[i].$1} ${pct.toStringAsFixed(0)}%',
                            style: TextStyle(fontSize: 10, color: Colors.white54),
                          ),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final List<double> values;

  _RingPainter({required this.values});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2 - 2;
    final ringWidth = 5.0;
    final innerPad = 10.0;
    final totalRings = VmRingCard._colors.length;

    for (int i = 0; i < totalRings; i++) {
      final radius = maxRadius - innerPad - (i * (ringWidth + 1));
      final pct = (values[i] / 100).clamp(0.01, 1.0); // min 1% for visibility

      final paint = Paint()
        ..color = VmRingCard._colors[i].$2.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = ringWidth
        ..strokeCap = StrokeCap.round;

      final rect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawArc(
        rect,
        -pi / 2, // start from top (12 o'clock)
        pct * 2 * pi,
        false,
        paint,
      );

      // Background ring
      final bgPaint = Paint()
        ..color = AppTheme.surface.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = ringWidth;

      canvas.drawArc(
        rect,
        (-pi / 2) + (pct * 2 * pi),
        (1 - pct) * 2 * pi,
        false,
        bgPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}
