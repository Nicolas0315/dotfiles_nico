# Discord Notification Script (PowerShell)
# Sends development notifications to Discord via Webhook

param(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateSet("commit", "pr", "build", "test")]
    [string]$Action,

    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]]$Arguments
)

# Configuration
$ConfigFile = if ($env:CLAWDBOT_CONFIG) { $env:CLAWDBOT_CONFIG } else { "$env:USERPROFILE\.clawdbot\config.json" }
$WebhookUrl = ""
$Enabled = $false

# Colors for console output
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

# Load configuration
function Load-Config {
    if (-not (Test-Path $ConfigFile)) {
        Write-ColorOutput "⚠️  Config file not found: $ConfigFile" "Yellow"
        Write-ColorOutput "Run: New-Item -ItemType Directory -Path $env:USERPROFILE\.clawdbot -Force" "Yellow"
        Write-ColorOutput "     Copy-Item .clawdbot\config.json $env:USERPROFILE\.clawdbot\" "Yellow"
        return $false
    }

    try {
        $config = Get-Content $ConfigFile -Raw | ConvertFrom-Json
        $script:WebhookUrl = $config.discord.webhookUrl
        $script:Enabled = $config.discord.enabled

        if (-not $Enabled) {
            Write-ColorOutput "⚠️  Discord notifications disabled in config" "Yellow"
            return $false
        }

        if ([string]::IsNullOrWhiteSpace($WebhookUrl)) {
            Write-ColorOutput "❌ Discord Webhook URL not configured" "Red"
            Write-ColorOutput "Set 'discord.webhookUrl' in $ConfigFile" "Red"
            return $false
        }

        return $true
    }
    catch {
        Write-ColorOutput "❌ Failed to parse config file: $_" "Red"
        return $false
    }
}

# Send notification to Discord
function Send-Notification {
    param(
        [string]$EventType,
        [string]$Status,
        [string]$Title,
        [string]$Description,
        [int]$Color
    )

    $timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    $config = Get-Content $ConfigFile -Raw | ConvertFrom-Json
    $username = $config.discord.username

    $payload = @{
        username = $username
        embeds = @(
            @{
                title = $Title
                description = $Description
                color = $Color
                timestamp = $timestamp
                fields = @(
                    @{
                        name = "Event"
                        value = $EventType
                        inline = $true
                    },
                    @{
                        name = "Status"
                        value = $Status
                        inline = $true
                    }
                )
                footer = @{
                    text = "Claude Code / Codex"
                }
            }
        )
    } | ConvertTo-Json -Depth 10

    try {
        $response = Invoke-RestMethod -Uri $WebhookUrl -Method Post -Body $payload -ContentType "application/json"
        Write-ColorOutput "✓ Notification sent to Discord" "Green"
        return $true
    }
    catch {
        Write-ColorOutput "❌ Failed to send notification: $_" "Red"
        return $false
    }
}

# Notification helpers
function Notify-Commit {
    param([string]$CommitMsg)

    $commitHash = & git rev-parse --short HEAD 2>$null
    if (-not $commitHash) { $commitHash = "unknown" }

    $branch = & git branch --show-current 2>$null
    if (-not $branch) { $branch = "unknown" }

    Send-Notification `
        -EventType "Git Commit" `
        -Status "✅ Success" `
        -Title "Commit: $commitHash" `
        -Description "**Branch:** $branch`n**Message:** $CommitMsg" `
        -Color 3066993  # Green
}

function Notify-PR {
    param([string]$PrUrl)

    $prNumber = if ($PrUrl -match 'pull/(\d+)') { $matches[1] } else { "unknown" }
    $branch = & git branch --show-current 2>$null
    if (-not $branch) { $branch = "unknown" }

    Send-Notification `
        -EventType "Pull Request" `
        -Status "✅ Created" `
        -Title "PR #$prNumber Created" `
        -Description "**Branch:** $branch`n**URL:** $PrUrl" `
        -Color 3447003  # Blue
}

function Notify-Build {
    param(
        [string]$Status,
        [string]$Message
    )

    $color = if ($Status -eq "failure") { 15158332 } else { 3066993 }  # Red : Green
    $statusEmoji = if ($Status -eq "failure") { "❌" } else { "✅" }

    Send-Notification `
        -EventType "Build" `
        -Status "$statusEmoji $Status" `
        -Title "Build $Status" `
        -Description $Message `
        -Color $color
}

function Notify-Test {
    param(
        [string]$Status,
        [string]$Passed,
        [string]$Failed,
        [string]$Coverage
    )

    $color = if ($Status -eq "failure") { 15158332 } else { 3066993 }  # Red : Green
    $statusEmoji = if ($Status -eq "failure") { "❌" } else { "✅" }

    $description = "**Passed:** $Passed`n**Failed:** $Failed`n**Coverage:** $Coverage"

    Send-Notification `
        -EventType "Test" `
        -Status "$statusEmoji $Status" `
        -Title "Test $Status" `
        -Description $description `
        -Color $color
}

# Main logic
if (-not (Load-Config)) {
    exit 1
}

switch ($Action) {
    "commit" {
        if ($Arguments.Count -lt 1) {
            Write-ColorOutput "Usage: $($MyInvocation.MyCommand.Name) commit <commit-message>" "Red"
            exit 1
        }
        Notify-Commit -CommitMsg $Arguments[0]
    }
    "pr" {
        if ($Arguments.Count -lt 1) {
            Write-ColorOutput "Usage: $($MyInvocation.MyCommand.Name) pr <pr-url>" "Red"
            exit 1
        }
        Notify-PR -PrUrl $Arguments[0]
    }
    "build" {
        if ($Arguments.Count -lt 2) {
            Write-ColorOutput "Usage: $($MyInvocation.MyCommand.Name) build <success|failure> <message>" "Red"
            exit 1
        }
        Notify-Build -Status $Arguments[0] -Message $Arguments[1]
    }
    "test" {
        if ($Arguments.Count -lt 4) {
            Write-ColorOutput "Usage: $($MyInvocation.MyCommand.Name) test <success|failure> <passed> <failed> <coverage>" "Red"
            exit 1
        }
        Notify-Test -Status $Arguments[0] -Passed $Arguments[1] -Failed $Arguments[2] -Coverage $Arguments[3]
    }
    default {
        Write-ColorOutput "Usage: $($MyInvocation.MyCommand.Name) {commit|pr|build|test} [args...]" "Red"
        exit 1
    }
}
