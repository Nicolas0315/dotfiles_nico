# Handoff Command - Implementation to Review Workflow

**Usage**: `/handoff`

**Purpose**: Hand off completed implementation from Claude Code to Codex for comprehensive review.

---

## What This Command Does

When you invoke `/handoff`, Claude Code will:

1. **Collect Implementation Context**
   - Changed files list
   - Test results and coverage
   - Implementation summary
   - Known issues or TODOs

2. **Save Handoff Data**
   - Write context to `~/.claude/handoff.json`
   - Include Git status and diff information
   - Add timestamp and session ID

3. **Launch Codex Session**
   - Execute `~/.claude/scripts/handoff-to-codex.sh`
   - Open Codex in new tmux pane or terminal tab
   - Codex automatically starts review process

---

## When to Use

Invoke `/handoff` when:
- Implementation is complete and tests pass
- Build is successful (no compile errors)
- Ready for code review and quality check
- Need security audit before commit
- Want documentation updated

---

## Workflow

### Step 1: Verify Implementation Complete

Before invoking `/handoff`, ensure:
- [ ] All tests pass (80%+ coverage)
- [ ] Build successful (no TypeScript errors)
- [ ] Code follows immutability principles
- [ ] Basic security checks done
- [ ] No console.log statements

### Step 2: Invoke Handoff

```bash
/handoff
```

### Step 3: Provide Context

You'll be prompted to provide:
- **Implementation summary**: What was implemented (1-3 sentences)
- **Changed files**: List of modified files (auto-detected)
- **Test coverage**: Current coverage percentage
- **Known issues**: Any known limitations or TODOs

### Step 4: Automatic Transfer

The system will:
1. Save all context to `~/.claude/handoff.json`
2. Run Git commands to capture current state
3. Launch Codex session automatically
4. Codex receives handoff context and starts review

---

## Handoff Data Structure

The handoff.json file contains:

```json
{
  "timestamp": "2026-01-23T19:30:00Z",
  "sessionId": "claude-session-abc123",
  "implementation": {
    "summary": "Implemented user authentication with JWT",
    "changedFiles": [
      "src/auth/login.ts",
      "src/auth/register.ts",
      "tests/auth.test.ts"
    ],
    "testCoverage": "85%",
    "knownIssues": ["TODO: Add rate limiting"]
  },
  "git": {
    "branch": "feature/auth",
    "status": "...",
    "diff": "..."
  },
  "handoffType": "implementation-complete"
}
```

---

## Codex Auto-Review Process

Once Codex receives the handoff, it will automatically:

1. **Code Review** (`/code-review`)
   - Quality check
   - Security audit
   - Performance analysis

2. **Test Verification**
   - Verify 80%+ coverage
   - Check test quality
   - Run E2E tests if needed

3. **Documentation Update**
   - Update README if needed
   - Generate API docs
   - Update CHANGELOG

4. **Git Operations** (if approved)
   - Create commit with proper message
   - Optionally create PR
   - Push to remote

---

## Example Usage

### Scenario: Feature Implementation Complete

```bash
# In Claude Code session
# After implementing user authentication feature

/handoff

# Prompted for context:
# Summary: "Implemented JWT-based user authentication with login/register endpoints"
# Changed files: Auto-detected (src/auth/*, tests/auth.test.ts)
# Coverage: 87%
# Known issues: "Rate limiting not yet implemented"

# System responds:
✓ Handoff context saved to ~/.claude/handoff.json
✓ Launching Codex session...
✓ Codex will automatically start review process
```

### In Codex Session (Automatic)

```bash
# Codex automatically loads handoff context
# And starts review:

📋 Handoff received from Claude Code
📁 Changed files: 3 files
📊 Test coverage: 87%
🔍 Starting automatic review...

/code-review
# Reviews all changed files
# Provides feedback

# If approved:
# Creates commit
# Optionally creates PR
```

---

## Configuration

### Enable tmux Integration (Recommended)

To automatically open Codex in new tmux pane:

```bash
# In ~/.claude/settings.json
{
  "handoff": {
    "launchMethod": "tmux",
    "autoStartReview": true
  }
}
```

### Terminal Tab Method

If not using tmux:

```bash
# In ~/.claude/settings.json
{
  "handoff": {
    "launchMethod": "terminal-tab",
    "autoStartReview": true
  }
}
```

---

## Troubleshooting

### Codex doesn't launch

Check that `~/.claude/scripts/handoff-to-codex.sh` is executable:

```bash
chmod +x ~/.claude/scripts/handoff-to-codex.sh
```

### Handoff context not loading in Codex

Verify `~/.claude/handoff.json` exists and is readable:

```bash
cat ~/.claude/handoff.json
```

### Want to manually trigger review

```bash
# In Codex
codex review-handoff
```

---

## Implementation Instructions

When user invokes `/handoff`:

1. **Collect Git Information**
   ```bash
   git status --porcelain
   git diff
   git branch --show-current
   ```

2. **Ask User for Context**
   Use AskUserQuestion to gather:
   - Implementation summary
   - Known issues or TODOs
   - Test coverage (if not auto-detected)

3. **Create Handoff JSON**
   Write to `~/.claude/handoff.json` with structure above

4. **Execute Handoff Script**
   ```bash
   bash ~/.claude/scripts/handoff-to-codex.sh
   ```

5. **Confirm to User**
   ```
   ✓ Handoff complete
   ✓ Codex session launched
   ✓ Review will start automatically
   ```

---

## Benefits

- **Seamless transition** from implementation to review
- **Context preservation** - no information lost
- **Automated quality checks** - consistent review process
- **Time saving** - no manual copying of context
- **Clear separation** - Claude Code and Codex roles well-defined
