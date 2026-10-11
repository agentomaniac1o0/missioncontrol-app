#!/bin/bash
# Deploy Mission Control Backend (VM 101 -> LXC 104)
# Nutzt den lxc104_monitor SSH-Key. Aufruf: bash ~/missioncontrol-app/backend/deploy.sh
set -e

SSH_KEY="$HOME/.ssh/lxc104_monitor"
TARGET="root@100.112.199.58"
DEST="/home/trading/trading-app/backend"
SRC="$(cd "$(dirname "$0")" && pwd)"

echo "[deploy] rsync app/ static/ pyproject.toml -> LXC 104"
rsync -az --delete -e "ssh -i $SSH_KEY" --exclude '__pycache__' "$SRC/app/" "$TARGET:$DEST/app/"
rsync -az --delete -e "ssh -i $SSH_KEY" --exclude '__pycache__' "$SRC/static/" "$TARGET:$DEST/static/"
rsync -az -e "ssh -i $SSH_KEY" "$SRC/pyproject.toml" "$TARGET:$DEST/"

echo "[deploy] chown + optional deps + restart"
ssh -i "$SSH_KEY" "$TARGET" "
    chown -R trading:trading $DEST/app $DEST/static $DEST/pyproject.toml
    su - trading -c 'export XDG_RUNTIME_DIR=/run/user/1000; export DBUS_SESSION_BUS_ADDRESS=unix:path=\$XDG_RUNTIME_DIR/bus; cd $DEST && .venv/bin/pip install -q networkx matplotlib 2>/dev/null; systemctl --user restart trading-backend.service; sleep 3; systemctl --user is-active trading-backend.service'
"

echo "[deploy] health check"
curl -sf --max-time 15 http://100.112.199.58:8000/api/health && echo " -> OK" || { echo " -> FEHLGESCHLAGEN"; exit 1; }
