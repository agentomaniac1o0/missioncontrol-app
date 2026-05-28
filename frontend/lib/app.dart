import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/theme.dart';
import 'pages/overview_page.dart';
import 'pages/system_page.dart';
import 'pages/code_quality_page.dart';
import 'pages/graphiphy_page.dart';
import 'pages/live_page.dart';
import 'pages/reports_page.dart';
import 'providers/missioncontrol_provider.dart';
import 'providers/live_provider.dart';
import 'providers/graphiphy_provider.dart';
import 'widgets/refresh_badge.dart';

class MissionControlApp extends ConsumerWidget {
  const MissionControlApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = ref.watch(locationProvider);
    final criticalAsync = ref.watch(criticalCountProvider(location));
    final criticalCount = criticalAsync.valueOrNull?.total ?? 0;
    final scale = ref.watch(textScaleProvider);

    final tabs = <Widget>[
      const Tab(text: 'Ubersicht'),
      const Tab(text: 'System'),
      const Tab(text: 'Code Quality'),
      const Tab(text: 'Graphiphy'),
      Tab(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Live'),
            if (criticalCount > 0) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: AppTheme.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('$criticalCount',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
      ),
      const Tab(text: 'Berichte'),
    ];

    return MaterialApp(
      title: 'Mission Control',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 6,
        child: Scaffold(
          appBar: AppBar(
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mission Control', style: TextStyle(fontSize: 18)),
                SizedBox(height: 2),
                Text(
                  'Daten: tägl. 03:00 (Monitoring Crew)  •  Live: stündl. Health Checks',
                  style: TextStyle(fontSize: 10, color: Colors.white30, fontWeight: FontWeight.normal),
                ),
              ],
            ),
            bottom: TabBar(
              tabs: tabs,
              isScrollable: true,
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.zoom_out, size: 20),
                tooltip: 'Verkleinern',
                onPressed: scale > 0.6
                    ? () => ref.read(textScaleProvider.notifier).state =
                        (scale - 0.1).clamp(0.5, 2.5)
                    : null,
              ),
              GestureDetector(
                onTap: () => ref.read(textScaleProvider.notifier).state = 1.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text('${(scale * 100).round()}%',
                      style: TextStyle(fontSize: 11,
                          color: scale == 1.0 ? Colors.white38 : AppTheme.gold)),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.zoom_in, size: 20),
                tooltip: 'Vergrößern',
                onPressed: scale < 2.4
                    ? () => ref.read(textScaleProvider.notifier).state =
                        (scale + 0.1).clamp(0.5, 2.5)
                    : null,
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.refresh, size: 20),
                tooltip: 'Daten aktualisieren',
                onPressed: () {
                  final loc = ref.read(locationProvider);
                  ref.invalidate(missioncontrollerOverviewProvider(loc));
                  ref.invalidate(missioncontrollerSystemProvider(loc));
                  ref.invalidate(missioncontrollerCodeQualityProvider(loc));
                  ref.invalidate(missioncontrollerHealthProvider(loc));
                  ref.invalidate(missioncontrollerLiveProvider(loc));
                  ref.invalidate(graphiphyStatsProvider(loc));
                  ref.invalidate(graphiphyGodNodesProvider(loc));
                  ref.invalidate(graphiphyCommunitiesProvider(loc));
                  ref.invalidate(criticalCountProvider(loc));
                  ref.invalidate(healthTrendProvider(loc));
                },
              ),
              _LocationToggle(location: location),
              const SizedBox(width: 8),
            ],
          ),
          body: MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
            child: const TabBarView(
              children: [
                OverviewPage(),
                SystemPage(),
                CodeQualityPage(),
                GraphiphyPage(),
                LivePage(),
                ReportsPage(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LocationToggle extends ConsumerWidget {
  final String location;

  const _LocationToggle({required this.location});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHomeLab = location == 'home-lab';

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isHomeLab ? 'HOME LAB' : 'PROD',
            style: const TextStyle(fontSize: 11, letterSpacing: 1),
          ),
          Switch(
            value: !isHomeLab,
            onChanged: (val) {
              ref.read(locationProvider.notifier).state =
                  val ? 'production-center' : 'home-lab';
            },
            activeTrackColor: AppTheme.green,
          ),
        ],
      ),
    );
  }
}
