# Discord Notify Command

**Usage**: `/discord-notify [event-type] [args...]`

**Purpose**: Send development notifications to Discord via Webhook.

---

## What This Command Does

When you invoke `/discord-notify`, Claude Code will send a notification to your Discord channel for various development events such as commits, PRs, builds, and test results.

---

## Prerequisites

### 1. Setup Discord Webhook

1. Open your Discord server
2. Go to **Server Settings** → **Integrations** → **Webhooks**
3. Click **New Webhook**
4. Configure:
   - **Name**: Claude Dev Bot
   - **Channel**: Select notification channel
   - **Avatar**: (Optional) Upload bot avatar
5. Click **Copy Webhook URL**

### 2. Configure Webhook URL

Edit `~/.clawdbot/config.json`:

```json
{
  "discord": {
    "webhookUrl": "https://discord.com/api/webhooks/YOUR_WEBHOOK_ID/YOUR_WEBHOOK_TOKEN",
    "enabled": true,
    "notifications": {
      "commit": true,
      "pr": true,
      "build": true,
      "test": true
    }
  }
}
```

**Important**: Never commit Webhook URLs to Git! Keep them in local config only.

---

## Usage Examples

### Notify Git Commit

```bash
/discord-notify commit "feat: add new authentication feature"
```

Sends notification with:
- Commit hash
- Branch name
- Commit message

### Notify PR Creation

```bash
/discord-notify pr "https://github.com/user/repo/pull/123"
```

Sends notification with:
- PR number
- Branch name
- PR URL

### Notify Build Result

```bash
# Successful build
/discord-notify build success "Build completed in 2m 30s"

# Failed build
/discord-notify build failure "Type error in src/auth/login.ts:42"
```

### Notify Test Result

```bash
# Successful tests
/discord-notify test success 42 0 87%

# Failed tests
/discord-notify test failure 38 4 79%
```

Arguments: `<status> <passed> <failed> <coverage>`

---

## Event Types

| Event | Description | Arguments |
|-------|-------------|-----------|
| `commit` | Git commit notification | `<commit-message>` |
| `pr` | Pull Request notification | `<pr-url>` |
| `build` | Build result notification | `<success\|failure> <message>` |
| `test` | Test result notification | `<success\|failure> <passed> <failed> <coverage>` |

---

## Notification Format

Discord notifications are sent as embeds with:
- **Title**: Event summary
- **Description**: Detailed information
- **Color**: Green (success) or Red (failure)
- **Fields**: Event type and status
- **Timestamp**: UTC timestamp
- **Footer**: "Claude Code / Codex"

---

## Automatic Notifications (Hooks)

To automatically send notifications on certain events, hooks are configured in `~/.claude/hooks/hooks.json`:

### Git Commit Hook

Automatically notifies Discord after successful commits:

```json
{
  "matcher": "tool == \"Bash\" && tool_input.command matches \"git commit\"",
  "hooks": [{
    "type": "command",
    "command": "bash ~/.claude/scripts/discord-notify.sh commit \"$(git log -1 --pretty=%s)\""
  }]
}
```

### PR Creation Hook

Automatically notifies Discord after PR creation:

```json
{
  "matcher": "tool == \"Bash\" && tool_input.command matches \"gh pr create\"",
  "hooks": [{
    "type": "command",
    "command": "bash ~/.claude/scripts/discord-notify.sh pr \"$(echo $output | grep -oP 'https://github.com/[^\\s]+')\""
  }]
}
```

### Build Completion Hook

Automatically notifies Discord after build:

```json
{
  "matcher": "tool == \"Bash\" && tool_input.command matches \"(npm|pnpm|yarn|bun) run build\"",
  "hooks": [{
    "type": "command",
    "command": "bash ~/.claude/scripts/discord-notify.sh build success \"Build completed\""
  }]
}
```

### Test Completion Hook

Automatically notifies Discord after tests:

