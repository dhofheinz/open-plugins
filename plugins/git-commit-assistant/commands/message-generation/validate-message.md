---
description: Validate commit message against conventional commits standard
---

# Operation: Validate Message

Validate a commit message against the conventional commits standard, checking format, style, and best practices.

## Parameters from $ARGUMENTS

**Required:**
- `message:` - Full commit message to validate (use quotes for multi-line)

**Optional:**
- `strict:` - Enable strict mode (true|false, default: false)
- `max_subject:` - Maximum subject length (default: 50)
- `max_line:` - Maximum body line length (default: 72)

**Format:** `validate message:"feat: add feature"` or `validate message:"$(cat commit.txt)"`

## Workflow

### Step 1: Parse Parameters

Extract message from $ARGUMENTS:

```bash
# Parse message (supports quoted multi-line)
message=$(echo "$ARGUMENTS" | sed -n 's/.*message:"\(.*\)".*/\1/p')
if [ -z "$message" ]; then
  message=$(echo "$ARGUMENTS" | sed 's/^validate //')
fi

strict=$(echo "$ARGUMENTS" | grep -oP 'strict:\K(true|false)' || echo "false")
max_subject=$(echo "$ARGUMENTS" | grep -oP 'max_subject:\K[0-9]+' || echo "50")
max_line=$(echo "$ARGUMENTS" | grep -oP 'max_line:\K[0-9]+' || echo "72")
```

### Step 2: Validate Parameters

**Check message provided:**
```bash
if [ -z "$message" ]; then
  echo "ERROR: message parameter is required"
  echo "Usage: validate message:\"<commit message>\""
  exit 1
fi
```

### Step 3: Invoke Message Validator Script

Pass message to validation script:

```bash
# Export variables
export MESSAGE="$message"
export STRICT_MODE="$strict"
export MAX_SUBJECT="$max_subject"
export MAX_LINE="$max_line"

# Run validator
/home/danie/projects/plugins/architect/open-plugins/plugins/git-commit-assistant/commands/message-generation/.scripts/message-validator.sh
```

The script performs comprehensive validation:
- Format compliance
- Type validation
- Subject line rules
- Body formatting
- Footer format
- Character limits
- Mood and style
- Best practices

### Step 4: Format Validation Report

Present detailed validation results:

```
COMMIT MESSAGE VALIDATION
═══════════════════════════════════════════════

MESSAGE:
───────────────────────────────────────────────
<commit message displayed>

FORMAT VALIDATION:
───────────────────────────────────────────────
✓ Conventional commits format
✓ Valid commit type
✓ Scope format correct (if present)
✓ Blank line before body (if present)
✓ Blank line before footer (if present)

SUBJECT LINE:
───────────────────────────────────────────────
✓ Length: XX/50 characters
✓ Imperative mood
✓ No capitalization after colon
✓ No period at end
✓ Clear and descriptive

BODY (if present):
───────────────────────────────────────────────
✓ Blank line after subject
✓ Lines wrapped at 72 characters
✓ Bullet points formatted correctly
✓ Explains what and why

FOOTER (if present):
───────────────────────────────────────────────
✓ Blank line before footer
✓ BREAKING CHANGE format correct
✓ Issue references valid
✓ Metadata formatted properly

OVERALL:
───────────────────────────────────────────────
Status: ✓ VALID / ✗ INVALID
Score: XX/100

WARNINGS (if any):
───────────────────────────────────────────────
- Subject line is long (consider shortening)
- Body line exceeds 72 characters

ERRORS (if any):
───────────────────────────────────────────────
- Invalid commit type
- Missing imperative mood

SUGGESTIONS:
───────────────────────────────────────────────
- <improvement 1>
- <improvement 2>

═══════════════════════════════════════════════
```

## Output Format

Return structured validation report with:
- Format compliance check
- Subject line validation
- Body validation (if present)
- Footer validation (if present)
- Overall score
- Warnings (non-critical issues)
- Errors (critical issues)
- Suggestions for improvement

## Error Handling

**No message provided:**
```
ERROR: message parameter is required
Usage: validate message:"<commit message>"

Example: validate message:"feat: add authentication"
```

**Empty message:**
```
ERROR: Commit message is empty
Provide a commit message to validate
```

**Completely invalid format:**
```
VALIDATION FAILED
Format does not match conventional commits standard

Expected: <type>(<scope>): <subject>
Received: <message>

See: https://www.conventionalcommits.org/
```

## Validation Rules

### Subject Line Validation

**Format:** `<type>(<scope>): <subject>`

**Type validation:**
- ✓ Valid types: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert
- ✗ Invalid types: feature, bugfix, update, change

**Scope validation:**
- ✓ Lowercase alphanumeric
- ✓ Hyphen allowed
- ✗ Spaces not allowed
- ✗ Special characters not allowed

**Subject validation:**
- ✓ Imperative mood (add, fix, update)
- ✗ Past tense (added, fixed)
- ✗ Present tense (adds, fixes)
- ✓ Lowercase after colon
- ✗ Uppercase after colon
- ✓ No period at end
- ✗ Period at end
- ✓ Length ≤ 50 chars (warning if > 50, error if > 72)

### Body Validation

**Structure:**
- ✓ Blank line after subject
- ✓ Lines wrapped at 72 characters
- ✓ Bullet points start with `-` or `*`
- ✓ Proper paragraph spacing

**Content:**
- ✓ Explains what and why
- ✓ Imperative mood
- ✗ Implementation details
- ✗ Overly verbose

### Footer Validation

