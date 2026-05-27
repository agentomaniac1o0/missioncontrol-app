import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/theme.dart';
import 'pages/overview_page.dart';
import 'pages/system_page.dart';
import 'pages/code_quality_page.dart';
import 'providers/missioncontrol_provider.dart';
import 'widgets/refresh_badge.dart';

class MissionControlApp extends ConsumerWidget {
  const MissionControlApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = ref.watch(locationProvider);

    return MaterialApp(
      title: 'Mission Control',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 3,
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
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Ubersicht'),
                Tab(text: 'System'),
                Tab(text: 'Code Quality'),
              ],
            ),
            actions: [
              _LocationToggle(location: location),
              const SizedBox(width: 8),
            ],
          ),
          body: const TabBarView(
            children: [
              OverviewPage(),
              SystemPage(),
              CodeQualityPage(),
            ],
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
