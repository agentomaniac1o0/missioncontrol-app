# Mission Control App – Projektanweisungen

## Projektziel

Cross-Platform Mission Control App (FastAPI + Flutter) für Home Lab (pve-1) und Production Center (Dell OptiPlex).
Ersetzt Discord-Berichte und das Streamlit Mission Control Dashboard durch eine native Flutter-App mit Push-Benachrichtigungen.

**Repo:** `~/missioncontrol-app/` (öffentlich auf GitHub)
**Backend:** Bestehender FastAPI-Backend in `~/trading-app/backend/` wird erweitert

## Architektur

```
┌─────────────────────────────────────────────────────┐
│  Flutter Frontend (Linux Desktop + Android)           │
│  missioncontrol-app/                                   │
│  Globaler Toggle: Home Lab ↔ Production Center        │
│  Tabs: Übersicht · System · Code Quality · Graphiphy · Live │
│  Health Score + grafische Darstellung aller Komp.     │
│  Push-Benachrichtigungen bei Critical-Issues          │
└────────────────────────┬────────────────────────────┘
                         │ HTTP/JSON
┌────────────────────────▼────────────────────────────┐
│  FastAPI Backend (trading-app/backend)                │
│  Neue Router: /api/missioncontrol/                    │
│  Health-Check Hintergrund-Task (stündlich)            │
│  Health Score Berechnung                              │
│  SSH-Pull vom production-center                       │
│  RPi-Watchdog: externe Ping-Daten per SSH             │
└──┬──────────────────────┬───────────────────────────┘
   │                      │
   ▼                      ▼
┌──────────────┐  ┌──────────────────────┐
│  Home Lab    │  │  Production Center   │
│  (pve-1)     │  │  (Dell OptiPlex)     │
│  Monitoring  │  │  Monitoring Crew     │
│  Crew → JSON │  │  → JSON + MD         │
│  + MD        │  │  SSH-Pull ← Backend  │
└──────────────┘  └──────────────────────┘
```

## Architektur-Entscheidungen

| # | Entscheidung | Gewählt |
|---|-------------|---------|
| 1 | API-Ansatz | Bestehender FastAPI-Backend (trading-app) erweitert |
| 2 | Production-Center-Daten holen | Backend pullt per SSH von der Schaltzentrale |
| 3 | Monitoring-Umfang production-center | Gleicher Umfang wie Home Lab (eigene Crew existiert) |
| 4 | Datenformat | Strukturiertes JSON |
| 5 | JSON-Generierung | Crew schreibt JSON + Markdown |
| 6 | App-Integration | Separate Flutter-App (`missioncontrol-app`) |
| 7 | Standort-Toggle | Globaler Switch in AppBar + gleiche Tabs für beide |
| 8 | Tabs | Übersicht, System, Code Quality, Graphiphy, Live |
| 9 | Backend-Endpoints | Sammel-Endpoint pro Tab: `/api/missioncontrol/{location}/{tab}` |
| 10 | Live-Daten | Backend macht eigene Service-Health-Checks |
| 11 | RPi-Aufteilung | RPi nur externe Pings, Backend alle internen Services |
| 12 | API-Kosten-Tracking | **Raus** — OpenCode Go-Kosten lokal nicht trackbar |
| 13 | Push-Benachrichtigungen | Linux Desktop + Android, auch im Hintergrund |
| 14 | Push-Architektur | Workmanager + flutter_local_notifications (kein externer Dienst) |
| 15 | Health Score | Dedizierter Endpoint `/api/missioncontrol/{location}/health`, Backend berechnet |
| 16 | Discord | Wird später stillgelegt, Push + Nextcloud als Ersatzkanäle |
| 17 | Nextcloud | Crew schreibt automatisch per WebDAV, App liest nur via API |

## Backend-Endpoints (zu implementieren in trading-app/backend)

