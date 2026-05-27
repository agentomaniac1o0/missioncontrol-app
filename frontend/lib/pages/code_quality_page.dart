import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../providers/missioncontrol_provider.dart';
import '../widgets/finding_card.dart';

class CodeQualityPage extends ConsumerWidget {
  const CodeQualityPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = ref.watch(locationProvider);
    final codeQualityAsync =
        ref.watch(missioncontrollerCodeQualityProvider(location));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(missioncontrollerCodeQualityProvider(location));
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSummaryCards(codeQualityAsync),
          const SizedBox(height: 12),
          _buildFindings(codeQualityAsync),
          const SizedBox(height: 12),
          _buildOpenPorts(codeQualityAsync),
          const SizedBox(height: 12),
          _buildAutoFixes(codeQualityAsync),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(AsyncValue async) {
    return async.when(
      data: (cq) => Row(
        children: [
          Expanded(
            child: _statCard(
              'Secrets',
              '${cq.hardcodedSecrets}',
              cq.hardcodedSecrets > 0 ? AppTheme.red : AppTheme.green,
              Icons.vpn_key,
            ),
          ),
          Expanded(
            child: _statCard(
              'bare excepts',
              '${cq.bareExcepts}',
              cq.bareExcepts > 0 ? AppTheme.gold : AppTheme.green,
              Icons.bug_report,
            ),
          ),
          Expanded(
            child: _statCard(
              'Offene Ports',
              '${cq.openPorts.length}',
              cq.openPorts.any((p) => !p.expected) ? AppTheme.gold : AppTheme.blue,
              Icons.router,
            ),
          ),
        ],
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _statCard(String label, String value, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.white38)),
          ],
        ),
      ),
    );
  }

  Widget _buildFindings(AsyncValue async) {
    return async.when(
      data: (cq) {
        if (cq.findings.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 8),
              child: Text('Audit Findings',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ),
            ...cq.findings.map((f) => FindingCard(finding: f)),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildOpenPorts(AsyncValue async) {
    return async.when(
      data: (cq) {
        if (cq.openPorts.isEmpty) return const SizedBox.shrink();
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Offene Ports',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ...cq.openPorts.map((p) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Icon(
                            p.expected ? Icons.check_circle : Icons.warning,
                            size: 14,
                            color: p.expected ? AppTheme.green : AppTheme.gold,
                          ),
                          const SizedBox(width: 8),
                          Text('${p.port}', style: const TextStyle(fontSize: 12, fontFamily: 'monospace')),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              p.service,
                              style: const TextStyle(fontSize: 11, color: Colors.white54),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildAutoFixes(AsyncValue async) {
    return async.when(
      data: (cq) {
        if (cq.autoFixResults.isEmpty) return const SizedBox.shrink();
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.auto_fix_high, size: 14, color: AppTheme.green),
                    SizedBox(width: 6),
                    Text('Auto-Fixes',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 8),
                ...cq.autoFixResults.map((r) => Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(r, style: const TextStyle(fontSize: 11, color: Colors.white54)),
                    )),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
