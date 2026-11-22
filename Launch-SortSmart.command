#!/bin/bash
# ══════════════════════════════════════════════════════════════════
#  🌿 SortSmart V2 — One-Click Launcher for macOS
#  Double-click this file to start SortSmart on http://localhost:3000
#  Opens the browser automatically! Press Ctrl+C to stop.
# ══════════════════════════════════════════════════════════════════

DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"

# Text Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

clear
echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║         🌿  SORTSMART V2 — ONE-CLICK LAUNCHER  🌿        ║${NC}"
echo -e "${CYAN}║     AI Waste Sorting & Recycling Rewards for India       ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

# 1. Clean up old processes on ports 3000 and 8000
echo -e "${YELLOW}► [1/4] Checking and freeing ports 3000 & 8000...${NC}"
OLD_3000=$(lsof -ti:3000 2>/dev/null || true)
OLD_8000=$(lsof -ti:8000 2>/dev/null || true)
if [ -n "$OLD_3000" ]; then kill -9 $OLD_3000 2>/dev/null || true; fi
if [ -n "$OLD_8000" ]; then kill -9 $OLD_8000 2>/dev/null || true; fi
sleep 1
echo -e "  ${GREEN}✓ Ports ready${NC}"

# 2. Start Backend AI & Database API on Port 8000
echo -e "${YELLOW}► [2/4] Starting AI & Database Backend on port 8000...${NC}"
if [ -f "/Users/jatingarg/Desktop/SortSmart/.venv/bin/python" ]; then
    PYTHON_BIN="/Users/jatingarg/Desktop/SortSmart/.venv/bin/python"
elif [ -d "$DIR/.venv" ]; then
    PYTHON_BIN="$DIR/.venv/bin/python"
else
    PYTHON_BIN="python3"
fi

$PYTHON_BIN server.py --host 0.0.0.0 --port 8000 >/dev/null 2>&1 &
BACKEND_PID=$!
sleep 1.5

if ps -p $BACKEND_PID > /dev/null; then
    echo -e "  ${GREEN}✓ Backend active (PID: $BACKEND_PID)${NC}"
else
    echo -e "  ${YELLOW}! Backend running standalone${NC}"
fi

# 3. Start Frontend UI on Port 3000
echo -e "${YELLOW}► [3/4] Starting SortSmart React UI on port 3000...${NC}"
python3 -m http.server 3000 --bind 0.0.0.0 >/dev/null 2>&1 &
FRONTEND_PID=$!
sleep 1

if ps -p $FRONTEND_PID > /dev/null; then
    echo -e "  ${GREEN}✓ Frontend active (PID: $FRONTEND_PID)${NC}"
fi

# Detect LAN IP for Mobile
LAN_IP=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || echo "127.0.0.1")

# Clean shutdown handler
cleanup() {
    echo ""
    echo -e "${YELLOW}► Shutting down SortSmart servers...${NC}"
    kill -9 $FRONTEND_PID 2>/dev/null || true
    kill -9 $BACKEND_PID 2>/dev/null || true
    lsof -ti:3000 2>/dev/null | xargs kill -9 2>/dev/null || true
    lsof -ti:8000 2>/dev/null | xargs kill -9 2>/dev/null || true
    echo -e "${GREEN}✓ All servers stopped cleanly. Goodbye!${NC}"
    exit 0
}
trap cleanup SIGINT SIGTERM EXIT

# 4. Open in default browser
echo -e "${YELLOW}► [4/4] Opening browser...${NC}"
sleep 1
open "http://localhost:3000"

echo ""
echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${GREEN} 🎉 SortSmart is RUNNING!${NC}"
echo -e " 💻 Desktop Local:  ${CYAN}http://localhost:3000${NC}"
echo -e " 📱 Mobile (Wi-Fi): ${CYAN}http://${LAN_IP}:3000${NC}"
echo -e " ⚙️  Backend API:   ${CYAN}http://${LAN_IP}:8000${NC}"
echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "👉 ${BOLD}Leave this Terminal window open while using SortSmart.${NC}"
echo -e "👉 ${YELLOW}Press Ctrl+C anytime to stop the server.${NC}"
echo ""

# Keep alive and print status
while true; do
    sleep 2
done
