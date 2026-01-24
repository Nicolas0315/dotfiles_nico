#!/bin/bash

# Review Handoff Wrapper for Codex
# This script is called as: codex review-handoff

HANDOFF_FILE="$HOME/.codex/handoff.json"
SKILL_FILE="$HOME/.codex/skills/auto-review/review-handoff.md"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check if handoff file exists
if [ ! -f "$HANDOFF_FILE" ]; then
    echo -e "${RED}✗${NC} No handoff context found"
    echo "Please run /handoff in Claude Code first."
    exit 1
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}📋 Handoff Received from Claude Code${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Parse and display handoff context
if command -v jq &> /dev/null; then
    SUMMARY=$(jq -r '.implementation.summary // "N/A"' "$HANDOFF_FILE")
    FILES=$(jq -r '.implementation.changedFiles[]? // empty' "$HANDOFF_FILE")
    FILES_COUNT=$(jq -r '.implementation.changedFiles | length // 0' "$HANDOFF_FILE")
    COVERAGE=$(jq -r '.implementation.testCoverage // "N/A"' "$HANDOFF_FILE")
    BRANCH=$(jq -r '.git.branch // "N/A"' "$HANDOFF_FILE")
    ISSUES=$(jq -r '.implementation.knownIssues[]? // empty' "$HANDOFF_FILE")

    echo -e "${GREEN}📌 Implementation Summary:${NC}"
    echo "  $SUMMARY"
    echo ""

    echo -e "${GREEN}📁 Changed Files ($FILES_COUNT):${NC}"
    while IFS= read -r file; do
        echo "  • $file"
    done <<< "$FILES"
    echo ""

    echo -e "${GREEN}📊 Test Coverage:${NC} $COVERAGE"
    echo -e "${GREEN}🌿 Branch:${NC} $BRANCH"
    echo ""

    if [ -n "$ISSUES" ]; then
        echo -e "${YELLOW}⚠️  Known Issues:${NC}"
        while IFS= read -r issue; do
            echo "  • $issue"
        done <<< "$ISSUES"
        echo ""
    fi
else
    echo -e "${YELLOW}⚠️  jq not found. Install jq for better output.${NC}"
    echo "Raw handoff data:"
    cat "$HANDOFF_FILE"
    echo ""
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Prompt user to start Codex with review context
echo -e "${GREEN}Starting Codex with auto-review context...${NC}"
echo ""

# Create instruction file for Codex session
INSTRUCTION_FILE="$HOME/.codex/review-instruction.txt"
cat > "$INSTRUCTION_FILE" <<EOF
You have received a handoff from Claude Code for review.

HANDOFF CONTEXT:
$(cat "$HANDOFF_FILE" | jq -r 'to_entries | .[] | "\(.key): \(.value)"' 2>/dev/null || cat "$HANDOFF_FILE")

TASK:
Please perform a comprehensive review following the auto-review skill:
1. Code Quality Review (/code-review)
2. Security Audit (security-reviewer agent)
3. Test Verification (check coverage, quality)
4. Documentation Check (README, API docs, CHANGELOG)
5. Provide structured findings report
6. Offer to fix issues, create commit, or create PR

Refer to ~/.codex/skills/auto-review/review-handoff.md for detailed process.

Start by showing a summary of what you will review, then proceed with the review.
EOF

echo -e "${BLUE}Starting Codex...${NC}"
echo ""

# Launch Codex with instruction
if command -v codex &> /dev/null; then
    codex --prompt "$(cat "$INSTRUCTION_FILE")"
else
    echo -e "${YELLOW}⚠️  'codex' command not found${NC}"
    echo ""
    echo "Please start Codex manually and review the handoff:"
    echo "  Context file: $HANDOFF_FILE"
    echo "  Instruction: $INSTRUCTION_FILE"
    echo "  Skill reference: $SKILL_FILE"
fi

# Cleanup
rm -f "$INSTRUCTION_FILE"
