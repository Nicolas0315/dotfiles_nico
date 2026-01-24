# Auto Review Handoff - Codex Skill

**Trigger**: `codex review-handoff` command or automatic invocation from Claude Code handoff

**Purpose**: Automatically review implementation handed off from Claude Code

---

## What This Skill Does

When invoked, Codex will:

1. **Load Handoff Context**
   - Read `~/.codex/handoff.json`
   - Parse implementation summary
   - Identify changed files
   - Check test coverage

2. **Execute Comprehensive Review**
   - Code quality review
   - Security audit
   - Test verification
   - Documentation check

3. **Report Findings**
   - Critical/High/Medium/Low issues
   - Recommendations
   - Action items

4. **Optional: Git Operations**
   - Create commit if approved
   - Generate PR if requested
   - Update documentation

---

## Automatic Review Process

### Phase 1: Context Loading

```bash
# Load handoff context
cat ~/.codex/handoff.json

# Display summary to user
Implementation: [summary]
Changed Files: [count]
Coverage: [percentage]
Branch: [branch-name]
```

### Phase 2: Code Review

Use `code-reviewer` agent to review all changed files:

```bash
/code-review
```

Review criteria:
- **Quality**: Readability, maintainability, performance
- **Security**: Vulnerabilities, secrets, input validation
- **Style**: Immutability, file size, naming
- **Tests**: Coverage, quality, edge cases

### Phase 3: Security Audit

Use `security-reviewer` agent:

```bash
# Check security issues
- Hardcoded secrets
- SQL injection risks
- XSS vulnerabilities
- CSRF protection
- Rate limiting
```

### Phase 4: Test Verification

```bash
# Verify test coverage
- Check if 80%+ coverage achieved
- Review test quality
- Check for edge cases
- Verify E2E tests for critical flows
```

### Phase 5: Documentation Check

```bash
# Check if documentation needs update
- README.md
- API documentation
- CHANGELOG.md
- Code comments
```

### Phase 6: Findings Report

Generate structured report:

```markdown
# Review Report

## Summary
[Brief overview of implementation and review]

## Changed Files
- file1.ts
- file2.ts
- test.ts

## Code Quality: ✓ PASS / ⚠️ ISSUES
- [List of issues with severity]

## Security: ✓ PASS / ⚠️ ISSUES
- [List of security concerns]

## Test Coverage: 87% ✓
- Unit tests: ✓
- Integration tests: ✓
- E2E tests: ⚠️ Missing for login flow

## Documentation: ⚠️ NEEDS UPDATE
- [ ] Update README with auth setup
- [ ] Add API documentation for /login endpoint

## Recommendations
1. [Recommendation 1]
2. [Recommendation 2]

## Action Items
- [ ] Fix critical issue in auth.ts:45
- [ ] Add E2E test for login
- [ ] Update README
```

### Phase 7: User Decision

Ask user:
- Fix issues now?
- Create commit?
- Create PR?
- Update docs?

---

## Implementation Instructions

When `review-handoff` is invoked:

### Step 1: Load Context

```bash
# Check if handoff file exists
if [ ! -f ~/.codex/handoff.json ]; then
    echo "No handoff context found. Run /handoff in Claude Code first."
    exit 1
fi

# Parse handoff JSON
HANDOFF=$(cat ~/.codex/handoff.json)
```

### Step 2: Display Summary

Show user what will be reviewed:
- Implementation summary
- Changed files list
- Current test coverage
- Git branch

### Step 3: Execute Reviews

Run agents in sequence:
1. `code-reviewer` agent for all changed files
2. `security-reviewer` agent for security audit
3. Check test coverage
4. Check documentation

### Step 4: Compile Report

Aggregate all findings into structured report

### Step 5: Ask User for Actions

Use AskUserQuestion:
- "Fix critical issues before commit?"
- "Update documentation?"
- "Create commit now?"
- "Create PR?"

### Step 6: Execute Actions

Based on user decisions:
- Fix issues (if requested)
- Update docs (if needed)
- Create commit with proper message
- Create PR (if requested)

---

## Handoff Context Structure

Expected JSON structure in `~/.codex/handoff.json`:

```json
{
  "timestamp": "2026-01-23T19:30:00Z",
  "sessionId": "claude-abc123",
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
    "status": "M  src/auth/login.ts\nM  src/auth/register.ts\nA  tests/auth.test.ts",
    "diff": "..."
  },
  "handoffType": "implementation-complete"
}
```

---

## Example Output

```
📋 Handoff Received from Claude Code
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📌 Implementation Summary:
Implemented user authentication with JWT

📁 Changed Files (3):
  • src/auth/login.ts
  • src/auth/register.ts
  • tests/auth.test.ts

📊 Test Coverage: 85%

🌿 Branch: feature/auth

⚠️  Known Issues:
  • TODO: Add rate limiting

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔍 Starting Comprehensive Review...

1. Code Quality Review...
   ✓ PASS - No critical issues

2. Security Audit...
   ⚠️  1 MEDIUM issue found:
   - Rate limiting not implemented (auth.ts:120)

3. Test Verification...
   ✓ PASS - 85% coverage achieved
   ⚠️  E2E test missing for login flow

4. Documentation Check...
   ⚠️  Needs update:
   - README.md (auth setup section)
   - API docs for /login endpoint

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📝 Review Summary:
Overall: ✓ APPROVED with minor fixes

Critical Issues: 0
High Issues: 0
Medium Issues: 1
Low Issues: 2

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

What would you like to do?
1. Fix medium issue and update docs
2. Create commit as-is
3. Show detailed report
4. Cancel
```

---

## Benefits

- **Consistent Quality**: Every handoff gets same thorough review
- **Time Saving**: Automated multi-phase review
- **Context Preservation**: All implementation details available
- **Clear Separation**: Claude Code implements, Codex reviews
- **Actionable Feedback**: Structured findings with priorities

---

## Configuration

### Auto-start Review

To automatically start review when Codex launches from handoff:

```bash
# In ~/.codex/config.toml
[handoff]
auto_review = true
show_summary_first = true
```

### Review Strictness

```bash
# In ~/.codex/config.toml
[review]
block_on_critical = true
block_on_high = false
require_80_percent_coverage = true
```

---

## Troubleshooting

### Handoff file not found

```bash
# Check if file exists
ls -la ~/.codex/handoff.json

# If missing, run in Claude Code:
/handoff
```

### Review fails

```bash
# Check handoff file format
cat ~/.codex/handoff.json | jq .

# Validate JSON
jq empty ~/.codex/handoff.json
```

### Want to re-run review

```bash
# Re-run with same context
codex review-handoff

# Or manually invoke
/code-review
```
