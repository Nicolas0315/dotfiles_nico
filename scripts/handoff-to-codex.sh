#!/bin/bash

# Handoff to Codex Script
# Launches Codex session with handoff context from Claude Code

set -e

HANDOFF_FILE="$HOME/.claude/handoff.json"
CODEX_HANDOFF_FILE="$HOME/.codex/handoff.json"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Handoff to Codex ===${NC}"

# Check if handoff file exists
if [ ! -f "$HANDOFF_FILE" ]; then
    echo -e "${YELLOW}⚠️  No handoff file found at $HANDOFF_FILE${NC}"
    echo "Please run /handoff command in Claude Code first."
    exit 1
fi

# Copy handoff file to Codex directory
echo -e "${GREEN}✓${NC} Copying handoff context to Codex..."
cp "$HANDOFF_FILE" "$CODEX_HANDOFF_FILE"

# Detect launch method (tmux or terminal)
LAUNCH_METHOD="${HANDOFF_LAUNCH_METHOD:-tmux}"

if [ "$LAUNCH_METHOD" = "tmux" ] && command -v tmux &> /dev/null && [ -n "$TMUX" ]; then
    # Launch Codex in new tmux pane
    echo -e "${GREEN}✓${NC} Launching Codex in new tmux pane..."

    # Split window horizontally and run Codex with auto-review
    tmux split-window -h "codex review-handoff; exec bash"

    echo -e "${GREEN}✓${NC} Codex session started in tmux pane"
    echo -e "${BLUE}Review will start automatically${NC}"

elif command -v osascript &> /dev/null; then
    # macOS: Open new Terminal tab
    echo -e "${GREEN}✓${NC} Launching Codex in new Terminal tab..."

    osascript <<EOF
tell application "Terminal"
    activate
    tell application "System Events" to keystroke "t" using {command down}
    delay 0.5
    do script "cd '$(pwd)' && codex review-handoff" in front window
end tell
EOF

    echo -e "${GREEN}✓${NC} Codex session started in new Terminal tab"
    echo -e "${BLUE}Review will start automatically${NC}"

else
    # Fallback: Manual instruction
    echo -e "${YELLOW}⚠️  Could not auto-launch Codex${NC}"
    echo ""
    echo "Please manually run in a new terminal:"
    echo "  cd $(pwd)"
    echo "  codex review-handoff"
    echo ""
    echo -e "${GREEN}Handoff context saved to: $CODEX_HANDOFF_FILE${NC}"
fi

# Display handoff summary
echo ""
echo -e "${BLUE}=== Handoff Summary ===${NC}"
if command -v jq &> /dev/null; then
    jq -r '"Summary: \(.implementation.summary // "N/A")
Files: \(.implementation.changedFiles | length // 0) changed
Coverage: \(.implementation.testCoverage // "N/A")
Branch: \(.git.branch // "N/A")"' "$HANDOFF_FILE"
else
    echo "Handoff file: $HANDOFF_FILE"
    echo "Use 'cat $HANDOFF_FILE' to view details"
fi

echo ""
echo -e "${GREEN}✓ Handoff complete${NC}"
