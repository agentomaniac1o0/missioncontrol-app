import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../models/missioncontrol_live.dart';
import '../providers/live_provider.dart';
import '../providers/missioncontrol_provider.dart';
import '../widgets/refresh_badge.dart';

class LivePage extends ConsumerStatefulWidget {
  const LivePage({super.key});

  @override
  ConsumerState<LivePage> createState() => _LivePageState();
}

class _LivePageState extends ConsumerState<LivePage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        final loc = ref.read(locationProvider);
        ref.invalidate(missioncontrollerLiveProvider(loc));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final location = ref.watch(locationProvider);
    final liveAsync = ref.watch(missioncontrollerLiveProvider(location));

    return RefreshIndicator(
      onRefresh: () async {
        final loc = ref.read(locationProvider);
        ref.invalidate(missioncontrollerLiveProvider(loc));
      },
      child: liveAsync.when(
        data: (live) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SectionHeader(
              title: 'Heartbeat (Pings)',
              frequency: RefreshFrequency.live,
              subtitle: 'RPi Watchdog + Server-Pings',
            ),
            _buildHeartbeatGrid(live.heartbeats),
            const SizedBox(height: 14),
            SectionHeader(
              title: 'Services (Port-Checks)',
              frequency: RefreshFrequency.live,
              subtitle: 'Response Times',
            ),
            _buildServiceChecks(live.serviceChecks),
            if (live.serviceChecks.isNotEmpty) ...[
              const SizedBox(height: 14),
              SectionHeader(
                title: 'Response Times',
                frequency: RefreshFrequency.live,
                subtitle: 'ms',
              ),
              _buildResponseChart(live.serviceChecks),
            ],
            const SizedBox(height: 12),
            _buildTimestamp(live.timestamp),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 48, color: Colors.white24),
              const SizedBox(height: 8),
              Text('Live-Daten nicht verfuegbar',
                  style: TextStyle(color: AppTheme.red.withValues(alpha: 0.7))),
              const SizedBox(height: 4),
              Text('$e',
                  style: const TextStyle(fontSize: 10, color: Colors.white24)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeartbeatGrid(List<LiveHeartbeat> heartbeats) {
    if (heartbeats.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text('Keine Heartbeat-Daten',
                style: TextStyle(color: AppTheme.gold.withValues(alpha: 0.7))),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: heartbeats.length,
      itemBuilder: (_, i) => _HeartbeatCard(beat: heartbeats[i]),
    );
  }

  Widget _buildServiceChecks(List<LiveServiceCheck> checks) {
    if (checks.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text('Keine Service-Checks',
                style: TextStyle(color: AppTheme.gold.withValues(alpha: 0.7))),
          ),
        ),
      );
    }

    final maxTime = checks
        .map((c) => c.responseTimeMs.toDouble())
        .reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: checks.map((c) {
            final ratio = maxTime > 0 ? c.responseTimeMs / maxTime : 0.0;
            final color = c.online
                ? c.responseTimeMs < 50
                    ? AppTheme.green
                    : c.responseTimeMs < 200
                        ? AppTheme.gold
                        : AppTheme.red
                : AppTheme.red;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  _HealthPulse(online: c.online),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(c.service,
                                style: const TextStyle(fontSize: 12)),
                            Text(
                              c.online ? '${c.responseTimeMs}ms' : 'offline',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: color,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: c.online ? ratio : 0.0,
                            backgroundColor: AppTheme.dark,
                            color: color,
                            minHeight: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildResponseChart(List<LiveServiceCheck> checks) {
    final onlineChecks = checks.where((c) => c.online).toList();
    if (onlineChecks.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 180,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: onlineChecks
                      .map((c) => c.responseTimeMs.toDouble())
                      .reduce((a, b) => a > b ? a : b) *
                  1.3,
              barGroups: onlineChecks.asMap().entries.map((e) {
                final time = e.value.responseTimeMs.toDouble();
                final color = time < 50
                    ? AppTheme.green
                    : time < 200
                        ? AppTheme.gold
                        : AppTheme.red;
                return BarChartGroupData(
                  x: e.key,
                  barRods: [
                    BarChartRodData(
                      toY: time,
                      color: color,
                      width: 18,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(3)),
                    ),
                  ],
                );
              }).toList(),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (value, meta) {
                      final i = value.toInt();
                      if (i < 0 || i >= onlineChecks.length) {
                        return const SizedBox.shrink();
                      }
                      final label = onlineChecks[i].service;
                      final short = label.length > 4
                          ? label.substring(0, 4)
                          : label;
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(short,
                            style: const TextStyle(
                                fontSize: 9, color: Colors.white38)),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    getTitlesWidget: (value, meta) => Text(
                      '${value.toInt()}ms',
                      style: const TextStyle(
                          fontSize: 9, color: Colors.white24),
                    ),
                  ),
                ),
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
                horizontalInterval: 50,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.white10,
                  strokeWidth: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimestamp(DateTime ts) {
    return Center(
      child: Text(
        'Letzter Check: ${ts.day.toString().padLeft(2, '0')}.${ts.month.toString().padLeft(2, '0')}. ${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}:${ts.second.toString().padLeft(2, '0')}',
        style: const TextStyle(fontSize: 10, color: Colors.white24),
      ),
    );
  }
}

class _HeartbeatCard extends StatelessWidget {
  final LiveHeartbeat beat;
  const _HeartbeatCard({required this.beat});

  @override
  Widget build(BuildContext context) {
    final isOk = beat.status == 'ok';
    final color = isOk ? AppTheme.green : AppTheme.red;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _HealthPulse(online: isOk, size: 16),
            const SizedBox(height: 8),
            Text(beat.system,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(
              beat.status.toUpperCase(),
              style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _HealthPulse extends StatefulWidget {
  final bool online;
  final double size;
  const _HealthPulse({required this.online, this.size = 10});

  @override
  State<_HealthPulse> createState() => _HealthPulseState();
}

class _HealthPulseState extends State<_HealthPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _anim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    if (widget.online) {
      _ctrl.repeat();
    }
  }

  @override
  void didUpdateWidget(_HealthPulse old) {
    super.didUpdateWidget(old);
    if (widget.online && !_ctrl.isAnimating) {
      _ctrl.repeat();
    } else if (!widget.online && _ctrl.isAnimating) {
      _ctrl.stop();
      _ctrl.reset();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.online ? AppTheme.green : AppTheme.red;
    final size = widget.size;
    return SizedBox(
      width: size * 2.5,
      height: size * 2.5,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (_, child) => CustomPaint(
          painter: _PulsePainter(color: color, radius: _anim.value * size),
          child: child,
        ),
        child: Center(
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

class _PulsePainter extends CustomPainter {
  final Color color;
  final double radius;

  _PulsePainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    if (radius <= 0) return;
    final paint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      radius + 4,
      paint,
    );
  }

  @override
  bool shouldRepaint(_PulsePainter old) => old.radius != radius;
}