```json
{
  "matcher": "tool == \"Bash\" && tool_input.command matches \"(npm|pnpm|yarn|bun) (run )?test\"",
  "hooks": [{
    "type": "command",
    "command": "bash ~/.claude/scripts/discord-notify.sh test success ... ... ..."
  }]
}
```

---

## Configuration Options

Edit `~/.clawdbot/config.json` to customize:

```json
{
  "discord": {
    "webhookUrl": "https://discord.com/api/webhooks/...",
    "enabled": true,
    "notifications": {
      "commit": true,     // Enable commit notifications
      "pr": true,         // Enable PR notifications
      "build": true,      // Enable build notifications
      "test": true        // Enable test notifications
    },
    "username": "Claude Dev Bot",
    "avatarUrl": "https://avatars.githubusercontent.com/u/0?v=4"
  },
  "notifications": {
    "format": "embed",              // Use Discord embeds
    "includeContext": true,         // Include context in messages
    "mentionOnFailure": false       // Mention @here on failures
  }
}
```

---

## Troubleshooting

### Webhook URL Not Configured

```
❌ Discord Webhook URL not configured
```

**Solution**: Set `discord.webhookUrl` in `~/.clawdbot/config.json`

### Notifications Disabled

```
⚠️  Discord notifications disabled in config
```

**Solution**: Set `discord.enabled: true` in config

### Failed to Send Notification

```
❌ Failed to send notification
```

**Possible causes**:
- Invalid Webhook URL
- Webhook deleted or expired
- Network connection issue
- Discord API rate limit

**Solution**: Verify Webhook URL in Discord settings and update config

### Config File Not Found

```
⚠️  Config file not found: ~/.clawdbot/config.json
```

**Solution**:
```bash
# Create config directory
mkdir -p ~/.clawdbot

# Copy template config
cp dotfiles_nico/.clawdbot/config.json ~/.clawdbot/

# Edit config
vim ~/.clawdbot/config.json
```

---

## Platform-Specific Notes

### macOS / Linux

Use Bash script:
```bash
bash ~/.claude/scripts/discord-notify.sh commit "message"
```

### Windows

Use PowerShell script:
```powershell
powershell -File $env:USERPROFILE\.claude\scripts\discord-notify.ps1 commit "message"
```

Or in PowerShell:
```powershell
& "$env:USERPROFILE\.claude\scripts\discord-notify.ps1" commit "message"
```

---

## Implementation Instructions

When user invokes `/discord-notify`:

1. **Parse Arguments**
   - Event type: commit, pr, build, test
   - Event-specific arguments

2. **Detect Platform**
   - Check if Windows (PowerShell) or Unix (Bash)
   - Use appropriate script

3. **Execute Notification Script**
   ```bash
   # Unix
   bash ~/.claude/scripts/discord-notify.sh <event> <args...>

   # Windows
   powershell -File ~/.claude/scripts/discord-notify.ps1 <event> <args...>
   ```

4. **Confirm to User**
   ```
   ✓ Notification sent to Discord
   Event: <event-type>
   Status: <status>
   ```

---

## Security Best Practices

1. **Never commit Webhook URLs**
   - Add `~/.clawdbot/config.json` to `.gitignore`
   - Use local config only

2. **Rotate Webhooks regularly**
   - Regenerate Webhook URLs periodically
   - Delete unused Webhooks

3. **Limit Webhook permissions**
   - Use dedicated notification channel
   - Restrict Webhook to posting only

4. **Monitor Webhook usage**
   - Check Discord audit log regularly
   - Revoke suspicious Webhooks immediately

---

## Benefits

- **Real-time notifications** - Get instant updates on development progress
- **Team transparency** - Share progress with team via Discord
- **Workflow visibility** - Track commits, PRs, builds, and tests in one place
- **Automated updates** - Reduce manual status reporting
- **Flexible configuration** - Enable/disable notifications per event type
