import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/theme.dart';
import '../providers/graphiphy_provider.dart';
import '../providers/missioncontrol_provider.dart';
import '../widgets/refresh_badge.dart';

class GraphiphyPage extends ConsumerStatefulWidget {
  const GraphiphyPage({super.key});

  @override
  ConsumerState<GraphiphyPage> createState() => _GraphiphyPageState();
}

class _GraphiphyPageState extends ConsumerState<GraphiphyPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final location = ref.watch(locationProvider);

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: AppTheme.green,
          unselectedLabelColor: Colors.white54,
          indicatorColor: AppTheme.green,
          tabs: const [
            Tab(text: 'Ubersicht'),
            Tab(text: 'Graph'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(location),
              _buildGraphTab(location),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewTab(String location) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(graphiphyStatsProvider(location));
        ref.invalidate(graphiphyGodNodesProvider(location));
        ref.invalidate(graphiphyCommunitiesProvider(location));
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStats(location),
          const SizedBox(height: 14),
          _buildSearchBar(),
          const SizedBox(height: 14),
          SectionHeader(title: 'God Nodes', frequency: RefreshFrequency.live, subtitle: 'meist-verbundene Knoten'),
          _buildGodNodes(location),
          const SizedBox(height: 14),
          SectionHeader(title: 'Communities', frequency: RefreshFrequency.live, subtitle: 'nach Groesse sortiert'),
          _buildCommunities(location),
        ],
      ),
    );
  }

  Widget _buildGraphTab(String location) {
    final svgUrl = ref.watch(graphiphySvgUrlProvider(location));
    final vizUrl = ref.watch(graphiphyVizUrlProvider(location));

    return Stack(
      children: [
        InteractiveViewer(
          minScale: 0.1,
          maxScale: 5.0,
          child: Center(
            child: SvgPicture.network(
              svgUrl,
              width: 2000,
              placeholderBuilder: (_) =>
                  const Center(child: CircularProgressIndicator()),
            ),
          ),
        ),
        Positioned(
          right: 12,
          bottom: 12,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton.small(
                heroTag: 'browser',
                onPressed: () => _openInBrowser(vizUrl),
                backgroundColor: AppTheme.violet,
                child: const Icon(Icons.open_in_browser, size: 18),
              ),
              const SizedBox(height: 4),
              Text('Browser',
                  style: TextStyle(
                      fontSize: 9,
                      color: AppTheme.violet.withValues(alpha: 0.7))),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _openInBrowser(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kann Browser nicht oeffnen: $url'),
          backgroundColor: AppTheme.red,
        ),
      );
    }
  }

  Widget _buildStats(String location) {
    final statsAsync = ref.watch(graphiphyStatsProvider(location));
    return statsAsync.when(
      data: (stats) => Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _StatsCard(label: 'Nodes', value: _fmtNum(stats.nodeCount), icon: Icons.circle_outlined, color: AppTheme.green),
          _StatsCard(label: 'Edges', value: _fmtNum(stats.edgeCount), icon: Icons.timeline, color: AppTheme.blue),
          _StatsCard(label: 'Communities', value: _fmtNum(stats.communityCount), icon: Icons.hub, color: AppTheme.violet),
          if (stats.fileTypes.isNotEmpty)
            ...stats.fileTypes.entries.map((e) => _StatsCard(
                  label: e.key,
                  value: _fmtNum(e.value),
                  icon: e.key == 'code'
                      ? Icons.code
                      : e.key == 'document'
                          ? Icons.description
                          : Icons.insert_drive_file,
                  color: AppTheme.gold,
                )),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Graph nicht verfuegbar', style: TextStyle(color: AppTheme.red)),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: 'Nodes durchsuchen...',
        hintStyle: const TextStyle(fontSize: 13, color: Colors.white38),
        prefixIcon: const Icon(Icons.search, size: 18),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 16),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
              )
            : null,
        filled: true,
        fillColor: AppTheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      onChanged: (v) => setState(() => _searchQuery = v),
      onSubmitted: (v) => setState(() => _searchQuery = v),
    );
  }

  Widget _buildGodNodes(String location) {
    final async = ref.watch(graphiphyGodNodesProvider(location));
    return async.when(
      data: (nodes) {
        if (nodes.isEmpty) return const SizedBox.shrink();
        final maxDeg = nodes.isNotEmpty ? nodes.first.degree.toDouble() : 1.0;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: nodes.take(10).map((n) {
                final ratio = maxDeg > 0 ? n.degree / maxDeg : 0.0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Icon(
                        _iconForFileType(n.fileType),
                        size: 14,
                        color: AppTheme.green.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(n.label,
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            LinearProgressIndicator(
                              value: ratio,
                              backgroundColor: AppTheme.dark,
                              color: AppTheme.green,
                              minHeight: 2,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${n.degree}',
                          style: const TextStyle(
                              fontSize: 11, color: Colors.white38)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildCommunities(String location) {
    final async = ref.watch(graphiphyCommunitiesProvider(location));
    return async.when(
      data: (communities) {
        if (communities.isEmpty) return const SizedBox.shrink();
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: communities.take(15).map((c) {
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: _CommunityBadge(id: c.id),
                  title: Text('#${c.id}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  subtitle: Text(c.topLabels.join(', '),
                      style: const TextStyle(fontSize: 10, color: Colors.white38),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: Text(_fmtNum(c.size),
                      style: const TextStyle(fontSize: 11, color: Colors.white54)),
                  onTap: () => _showCommunityNodes(location, c.id, c.topLabels),
                );
              }).toList(),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  void _showCommunityNodes(String location, int communityId, List<String> topLabels) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _CommunityDetailSheet(
        location: location,
        communityId: communityId,
        topLabels: topLabels,
      ),
    );
  }

  IconData _iconForFileType(String ft) {
    switch (ft) {
      case 'code':
        return Icons.code;
      case 'document':
        return Icons.description;
      case 'paper':
        return Icons.article;
      case 'concept':
        return Icons.lightbulb_outline;
      default:
        return Icons.circle_outlined;
    }
  }

  String _fmtNum(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}

class _StatsCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatsCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(height: 4),
              Text(value,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color)),
              Text(label,
                  style: const TextStyle(fontSize: 10, color: Colors.white38)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommunityBadge extends StatelessWidget {
  final int id;
  const _CommunityBadge({required this.id});

  @override
  Widget build(BuildContext context) {
    final colors = [
      AppTheme.green,
      AppTheme.blue,
      AppTheme.violet,
      AppTheme.gold,
      AppTheme.red,
    ];
    final c = colors[id % colors.length];
    return CircleAvatar(
      radius: 12,
      backgroundColor: c.withValues(alpha: 0.2),
      child: Text('${id % 100}',
          style: TextStyle(fontSize: 9, color: c, fontWeight: FontWeight.w600)),
    );
  }
}

class _CommunityDetailSheet extends ConsumerWidget {
  final String location;
  final int communityId;
  final List<String> topLabels;

  const _CommunityDetailSheet({
    required this.location,
    required this.communityId,
    required this.topLabels,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(graphiphyCommunityNodesProvider(
        (location: location, communityId: communityId)));

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, scrollController) => Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Community #$communityId',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(topLabels.join(' · '),
                    style: const TextStyle(
                        fontSize: 11, color: Colors.white38)),
                const Divider(height: 20),
              ],
            ),
          ),
          Expanded(
            child: async.when(
              data: (nodes) => ListView.builder(
                controller: scrollController,
                itemCount: nodes.length,
                itemBuilder: (_, i) {
                  final n = nodes[i];
                  return ListTile(
                    dense: true,
                    leading: Icon(
                      n.fileType == 'code'
                          ? Icons.code
                          : n.fileType == 'document'
                              ? Icons.description
                              : Icons.circle_outlined,
                      size: 16,
                      color: AppTheme.green.withValues(alpha: 0.5),
                    ),
                    title: Text(n.label,
                        style: const TextStyle(fontSize: 12),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    subtitle: Text(
                      '${n.sourceFile}  ·  ${n.degree} edges',
                      style: const TextStyle(fontSize: 10),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Center(child: Text('Fehler beim Laden')),
            ),
          ),
        ],
      ),
    );
  }
}