| Endpoint | Beschreibung | Quelle |
|----------|-------------|--------|
| `GET /api/missioncontrol/{location}/overview` | Gesamtstatus, Health Score, Disks, Crew-Status, Alerts | Report-JSON |
| `GET /api/missioncontrol/{location}/system` | Proxmox-Host, VMs, Services, Backups | Report-JSON |
| `GET /api/missioncontrol/{location}/code-quality` | Security-Audit, Code-Review-Findings | Audit-JSON |
| `GET /api/missioncontrol/{location}/live` | Health-Checks, Heartbeat, RPi-Pings | Background-Task + RPi |
| `GET /api/missioncontrol/{location}/health` | Health Score (0–100), aggregiert aus VM/Service/Audit-Status | Background-Task |
| `GET /api/missioncontrol/{location}/graphiphy/stats` | Node/Edge/Community-Counts, File-Types | graph.json |
| `GET /api/missioncontrol/{location}/graphiphy/god-nodes?top_n=` | Meist-verbundene Nodes nach Degree | graph.json |
| `GET /api/missioncontrol/{location}/graphiphy/communities?limit=&offset=` | Community-Liste nach Groesse | graph.json |
| `GET /api/missioncontrol/{location}/graphiphy/community/{id}` | Nodes einer Community | graph.json |
| `GET /api/missioncontrol/{location}/graphiphy/search?q=` | Node-Suche | graph.json |
| `GET /api/missioncontrol/{location}/graphiphy/viz` | graph.html (interaktiver D3.js-Graph) | graphify-out/graph.html |
| `POST /api/missioncontrol/{location}/graphiphy/viz/refresh` | graph.html regenerieren via graphify | graphify CLI |

`{location}` = `home-lab` | `production-center`

## Implementierungs-Reihenfolge

1. **Phase 1 — Home Lab:** Alles für home-lab Standort aufbauen, production-center als Platzhalter
2. **Phase 2 — Production Center:** production-center einbinden, sobald der andere Rechner bereit ist

## Flutter App Tabs

### Tab 1 – Übersicht
- **Health Score** (0–100) — großer, zentraler Indikator mit Farbverlauf (rot → gold → grün)
- Gesamtstatus (OK / Warning / Critical)
- Letzter Report-Zeitstempel
- **Grafische Übersicht:**
  - Disk-Usage aller Systeme (Balken mit %)
  - VM/LXC-Grid mit Status-Indikatoren (kompakt)
  - Service-Matrix (alle Services als grüne/gelbe/rote Punkte)
- Crew-Run-Status
- Aktive Alerts/Warnings
- **Live:** Heartbeat-Indikatoren

### Tab 2 – System
- Proxmox-Host-Status (CPU, RAM, Uptime) mit Charts
- VM/LXC-Liste mit Status, CPU, RAM, Disk
- Service-Status (Apache, MariaDB, Ghost, FastSD, ComfyUI, etc.)
- Backup-Status (letztes erfolgreiches Backup pro VM)
- Kernel-Versionen, Updates pending
- **Live:** Service-Port-Checks

### Tab 3 – Code Quality
- Security-Audit-Findings (kritisch/hoch/mittel)
- Code-Review-Ergebnisse
- Offene Ports, harte Secrets, bare excepts
- Auto-Fix-Ergebnisse (was wurde automatisch behoben)

### Tab 4 – Graphiphy
- **Stats**: Node/Edge/Community-Counts, File-Type-Verteilung
- **God Nodes**: Top-10 meist-verbundene Knoten mit Degree-Anzeige
- **Communities**: Nach Groesse sortiert, antippbar mit Bottom-Sheet-Detail
- **Suche**: Freitext-Suche nach Node-Labels
- **Graph-Visualisierung**: graph.html per "Open in Browser"-Button (D3.js, interaktiv)
- Datenquelle: `~/graphify-out/graph.json` → Backend

### Tab 5 – Live
- **Heartbeat Grid**: Pings der Systeme (RPi-Watchdog) mit Puls-Animation
- **Service Status**: Port-Checks mit Response-Time-Balken, farbcodiert
- **Response-Time Chart**: fl_chart BarChart der Service-Antwortzeiten
- **Auto-Refresh**: Alle 30 Sekunden (Timer + Provider-Invalidation)
- Datenquelle: `/api/missioncontrol/{location}/live`

