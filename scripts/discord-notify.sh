#!/bin/bash

# Discord Notification Script
# Sends development notifications to Discord via Webhook

set -e

# Configuration
CONFIG_FILE="${CLAWDBOT_CONFIG:-$HOME/.clawdbot/config.json}"
WEBHOOK_URL=""
ENABLED=false

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Load configuration
load_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        echo -e "${YELLOW}⚠️  Config file not found: $CONFIG_FILE${NC}" >&2
        echo "Run: mkdir -p ~/.clawdbot && cp .clawdbot/config.json ~/.clawdbot/" >&2
        return 1
    fi

    if command -v jq &> /dev/null; then
        WEBHOOK_URL=$(jq -r '.discord.webhookUrl // ""' "$CONFIG_FILE")
        ENABLED=$(jq -r '.discord.enabled // false' "$CONFIG_FILE")
    else
        echo -e "${YELLOW}⚠️  jq not found. Please install jq for JSON parsing${NC}" >&2
        return 1
    fi

    if [ "$ENABLED" != "true" ]; then
        echo -e "${YELLOW}⚠️  Discord notifications disabled in config${NC}" >&2
        return 1
    fi

    if [ -z "$WEBHOOK_URL" ] || [ "$WEBHOOK_URL" = "null" ]; then
        echo -e "${RED}❌ Discord Webhook URL not configured${NC}" >&2
        echo "Set 'discord.webhookUrl' in $CONFIG_FILE" >&2
        return 1
    fi

    return 0
}

# Send notification to Discord
send_notification() {
    local event_type="$1"
    local status="$2"
    local title="$3"
    local description="$4"
    local color="$5"

    # Build embed JSON
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local username=$(jq -r '.discord.username // "Claude Dev Bot"' "$CONFIG_FILE")

    local payload=$(jq -n \
        --arg username "$username" \
        --arg title "$title" \
        --arg description "$description" \
        --arg color "$color" \
        --arg timestamp "$timestamp" \
        --arg event "$event_type" \
        --arg status "$status" \
        '{
            username: $username,
            embeds: [{
                title: $title,
                description: $description,
                color: ($color | tonumber),
                timestamp: $timestamp,
                fields: [
                    {
                        name: "Event",
                        value: $event,
                        inline: true
                    },
                    {
                        name: "Status",
                        value: $status,
                        inline: true
                    }
                ],
                footer: {
                    text: "Claude Code / Codex"
                }
            }]
        }')

    # Send to Discord
    local response=$(curl -s -X POST "$WEBHOOK_URL" \
        -H "Content-Type: application/json" \
        -d "$payload")

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓${NC} Notification sent to Discord" >&2
        return 0
    else
        echo -e "${RED}❌ Failed to send notification${NC}" >&2
        return 1
    fi
}

# Notification helpers
notify_commit() {
    local commit_msg="$1"
    local commit_hash=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
    local branch=$(git branch --show-current 2>/dev/null || echo "unknown")

    send_notification \
        "Git Commit" \
        "✅ Success" \
        "Commit: $commit_hash" \
        "**Branch:** $branch\n**Message:** $commit_msg" \
        "3066993" # Green
}

notify_pr() {
    local pr_url="$1"
    local pr_number=$(echo "$pr_url" | grep -oP 'pull/\K\d+')
    local branch=$(git branch --show-current 2>/dev/null || echo "unknown")

    send_notification \
        "Pull Request" \
        "✅ Created" \
        "PR #$pr_number Created" \
        "**Branch:** $branch\n**URL:** $pr_url" \
        "3447003" # Blue
}

notify_build() {
    local status="$1"
    local message="$2"
    local color="3066993" # Green
    local status_emoji="✅"

    if [ "$status" = "failure" ]; then
        color="15158332" # Red
        status_emoji="❌"
    fi

    send_notification \
        "Build" \
        "$status_emoji $status" \
        "Build $status" \
        "$message" \
        "$color"
}

notify_test() {
    local status="$1"
    local passed="$2"
    local failed="$3"
    local coverage="$4"
    local color="3066993" # Green
    local status_emoji="✅"

    if [ "$status" = "failure" ]; then
        color="15158332" # Red
        status_emoji="❌"
    fi

    local description="**Passed:** $passed\n**Failed:** $failed\n**Coverage:** $coverage"

    send_notification \
        "Test" \
        "$status_emoji $status" \
        "Test $status" \
        "$description" \
        "$color"
}

# Main function
main() {
    local action="$1"
    shift

    # Load configuration
    if ! load_config; then
        exit 1
    fi

    case "$action" in
        commit)
            notify_commit "$@"
            ;;
        pr)
            notify_pr "$@"
            ;;
        build)
            notify_build "$@"
            ;;
        test)
            notify_test "$@"
            ;;
        *)
            echo "Usage: $0 {commit|pr|build|test} [args...]" >&2
            echo "" >&2
            echo "Examples:" >&2
            echo "  $0 commit \"feat: add new feature\"" >&2
            echo "  $0 pr \"https://github.com/user/repo/pull/123\"" >&2
            echo "  $0 build success \"Build completed in 2m 30s\"" >&2
            echo "  $0 test success 42 0 87%" >&2
            exit 1
            ;;
    esac
}

main "$@"