**Format:**
- ✓ Blank line before footer
- ✓ `BREAKING CHANGE:` (uppercase, singular)
- ✓ Issue references: `Closes #123`
- ✓ Metadata format: `Key: value`

**Issue references:**
- ✓ `Closes #123`
- ✓ `Fixes #42`
- ✓ `Refs #100`
- ✗ `Closes 123` (missing #)
- ✗ `closes #123` (lowercase)

## Integration with Agent

The commit-assistant agent uses this operation to:
1. Validate messages before commit
2. Check user-provided messages
3. Verify generated messages
4. Provide improvement suggestions

## Usage Examples

### Example 1: Valid Message

```bash
# Input
/message-generation validate message:"feat(auth): add OAuth authentication"

# Output
✓ VALID
Subject: feat(auth): add OAuth authentication (42/50 chars)
All checks passed
```

### Example 2: Message with Warnings

```bash
# Input
/message-generation validate message:"feat: add a comprehensive OAuth2 authentication system"

# Output
⚠ VALID WITH WARNINGS
Subject exceeds 50 characters (57 chars)

Suggestion: Shorten subject or move details to body
Example: "feat: add OAuth2 authentication"
```

### Example 3: Invalid Type

```bash
# Input
/message-generation validate message:"feature: add login"

# Output
✗ INVALID
Invalid commit type: 'feature'

Valid types: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert
Suggested: feat: add login
```

### Example 4: Wrong Mood

```bash
# Input
/message-generation validate message:"fix: fixed login bug"

# Output
⚠ VALID WITH WARNINGS
Use imperative mood in subject

Current: "fixed login bug"
Correct: "fix login bug"
```

### Example 5: Multi-line Message

```bash
# Input
/message-generation validate message:"feat(auth): add OAuth

Implement OAuth2 authentication flow with Google and GitHub providers.

BREAKING CHANGE: authentication endpoint changed
Closes #123"

# Output
✓ VALID
Subject: ✓ (28/50 chars)
Body: ✓ (proper formatting)
Footer: ✓ (BREAKING CHANGE and issue reference)
Score: 100/100
```

### Example 6: Invalid Footer

```bash
# Input
/message-generation validate message:"feat: add feature

Breaking change: API changed"

# Output
✗ INVALID - Footer format incorrect

Current: "Breaking change: API changed"
Correct: "BREAKING CHANGE: API changed"

Footer tokens must be uppercase.
```

## Validation Scoring

**Score breakdown (100 points total):**

**Subject (40 points):**
- Valid type (10 pts)
- Proper format (10 pts)
- Imperative mood (10 pts)
- Length ≤ 50 chars (10 pts)

**Body (30 points, if present):**
- Blank line after subject (10 pts)
- Proper wrapping (10 pts)
- Clear explanation (10 pts)

**Footer (15 points, if present):**
- Blank line before footer (5 pts)
- Proper format (10 pts)

**Style (15 points):**
- Consistent style (5 pts)
- No typos (5 pts)
- Professional tone (5 pts)

**Scoring thresholds:**
- 90-100: Excellent
- 75-89: Good
- 60-74: Acceptable
- Below 60: Needs improvement

## Strict Mode

**Normal mode (default):**
- Warnings for non-critical issues
- Accepts messages with minor issues
- Suggests improvements

**Strict mode (strict:true):**
- Errors for any deviation
- Rejects messages with warnings
- Enforces all best practices
- Useful for pre-commit hooks

**Example difference:**

Normal mode:
```
⚠ Subject is 55 characters (warning)
Status: VALID
```

Strict mode:
```
✗ Subject exceeds 50 characters (error)
Status: INVALID
```

## Best Practices Validation

**Checks performed:**

**Subject best practices:**
- Be specific (not "update code")
- Focus on what (not how)
- Avoid filler words
- Use consistent terminology

**Body best practices:**
- Explain motivation
- Describe high-level approach
- Mention side effects
- Link to related work

**Footer best practices:**
- Clear breaking change description
- Accurate issue references
- Proper DCO/sign-off
- Relevant metadata only

## Common Validation Failures

**Invalid type:**
```
✗ Type "feature" is not valid
→ Use "feat" instead
```

**Past tense:**
```
✗ Use imperative: "add" not "added"
→ Subject should use present tense
```

**Capitalization:**
```
✗ Don't capitalize after colon
→ "feat: Add feature" should be "feat: add feature"
```

**Period at end:**
```
✗ No period at end of subject
→ "feat: add feature." should be "feat: add feature"
```

**No blank line:**
```
✗ Blank line required between subject and body
→ Add empty line after subject
```

**Line too long:**
```
✗ Body line exceeds 72 characters
→ Wrap text at 72 characters
```

**Invalid footer:**
```
✗ Footer format incorrect
→ Use "BREAKING CHANGE:" not "Breaking change:"
```

## Pre-commit Integration

This validation can be used in pre-commit hooks:

```bash
#!/bin/bash
# .git/hooks/commit-msg

MESSAGE=$(cat "$1")

# Validate message
result=$(/message-generation validate message:"$MESSAGE" strict:true)

if echo "$result" | grep -q "✗ INVALID"; then
  echo "$result"
  exit 1
fi
```

## Validation vs Generation

**Validation:**
- Checks existing messages
- Identifies problems
- Suggests corrections
- Pass/fail result

**Generation:**
- Creates new messages
- Follows rules automatically
- Optimized output
- Always valid (when properly configured)

**Workflow:**
```
User writes message → Validate → If invalid → Suggest corrections
Agent generates message → Validate → Should always pass
```