## Datenquellen & Ablage

### Statische Daten (täglich, aus Reports)
```
monitoring_crew.py → report_YYYY-MM-DD.json → /api/missioncontrol/{location}/overview
                    → report_YYYY-MM-DD.json → /api/missioncontrol/{location}/system
                    → security_audit_log.json → /api/missioncontrol/{location}/code-quality
```

### Live-Daten (stündlich, Health Checks)
```
Backend Background Task → ping + port-check aller Services
RPi Watchdog → externe Ping-Daten per SSH-Pull
→ /api/missioncontrol/{location}/live
→ /api/missioncontrol/{location}/health
```

### Nextcloud (Backup/Archiv)
- Crew schreibt Reports automatisch per WebDAV nach Nextcloud
- Dient als Fallback/Nachschlag, falls die App nicht verfügbar ist
- Kein Upload-Code in der App nötig

### Graphify (Knowledge Graph)
- `graph.json` liegt in `~/graphify-out/` (509k Nodes, 654k Edges, 33k Communities)
- Backend liest `graph.json` direkt, cached im RAM, erkennt mtime-Änderungen
- `graph.html` zeigt Top-500 Communities als aggregierten Meta-Graph (D3.js)
- Nach Code-Änderungen: `graphify update . && graphify cluster-only .` → HTML + JSON aktualisiert
- Für grosse Graphen (>5000 Nodes): `GRAPHIFY_VIZ_NODE_LIMIT` env var setzen
- App öffnet graph.html via System-Browser (`url_launcher`)

## Push-Benachrichtigungen

- `flutter_local_notifications` für lokale Notifications
- `workmanager` für periodische Background-Tasks (Android)
- Polling des `/live`-Endpoints, Trigger bei Critical-Findings
- Funktioniert auf Linux Desktop und Android

## Technologie-Stack

| Komponente | Technologie |
|-----------|-------------|
| Frontend | Flutter 3.24+ |
| State | Riverpod 2.5+ |
| HTTP | Dio 5.0+ |
| Charts | fl_chart 0.69+ |
| Push | flutter_local_notifications + workmanager |
| Backend | FastAPI 0.115+ (in trading-app/backend) |
| Health Checks | asyncio Background Tasks |
| SSH-Pull | asyncssh / paramiko |

## CI-Farben

| Farbe | Hex | Verwendung |
|-------|-----|-----------|
| Grün/Positiv | `#00b09b` | OK-Status, Online, Gesund |
| Rot/Negativ | `#e74c3c` | Critical, Offline, Fehler |
| Gold | `#f0a500` | Warnings, Alerts |
| Blau | `#3498db` | Info, Sekundär |
| Violett | `#9b59b6` | Highlights |
| Dunkel | `#0d1117` | Hintergrund |

## Projektstruktur

```
missioncontrol-app/
├── AGENTS.md
├── .gitignore
├── backend/
│   └── health_checker.py
├── frontend/
│   ├── pubspec.yaml
│   └── lib/
│       ├── main.dart
│       ├── app.dart
│       ├── config/
│       │   ├── api_config.dart
│       │   └── theme.dart
│       ├── models/
│       │   ├── missioncontrol_overview.dart
│       │   ├── missioncontrol_system.dart
│       │   ├── missioncontrol_code_quality.dart
│       │   ├── missioncontrol_live.dart
│       │   ├── missioncontrol_health.dart
│       │   └── missioncontrol_graphiphy.dart
│       ├── providers/
│       │   ├── missioncontrol_provider.dart
│       │   ├── live_provider.dart
│       │   └── graphiphy_provider.dart
│       ├── pages/
│       │   ├── overview_page.dart
│       │   ├── system_page.dart
│       │   ├── code_quality_page.dart
│       │   ├── graphiphy_page.dart
│       │   └── live_page.dart
│       └── widgets/
│           ├── health_score_card.dart
│           ├── health_dot.dart
│           ├── disk_bar.dart
│           ├── vm_card.dart
│           ├── service_matrix.dart
│           └── finding_card.dart
└── deploy/
    └── flatpak.yml
```

