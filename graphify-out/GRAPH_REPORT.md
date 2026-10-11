# Graph Report - missioncontrol-app  (2026-10-11)

## Corpus Check
- 58 files · ~25,195 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 17 file(s) not represented in the graph (top: .xml 7, (none) 5, .properties 2)

## Summary
- 734 nodes · 1073 edges · 45 communities (32 shown, 13 thin omitted)
- Extraction: 98% EXTRACTED · 2% INFERRED · 0% AMBIGUOUS · INFERRED: 22 edges (avg confidence: 0.94)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `2d593049`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Mission Control App – Projektanweisungen
- app.dart
- graphiphy_page.dart
- overview_page.dart
- missioncontrol_service_history.dart
- missioncontrol_provider.dart
- missioncontrol_live.dart
- live_page.dart
- missioncontrol.py
- my_application.cc
- api_config.dart
- missioncontrol_system.dart
- missioncontrol_graphiphy.dart
- theme.dart
- _parse_system_from_md
- disk_bar.dart
- main.py
- missioncontrol_code_quality.dart
- system_page.dart
- locationProvider
- health_score_card.dart
- StatelessWidget
- reports_page.dart
- ../config/theme.dart
- code_quality_page.dart
- refresh_badge.dart
- vm_detail_card.dart
- package:flutter_riverpod/flutter_riverpod.dart
- vm_ring_card.dart
- deploy.sh
- service_matrix.dart
- package:flutter/material.dart
- update.sh
- widget_test.dart
- FlutterActivity
- missioncontrol_app
- mission-control-backend

## God Nodes (most connected - your core abstractions)
1. `Mission Control App – Projektanweisungen` - 19 edges
2. `locationProvider` - 17 edges
3. `Session-Log: 2026-05-27` - 12 edges
4. `_GraphiphyPageState` - 11 edges
5. `get_live()` - 10 edges
6. `_graph_path()` - 10 edges
7. `_get_graph_stats()` - 10 edges
8. `_parse_system_from_md()` - 8 edges
9. `get_system()` - 8 edges
10. `_build_system_response()` - 8 edges

## Surprising Connections (you probably didn't know these)
- `_periodic_service_history()` --calls--> `_collect_service_history()`  [EXTRACTED]
  backend/app/main.py → backend/app/routers/missioncontrol.py
- `get_overview()` --uses--> `MissioncontrolOverview`  [INFERRED]
  backend/app/routers/missioncontrol.py → backend/app/schemas.py
- `get_system()` --uses--> `MissioncontrolSystem`  [INFERRED]
  backend/app/routers/missioncontrol.py → backend/app/schemas.py
- `get_code_quality()` --uses--> `MissioncontrolCodeQuality`  [INFERRED]
  backend/app/routers/missioncontrol.py → backend/app/schemas.py
- `get_live()` --uses--> `LiveHeartbeat`  [INFERRED]
  backend/app/routers/missioncontrol.py → backend/app/schemas.py

## Import Cycles
- None detected.

## Communities (45 total, 13 thin omitted)

### Community 0 - "Mission Control App – Projektanweisungen"
Cohesion: 0.04
Nodes (48): Abhängigkeiten zum trading-app Backend, Android, Android APK, Architektur, Architektur-Entscheidungen, Backend-Endpoints (zu implementieren in trading-app/backend), Backend (Server: LXC 104 trading-app), Backend (trading-app) (+40 more)

### Community 1 - "app.dart"
Cohesion: 0.16
Nodes (5): build, location, MissionControlApp, criticalCountProvider, textScaleProvider

### Community 2 - "graphiphy_page.dart"
Cohesion: 0.05
Nodes (44): build, _buildCommunities, _buildGodNodes, _buildGraphTab, _buildOverviewTab, _buildSearchBar, _buildStats, color (+36 more)

### Community 3 - "overview_page.dart"
Cohesion: 0.06
Nodes (28): build, _buildAlerts, _buildDiskSection, _buildHealthScore, _buildHealthTrend, _buildServiceHistory, _buildServiceSectionOverview, _buildStatusStrip (+20 more)

### Community 4 - "missioncontrol_service_history.dart"
Cohesion: 0.11
Nodes (16): avgMs, collectedAt, fromJson, history, host, isOnline, maxMs, name (+8 more)

### Community 5 - "missioncontrol_provider.dart"
Cohesion: 0.07
Nodes (17): main, apiKey, dio, dioProvider, fromJson, response, _check, checkOnce (+9 more)

### Community 6 - "missioncontrol_live.dart"
Cohesion: 0.07
Nodes (27): auditHealth, calculatedAt, fromJson, level, score, serviceHealth, vmHealth, date (+19 more)

### Community 7 - "live_page.dart"
Cohesion: 0.06
Nodes (26): GraphiphyPage, _anim, beat, build, _buildHeartbeatGrid, _buildResponseChart, _buildServiceChecks, _buildTimestamp (+18 more)

### Community 8 - "missioncontrol.py"
Cohesion: 0.05
Nodes (77): _build_community_index(), _build_degree_index(), _build_overview(), _build_system_response(), _collect_service_history(), _compute_score_from_text(), _empty_system(), _extract_report_title() (+69 more)

### Community 9 - "my_application.cc"
Cohesion: 0.08
Nodes (14): fl_register_plugins(), main(), first_frame_cb(), my_application_activate(), my_application_class_init(), my_application_dispose(), my_application_init(), my_application_local_command_line() (+6 more)

