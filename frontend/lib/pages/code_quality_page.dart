import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../models/missioncontrol_code_quality.dart';
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
      child: codeQualityAsync.when(
        data: (cq) => _buildContent(cq, context),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppTheme.red),
              const SizedBox(height: 8),
              Text(
                'Daten nicht verfügbar',
                style: TextStyle(color: AppTheme.red, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                '$e'.length > 120 ? '${'$e'.substring(0, 120)}...' : '$e',
                style: const TextStyle(fontSize: 11, color: Colors.white38),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(MissioncontrolCodeQuality cq, BuildContext context) {
    final auditFindings = <Finding>[];
    final subagentFindings = <Finding>[];
    final autoFixFindings = <Finding>[];

    for (final f in cq.findings) {
      if (f.autoFixed) {
        autoFixFindings.add(f);
      } else if (f.title.startsWith('[')) {
        subagentFindings.add(f);
      } else {
        auditFindings.add(f);
      }
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSummaryCards(cq, subagentFindings.length),
        const SizedBox(height: 14),
        if (auditFindings.isNotEmpty) ...[
          _buildFindingsSection(
            title: 'Security Audit',
            subtitle: '${auditFindings.length} Findings',
            lastReport: cq.lastReport,
            findings: auditFindings,
            color: AppTheme.gold,
          ),
          const SizedBox(height: 14),
        ],
        if (subagentFindings.isNotEmpty) ...[
          _buildFindingsSection(
            title: 'Subagent Findings (Code Quality)',
            subtitle: '${subagentFindings.length} Findings',
            lastReport: cq.lastReport,
            findings: subagentFindings,
            color: AppTheme.blue,
          ),
          const SizedBox(height: 14),
        ],
        if (autoFixFindings.isNotEmpty) ...[
          _buildFindingsSection(
            title: 'Auto-Fix Results',
            subtitle: '${autoFixFindings.length} fixes',
            lastReport: cq.lastReport,
            findings: autoFixFindings,
            color: AppTheme.green,
          ),
          const SizedBox(height: 14),
        ],
        if (cq.openPorts.isNotEmpty) _buildOpenPorts(cq),
        const SizedBox(height: 14),
        if (cq.autoFixResults.isNotEmpty) _buildAutoFixSummary(cq),
      ],
    );
  }

  Widget _buildSummaryCards(MissioncontrolCodeQuality cq, int subagentCount) {
    final auditCriticalCount = cq.findings
        .where((f) => !f.autoFixed && !f.title.startsWith('[') && f.severity == 'critical')
        .length;
    final auditHighCount = cq.findings
        .where((f) => !f.autoFixed && !f.title.startsWith('[') && f.severity == 'high')
        .length;
    final auditMediumCount = cq.findings
        .where((f) => !f.autoFixed && !f.title.startsWith('[') && f.severity == 'medium')
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.assessment, size: 14, color: AppTheme.blue),
            const SizedBox(width: 6),
            const Text(
              'Sicherheits-Statistik',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            if (cq.lastReport.isNotEmpty)
              Text(
                'Stand: ${cq.lastReport.length >= 16 ? cq.lastReport.substring(0, 16) : cq.lastReport}',
                style: const TextStyle(fontSize: 10, color: Colors.white38),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
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
                cq.openPorts.isNotEmpty ? AppTheme.gold : AppTheme.blue,
                Icons.router,
              ),
            ),
            Expanded(
              child: _statCard(
                'Subagents',
                '$subagentCount',
                subagentCount > 0 ? AppTheme.gold : AppTheme.green,
                Icons.smart_toy,
              ),
            ),
          ],
        ),
        if (auditCriticalCount > 0 || auditHighCount > 0 || auditMediumCount > 0) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              if (auditCriticalCount > 0)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: _severityBadge('Critical: $auditCriticalCount', AppTheme.red),
                ),
              if (auditHighCount > 0)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: _severityBadge('High: $auditHighCount', AppTheme.gold),
                ),
              if (auditMediumCount > 0)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: _severityBadge('Medium: $auditMediumCount', AppTheme.blue),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _severityBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(text, style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w600)),
    );
  }

  Widget _statCard(String label, String value, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 3),
            Text(value,
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            Text(label,
                style: const TextStyle(fontSize: 9, color: Colors.white38)),
          ],
        ),
      ),
    );
  }

  Widget _buildFindingsSection({
    required String title,
    required String subtitle,
    required String lastReport,
    required List<Finding> findings,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(_iconForSection(title), size: 14, color: color),
            const SizedBox(width: 6),
            Text(title,
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600, color: color)),
            const SizedBox(width: 8),
            Text(subtitle,
                style: const TextStyle(fontSize: 11, color: Colors.white38)),
            const Spacer(),
            if (lastReport.isNotEmpty)
              Text(
                lastReport.length >= 16
                    ? lastReport.substring(0, 16)
                    : lastReport,
                style: const TextStyle(fontSize: 9, color: Colors.white30),
              ),
          ],
        ),
        const SizedBox(height: 8),
        ...findings.map((f) => FindingCard(finding: f)),
      ],
    );
  }

  IconData _iconForSection(String title) {
    if (title.contains('Subagent')) return Icons.smart_toy;
    if (title.contains('Auto-Fix')) return Icons.auto_fix_high;
    return Icons.security;
  }

  Widget _buildOpenPorts(MissioncontrolCodeQuality cq) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.router, size: 14, color: AppTheme.blue),
                SizedBox(width: 6),
                Text('Offene Ports',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
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
                      Text('${p.port}',
                          style: const TextStyle(
                              fontSize: 12, fontFamily: 'monospace')),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          p.service,
                          style: const TextStyle(
                              fontSize: 11, color: Colors.white54),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildAutoFixSummary(MissioncontrolCodeQuality cq) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.auto_fix_high, size: 14, color: AppTheme.green),
                SizedBox(width: 6),
                Text('Auto-Fixes',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
            ...cq.autoFixResults.map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(r,
                      style:
                          const TextStyle(fontSize: 11, color: Colors.white54)),
                )),
          ],
        ),
      ),
    );
  }
}