## Phase 1 – TODO

- [x] Projekt-Setup: GitHub-Repo, AGENTS.md, Verzeichnisstruktur
- [ ] Projekt umbenannt: monitoring-app → missioncontrol-app
- [ ] Altes mission-control Streamlit-Dashboard archiviert
- [ ] JSON-Schema für Monitoring-Reports definieren
- [ ] Monitoring Crews: JSON-Output parallel zu Markdown (Home Lab)
- [ ] Backend: Neue Router `/api/missioncontrol/` in trading-app/backend
- [ ] Backend: Health-Check Background-Task
- [ ] Backend: Health Score Berechnung
- [ ] Backend: Production Center Platzhalter-Endpoints
- [ ] Flutter: Projekt-Scaffold (flutter create)
- [ ] Flutter: Riverpod + Dio + fl_chart + flutter_local_notifications + workmanager
- [ ] Flutter: Globaler Toggle + 3-Tab-Navigation
- [ ] Flutter: Übersicht-Tab mit Health Score + grafischer Übersicht
- [ ] Flutter: System-Tab mit VM-Grid + Service-Matrix
- [ ] Flutter: Code-Quality-Tab
- [ ] Flutter: Live-Health-Indikatoren
- [ ] Flutter: Push-Benachrichtigungen (Polling + workmanager)
- [x] Deployment: APK + Flatpak
- [x] Update-Script: ./update.sh (Frontend) / --backend / --all

## Deployment & Updates

### Linux Desktop (CachyOS) – One-Command Update

```bash
cd ~/missioncontrol-app && ./update.sh
```

Das macht: `git pull` → `flutter build linux` → `flatpak-builder install`

**Optionen:**
| Befehl | Was passiert |
|--------|-------------|
| `./update.sh` | Nur Frontend (default) |
| `./update.sh --backend` | Nur Backend (SSH zu ai-agents, git pull + restart) |
| `./update.sh --all` | Backend + Frontend |

**Voraussetzungen:** `git clone https://github.com/agentomaniac1o0/missioncontrol-app.git` (einmalig)

### Android APK

APK liegt in Nextcloud: `Home Lab/Mission Control/missioncontrol-*.apk`

### Backend (Server: ai-agents VM 101)

Das Backend läuft in `~/trading-app/backend/`. Update via:

```bash
ssh ai-agents
cd ~/trading-app && git pull && systemctl --user restart trading-backend
```

## Session-Log: 2026-05-27

### Graphiphy + Live Tabs
- 2 neue Tabs: Graphiphy (Tab 4) + Live (Tab 5)
- **Graphiphy**: Stats, God Nodes, Communities, Suche, graph.html-Visualisierung per Browser
- **Live**: Heartbeat-Grid (Puls-Animation), Service-Checks mit Response-Times, fl_chart BarChart, 30s Auto-Refresh
- Neue Backend-Endpoints: `/graphiphy/stats`, `/god-nodes`, `/communities`, `/community/{id}`, `/search`, `/viz`, `/viz/refresh`
- `graph.html` generiert (Top-500 Communities, 442KB, aggregierte D3.js-Visualisierung)
- `url_launcher` statt `flutter_inappwebview` (kein Linux-Plugin)

### Berichte-Tab + Live-Upgrades
- **Berichte-Tab (Tab 6)**: Letzte 5 Monitoring-Reports mit Markdown-Detailansicht
- **Live-Endpoint**: Echte parallele Ping-Heartbeats (asyncio, max 3s) + TCP-Service-Checks
- **Hybrid-Checks**: TCP für externe Services (Apache, Ghost, ComfyUI), Report-basierte für interne (MariaDB, Redis)
- **Graph-Refresh-Button**: FAB im Graphiphy-Tab → `graphify update` + `cluster-only` + neues PNG
- **PNG-Rendering**: matplotlib spring_layout (200 DPI, Dark-Theme) statt fehlerhaftem SVG

