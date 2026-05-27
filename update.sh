#!/bin/bash
# Mission Control – One-Command Update
# Legt Projektverzeichnisse im aktuellen Verzeichnis an, falls nicht vorhanden.
#
# Usage:  ./update.sh                → Frontend (Flutter → Flatpak)
#         ./update.sh --backend      → Backend (git pull + restart auf ai-agents via SSH)
#         ./update.sh --all          → Beides

set -e

BOLD="\033[1m"
GREEN="\033[32m"
YELLOW="\033[33m"
RESET="\033[0m"

API_URL="${API_BASE_URL:-http://100.103.32.107:8000}"
MISSION_DIR="${MISSION_DIR:-$HOME/missioncontrol-app}"
TRADING_DIR="${TRADING_DIR:-$HOME/trading-app}"
SERVER_SSH="${SERVER_SSH:-100.103.32.107}"

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
    flutter build linux --release --dart-define="API_BASE_URL=$API_URL"

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
    echo -e "${BOLD}${YELLOW}═══ Backend Update (ai-agents via SSH) ═══${RESET}"

    if ! ssh -q "$SERVER_SSH" exit 2>/dev/null; then
        echo "✗ Kein SSH-Zugang zu $SERVER_SSH – Update manuell auf dem Server ausführen:"
        echo "  ssh ai-agents"
        echo "  cd ~/trading-app && git pull && systemctl --user restart trading-backend"
        return 1
    fi

    ssh "$SERVER_SSH" "
        cd $TRADING_DIR && git pull && backend/.venv/bin/pip install networkx matplotlib -q --break-system-packages && systemctl --user restart trading-backend
    "
    sleep 2

    if ssh "$SERVER_SSH" "curl -sf $API_URL/api/health" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Backend OK${RESET}"
    else
        echo -e "${YELLOW}⚠ Backend antwortet nicht – prüfen mit: ssh ai-agents systemctl --user status trading-backend${RESET}"
    fi
}

case "$action" in
    --backend)  do_backend ;;
    --all)      do_backend; echo ""; do_frontend ;;
    *)          do_frontend ;;
esac
