#!/bin/bash
# Mission Control – One-Command Update
# Legt Projektverzeichnisse im aktuellen Verzeichnis an, falls nicht vorhanden.
#
# Usage:  ./update.sh                → Frontend (Flutter → Flatpak)
#         ./update.sh --backend      → Backend (git pull + restart auf ai-agents via SSH)
#         ./update.sh --all          → Beides

set -e

# Flutter PATH (CachyOS /opt/flutter default install)
if [ -d /opt/flutter/bin ]; then
    export PATH="/opt/flutter/bin:$PATH"
fi

BOLD="\033[1m"
GREEN="\033[32m"
YELLOW="\033[33m"
RESET="\033[0m"

API_URL="${API_BASE_URL:-http://100.112.199.58:8000}"
MISSION_DIR="${MISSION_DIR:-$HOME/missioncontrol-app}"
TRADING_DIR="${TRADING_DIR:-$HOME/trading-app}"
SERVER_SSH="${SERVER_SSH:-100.112.199.58}"
API_KEY="${API_KEY:-}"

action="${1:-frontend}"

# ── Frontend ──────────────────────────────────────────────────────────────
do_frontend() {
    echo -e "${BOLD}${GREEN}═══ Mission Control Frontend Update ═══${RESET}"

    if [ ! -d "$MISSION_DIR" ]; then
        echo "→ Klonen..."
        git clone https://github.com/agentomaniac1o0/missioncontrol-app.git "$MISSION_DIR"
    fi

    cd "$MISSION_DIR"
    echo "→ git pull..."
    git pull

    cd frontend
    echo "→ flutter build linux..."
    DART_DEFINES="--dart-define=API_BASE_URL=$API_URL"
    if [ -n "$API_KEY" ]; then
        DART_DEFINES="$DART_DEFINES --dart-define=API_KEY=$API_KEY"
    fi
    flutter build linux --release $DART_DEFINES

    echo "→ copy desktop integration..."
    cp "$MISSION_DIR/deploy/app.missioncontrol.MissionControlApp.desktop" "$MISSION_DIR/frontend/build/linux/x64/release/bundle/"
    cp "$MISSION_DIR/deploy/icon.png" "$MISSION_DIR/frontend/build/linux/x64/release/bundle/"

    cd ../deploy
    rm -rf .flatpak-builder
    echo "→ flatpak install..."
    flatpak-builder --repo=repo --force-clean --install --user build-dir \
        app.missioncontrol.MissionControlApp.yml

    echo "→ desktop entry..."
    mkdir -p $HOME/.local/share/applications
    cat > $HOME/.local/share/applications/missioncontrol.desktop << 'DESKTOP'
[Desktop Entry]
Name=Mission Control
Comment=Home Lab & Production Center Dashboard
Exec=flatpak run app.missioncontrol.MissionControlApp
Icon=app.missioncontrol.MissionControlApp
Terminal=false
Type=Application
Categories=System;Monitor;
StartupWMClass=missioncontrol_app
DESKTOP

    echo ""
    echo -e "${GREEN}✓ App bereit:${RESET} flatpak run app.missioncontrol.MissionControlApp"
    echo -e "  Commit: $(git -C "$MISSION_DIR" rev-parse --short HEAD)"
}

# ── Backend ──────────────────────────────────────────────────────────────
do_backend() {
    echo -e "${BOLD}${YELLOW}═══ Backend Update (VM 101 -> LXC 104 via rsync) ═══${RESET}"

    if [ ! -d "$MISSION_DIR/backend/app" ]; then
        echo "✗ Backend-Quellcode fehlt: $MISSION_DIR/backend/app"
        return 1
    fi

    # Deploy-Skript liegt im Repo und nutzt den lxc104_monitor-Key auf VM 101.
    # Von anderen Rechnern: erst git pull auf VM 101, dann dort ausführen.
    if [ -f "$HOME/.ssh/lxc104_monitor" ]; then
        bash "$MISSION_DIR/backend/deploy.sh"
    else
        echo "⚠ Kein lxc104_monitor-Key vorhanden – Backend-Deploy auf VM 101 ausführen:"
        echo "  ssh ai-agents 'cd ~/missioncontrol-app && git pull && bash backend/deploy.sh'"
        return 1
    fi

    if curl -sf --max-time 15 "$API_URL/api/health" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Backend OK${RESET}"
    else
        echo -e "${YELLOW}⚠ Backend antwortet nicht – prüfen: ssh ai-agents (LXC 104 trading-backend.service)${RESET}"
    fi
}

case "$action" in
    --backend)  do_backend ;;
    --all)      do_backend; echo ""; do_frontend ;;
    *)          do_frontend ;;
esac
