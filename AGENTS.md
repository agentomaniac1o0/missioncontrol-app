# Monitoring App – Projektanweisungen

## Projektziel

Cross-Platform Monitoring App (FastAPI + Flutter) für Home Lab (pve-1) und Production Center.
Ersetzt Discord-Berichte und die Streamlit Mission Control durch eine native Flutter-App.

**Repo:** `~/monitoring-app/` (öffentlich auf GitHub)
**Backend:** Bestehender FastAPI-Backend in `~/trading-app/backend/` wird erweitert

## Architektur

```
┌─────────────────────────────────────────────────────┐
│  Flutter Frontend (Web + Mobile)                      │
│  monitoring-app/                                       │
│  Globaler Toggle: Home Lab ↔ Production Center        │
│  Tabs: Übersicht · System · Code Quality              │
│  Jeder Tab: statischer Report-Teil + Live-Health      │
└────────────────────────┬────────────────────────────┘
                         │ HTTP/JSON
┌────────────────────────▼────────────────────────────┐
│  FastAPI Backend (trading-app/backend)                │
│  Neue Router: /api/monitoring/                        │
│  Health-Check Hintergrund-Task (stündlich)            │
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

## Architektur-Entscheidungen (Grill-Me Session 2026-05-25)

| # | Entscheidung | Gewählt |
|---|-------------|---------|
| 1 | API-Ansatz | Bestehender FastAPI-Backend (trading-app) erweitert |
| 2 | Production-Center-Daten holen | Backend pullt per SSH von der Schaltzentrale |
| 3 | Monitoring-Umfang production-center | Gleicher Umfang wie Home Lab (eigene Crew existiert) |
| 4 | Datenformat | Strukturiertes JSON |
| 5 | JSON-Generierung | Crew schreibt JSON + Markdown |
| 6 | App-Integration | Separate Flutter-App (`monitoring-app`) |
| 7 | Standort-Toggle | Globaler Switch in AppBar + gleiche Tabs für beide |
| 8 | Tabs | Übersicht, System, Code Quality (Monitoring-Kern) |
| 9 | Backend-Endpoints | Sammel-Endpoint pro Tab: `/api/monitoring/{location}/{tab}` |
| 10 | Live-Daten | Backend macht eigene Service-Health-Checks |
| 11 | RPi-Aufteilung | RPi nur externe Pings, Backend alle internen Services |

## Datenfluss

### Statische Daten (täglich, aus Reports)
```
monitoring_crew.py → report_YYYY-MM-DD.json → /api/monitoring/{location}/overview
                    → report_YYYY-MM-DD.json → /api/monitoring/{location}/system
                    → security_audit_log.json → /api/monitoring/{location}/code-quality
```

### Live-Daten (stündlich, Health Checks)
```
Backend Background Task → ping + port-check aller Services
RPi Watchdog → externe Ping-Daten per SSH-Pull
→ /api/monitoring/{location}/live
```

## Backend-Endpoints (zu implementieren in trading-app/backend)

| Endpoint | Beschreibung | Quelle |
|----------|-------------|--------|
| `GET /api/monitoring/{location}/overview` | Gesamtstatus, Disks, Crew-Status, Alerts | Report-JSON |
| `GET /api/monitoring/{location}/system` | Proxmox-Host, VMs, Services, Backups | Report-JSON |
| `GET /api/monitoring/{location}/code-quality` | Security-Audit, Code-Review-Findings | Audit-JSON |
| `GET /api/monitoring/{location}/live` | Health-Checks, Heartbeat, RPi-Pings | Background-Task + RPi |

`{location}` = `home-lab` | `production-center`

## Flutter App Tabs

### Tab 1 – Übersicht
- Gesamtstatus (OK / Warning / Critical) mit Ampel
- Letzter Report-Zeitstempel
- Disk-Usage aller Systeme (Balken mit %)
- Crew-Run-Status
- Aktive Alerts/Warnings
- **Live:** Heartbeat-Indikatoren (grün/gelb/rot)

### Tab 2 – System
- Proxmox-Host-Status (CPU, RAM, Uptime)
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

## Technologie-Stack

| Komponente | Technologie |
|-----------|-------------|
| Frontend | Flutter 3.24+ |
| State | Riverpod 2.5+ |
| HTTP | Dio 5.0+ |
| Charts | fl_chart 0.69+ |
| Backend | FastAPI 0.115+ (in trading-app/backend) |
| Health Checks | asyncio Background Tasks |
| SSH-Pull | asyncssh / paramiko |

## CI-Farben (wie trading-app)

| Farbe | Hex | Verwendung |
|-------|-----|-----------|
| Grün/Positiv | `#00b09b` | OK-Status, Online, Grün |
| Rot/Negativ | `#e74c3c` | Critical, Offline, Fehler |
| Gold | `#f0a500` | Warnings, Alerts |
| Blau | `#3498db` | Info, Sekundär |
| Violett | `#9b59b6` | Highlights |
| Dunkel | `#0d1117` | Hintergrund |

## Projektstruktur (geplant)

```
monitoring-app/
├── AGENTS.md
├── ROADMAP.md
├── .gitignore
├── backend/                    # Nur Health-Check-Task (Rest in trading-app/backend)
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
│       │   ├── monitoring_overview.dart
│       │   ├── monitoring_system.dart
│       │   ├── monitoring_code_quality.dart
│       │   └── monitoring_live.dart
│       ├── providers/
│       │   ├── monitoring_provider.dart
│       │   └── live_provider.dart
│       ├── pages/
│       │   ├── overview_page.dart
│       │   ├── system_page.dart
│       │   └── code_quality_page.dart
│       └── widgets/
│           ├── ampel_indicator.dart
│           ├── health_dot.dart
│           ├── disk_bar.dart
│           ├── vm_card.dart
│           └── finding_card.dart
└── deploy/
    └── flatpak.yml
```

## Offen (Phase 1)

- [ ] Projekt-Setup: GitHub-Repo, AGENTS.md, Verzeichnisstruktur
- [ ] JSON-Schema für Monitoring-Reports definieren
- [ ] Monitoring Crews: JSON-Output parallel zu Markdown (beide Maschinen)
- [ ] Backend: Neue Router `/api/monitoring/` in trading-app/backend
- [ ] Backend: Health-Check Background-Task
- [ ] Backend: SSH-Pull vom Production Center
- [ ] Flutter: Projekt-Scaffold (flutter create)
- [ ] Flutter: Globaler Toggle + 3-Tab-Navigation
- [ ] Flutter: Übersicht-Tab
- [ ] Flutter: System-Tab
- [ ] Flutter: Code-Quality-Tab
- [ ] Flutter: Live-Health-Indikatoren
- [ ] Deployment: APK + Flatpak

## Was NICHT hier rein gehört

- Mission Control Dashboard → bleibt in `~/mission-control/` (Streamlit)
- Discord-Berichte → bleiben als Fallback
- Trading-Analysen → bleiben in `~/trading-app/`
- Token-Verbrauch → bleibt in Streamlit
- CronMaster → bleibt auf LXC 102