### Community 10 - "api_config.dart"
Cohesion: 0.08
Nodes (22): apiBaseUrl, ApiConfig, baseUrl, codeQualityUrl, criticalCountUrl, graphiphyCommunitiesUrl, graphiphyCommunityUrl, graphiphyGodNodesUrl (+14 more)

### Community 11 - "missioncontrol_system.dart"
Cohesion: 0.06
Nodes (34): autoFixes, backups, BackupStatus, cpuPercent, detail, details, diskPercent, fromJson (+26 more)

### Community 12 - "missioncontrol_graphiphy.dart"
Cohesion: 0.05
Nodes (34): community, communityCount, degree, edgeCount, fileType, fileTypes, fromJson, GraphiphyCommunity (+26 more)

### Community 13 - "theme.dart"
Cohesion: 0.11
Nodes (15): AppTheme, blue, cardSurface, chartColors, dark, darkTheme, gold, green (+7 more)

### Community 14 - "_parse_system_from_md"
Cohesion: 0.10
Nodes (11): _extract_vm_num(), _parse_backups_from_text(), _parse_disk_map_from_text(), _parse_fixes_from_text(), _parse_host_from_text(), _parse_kernel_map_from_text(), _parse_known_services(), _parse_services_from_text() (+3 more)

### Community 15 - "disk_bar.dart"
Cohesion: 0.29
Nodes (5): _barColor, build, DiskBar, label, percent

### Community 16 - "main.py"
Cohesion: 0.12
Nodes (5): Settings, api_key_middleware(), health(), _periodic_service_history(), startup()

### Community 17 - "missioncontrol_code_quality.dart"
Cohesion: 0.11
Nodes (17): autoFixed, autoFixResults, bareExcepts, description, expected, Finding, findings, fromJson (+9 more)

### Community 18 - "system_page.dart"
Cohesion: 0.14
Nodes (12): build, _buildBackupSection, _buildHostSection, _buildServiceSection, _buildUpdateSection, _buildVmSection, _gaugeChart, _infoRow (+4 more)

### Community 19 - "locationProvider"
Cohesion: 0.22
Nodes (12): _LocationToggle, build, CodeQualityPage, _startAutoRefresh, build, _ReportDetailPage, ReportsPage, _ReportTile (+4 more)

### Community 20 - "health_score_card.dart"
Cohesion: 0.25
Nodes (6): MissioncontrolHealth, build, health, HealthScoreCard, _scoreColor, _subScore

### Community 21 - "StatelessWidget"
Cohesion: 0.25
Nodes (7): _CommunityBadge, _StatsCard, _HeartbeatCard, _JsonRenderer, _MarkdownRenderer, RefreshBadge, SectionHeader

### Community 22 - "reports_page.dart"
Cohesion: 0.17
Nodes (6): content, displayDate, filename, location, report, _showReport

### Community 23 - "../config/theme.dart"
Cohesion: 0.25
Nodes (4): build, finding, FindingCard, _severityColor

### Community 24 - "code_quality_page.dart"
Cohesion: 0.18
Nodes (8): _buildAutoFixSummary, _buildContent, _buildFindingsSection, _buildOpenPorts, _buildSummaryCards, _iconForSection, _severityBadge, _statCard

### Community 25 - "refresh_badge.dart"
Cohesion: 0.20
Nodes (8): build, customLabel, _formatReportTime, frequency, lastReport, RefreshFrequency, subtitle, title

### Community 26 - "vm_detail_card.dart"
Cohesion: 0.25
Nodes (6): build, _metricBar, _tag, update, vm, VmDetailCard

### Community 27 - "package:flutter_riverpod/flutter_riverpod.dart"
Cohesion: 0.29
Nodes (4): dio, fromJson, list, response

### Community 28 - "vm_ring_card.dart"
Cohesion: 0.29
Nodes (4): build, _legend, vm, VmRingCard

### Community 30 - "service_matrix.dart"
Cohesion: 0.33
Nodes (4): build, _serviceChip, ServiceMatrix, services

### Community 31 - "package:flutter/material.dart"
Cohesion: 0.29
Nodes (5): build, _color, HealthDot, size, status

### Community 36 - "update.sh"
Cohesion: 0.83
Nodes (3): do_backend(), do_frontend(), update.sh script

## Knowledge Gaps
- **313 isolated node(s):** `mission-control-backend`, `location`, `ApiConfig`, `apiBaseUrl`, `baseUrl` (+308 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 461 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **13 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `MissioncontrolHealth` connect `health_score_card.dart` to `missioncontrol_live.dart`?**
  _High betweenness centrality (0.022) - this node is a cross-community bridge._
- **What connects `mission-control-backend`, `location`, `ApiConfig` to the rest of the system?**
  _313 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Mission Control App – Projektanweisungen` be split into smaller, more focused modules?**
  _Cohesion score 0.04081632653061224 - nodes in this community are weakly interconnected._
- **Why does `_GraphiphyPageState` connect `graphiphy_page.dart` to `locationProvider`, `live_page.dart`?**
  _High betweenness centrality (0.011) - this node is a cross-community bridge._
- **Should `graphiphy_page.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.05142857142857143 - nodes in this community are weakly interconnected._
- **Why does `locationProvider` connect `locationProvider` to `app.dart`, `graphiphy_page.dart`, `overview_page.dart`, `missioncontrol_provider.dart`, `live_page.dart`, `system_page.dart`?**
  _High betweenness centrality (0.008) - this node is a cross-community bridge._
- **Should `overview_page.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.05731707317073171 - nodes in this community are weakly interconnected._