### Push-Benachrichtigungen + Health-Trend
- **Push**: `flutter_local_notifications` auf Linux Desktop (5min Timer), Android ohne Workmanager (Startup-Crash)
- **Health-Trend**: 14-Tage fl_chart LineChart auf der Übersichts-Seite
- **Tab-Badge**: Roter Badge am Live-Tab bei kritischen Issues (Critical-Count)
- **Notification-Dedup**: Alarmiert nur bei neuen Issues, nicht wiederholt

### Android
- Workmanager komplett entfernt (Crash-Ursache: Background-Isolate + Dio-Inkompatibilität)
- `Platform.isAndroid` Guard: Keine Notification/Poller-Init auf Android
- APK in Nextcloud: `Home Lab/missioncontrol_app/`

### Bereinigung
- `flutter_svg` entfernt (ungenutzt nach PNG-Switch)
- `flutter_inappwebview` → `url_launcher` (Öffnet Graph im System-Browser)
- `update.sh`: SSH-Host auf IP `100.103.32.107` gefixt, `pip install networkx matplotlib` eingebaut

### Neue Dateien
- `models/missioncontrol_graphiphy.dart`, `models/missioncontrol_reports.dart`
- `providers/graphiphy_provider.dart`, `providers/reports_provider.dart`
- `pages/graphiphy_page.dart`, `pages/live_page.dart`, `pages/reports_page.dart`
- `services/notification_service.dart`

### Initial Setup & Rename
- monitoring-app → missioncontrol-app (komplettes Rebranding)
- Altes Streamlit Mission Control archiviert → `~/mission-control_old/`
- Grill-Me: 13 Architektur-Entscheidungen
- Neues GitHub-Repo: `agentomaniac1o0/missioncontrol-app`
- Altes Repo `agentomaniac1o0/monitoring-app` archiviert

### Flutter App
- Scaffold mit Riverpod + Dio + fl_chart + flutter_local_notifications + workmanager
- 3 Tabs: Übersicht (Health Score) · System · Code Quality
- Globaler Toggle Home Lab ↔ Production Center
- Dark Theme mit CI-Farben (#00b09b, #e74c3c, #f0a500, #3498db)
- Refresh-Badges: Täglich (gold), Stündlich (blau), Live (grün)
- Linux Release + Flatpak + Android APK Build

### Backend (trading-app)
- Router `/api/missioncontrol/` mit 5 Endpoints
- Markdown-Parser: VM/LXC/Service/Backup-Daten aus Crew-Report extrahiert
- Health Score (0-100) mit Sub-Scores (VMs, Services, Audit)
- Production-Center Platzhalter-Endpoints
- Pydantic-Settings: `extra='ignore'` für .env-Kompatibilität

### Monitoring Crew (agent-templates)
- `_build_missioncontrol_json()`: Strukturiertes JSON parallel zu Markdown
- JSON + MD beide nach Nextcloud hochgeladen
- LXC 104 (Trading App) in Report + Backup-Prompt aufgenommen
- JSON-Schema dokumentiert: `schema.json`

### Builds
| Platform | Status | Pfad |
|----------|--------|------|
| Linux (Flatpak) | ✅ | `flatpak run app.missioncontrol.MissionControlApp` |
| Android (APK) | ✅ | Nextcloud `Home Lab/Mission Control/` |
| Linux (Bundle) | ✅ | `frontend/build/linux/x64/release/bundle/` |

## Was NICHT hier rein gehört

- Streamlit Mission Control → archiviert in `~/mission-control_old/` (wird nach Migration gelöscht)
- Discord-Berichte → werden später stillgelegt
- Trading-Analysen → bleiben in `~/trading-app/`
- API-Kosten/Token-Tracking → nicht lokal trackbar (OpenCode Go)
- CronMaster → bleibt auf LXC 102
