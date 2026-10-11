from pydantic import BaseModel, Field

class HealthScore(BaseModel):
    score: int
    level: str
    vm_health: float
    service_health: float
    audit_health: float
    calculated_at: str

class MissioncontrolOverview(BaseModel):
    status: str
    last_report: str
    health_score: int
    disk_usage: dict[str, float]
    crew_status: str
    active_alerts: list[str]

class VmStatus(BaseModel):
    name: str
    status: str
    cpu_percent: float
    ram_percent: float
    disk_percent: float
    uptime_days: int

class ServiceStatus(BaseModel):
    name: str
    online: bool
    port: int
    host: str = "pve-1"

class ProxmoxHost(BaseModel):
    cpu_percent: float
    ram_percent: float
    uptime: str
    kernel_version: str
    updates_pending: bool

class BackupStatus(BaseModel):
    vm_name: str
    last_backup: str
    success: bool
    detail: str = ""

class SysUpdate(BaseModel):
    system: str
    updates_pending: int
    reboot_needed: bool
    kernel: str
    auto_fixes: list[str]
    details: list[str] = []
    warnings: list[str] = []

class MissioncontrolSystem(BaseModel):
    host: ProxmoxHost
    vms: list[VmStatus]
    services: list[ServiceStatus]
    backups: list[BackupStatus]
    updates: list[SysUpdate] = []
    last_report: str = ""

class Finding(BaseModel):
    severity: str
    title: str
    description: str
    auto_fixed: bool

class OpenPort(BaseModel):
    port: int
    service: str
    expected: bool

class MissioncontrolCodeQuality(BaseModel):
    findings: list[Finding]
    open_ports: list[OpenPort]
    hardcoded_secrets: int
    bare_excepts: int
    auto_fix_results: list[str]
    last_report: str = ""

class LiveHeartbeat(BaseModel):
    system: str
    status: str

class LiveServiceCheck(BaseModel):
    service: str
    online: bool
    response_time_ms: int

class MissioncontrolLive(BaseModel):
    heartbeats: list[LiveHeartbeat]
    service_checks: list[LiveServiceCheck]
    timestamp: str

class GraphiphyStats(BaseModel):
    node_count: int
    edge_count: int
    community_count: int
    file_types: dict[str, int]

class GraphiphyGodNode(BaseModel):
    label: str
    degree: int
    community: int
    file_type: str

class GraphiphyNode(BaseModel):
    label: str
    file_type: str
    community: int
    source_file: str
    degree: int
    id: str = ""

class GraphiphyCommunity(BaseModel):
    id: int
    size: int
    top_labels: list[str]

class ReportListItem(BaseModel):
    filename: str
    date: str
    size_bytes: int
    title: str = ""  # Optional title field

class ReportDetail(BaseModel):
    filename: str
    date: str
    content: str
    format: str  # "markdown" or "json"

class HealthTrendPoint(BaseModel):
    date: str
    score: int

class LiveCriticalCount(BaseModel):
    heartbeat_critical: int
    services_offline: int
    total: int

class ServiceHistoryPoint(BaseModel):
    timestamp: str
    response_time_ms: int
    online: bool

class ServiceHistorySeries(BaseModel):
    name: str
    host: str
    port: int
    history: list[ServiceHistoryPoint]

class ServiceHistoryResponse(BaseModel):
    services: list[ServiceHistorySeries]
    collected_at: str
