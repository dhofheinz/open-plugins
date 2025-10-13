---
description: Add footer with breaking changes and issue references to commit message
---

# Operation: Add Footer

Add a properly formatted footer to commit message with breaking changes, issue references, and other metadata.

## Parameters from $ARGUMENTS

**Optional (at least one required):**
- `breaking:` - Breaking change description
- `closes:` - Comma-separated issue numbers to close
- `fixes:` - Comma-separated issue numbers to fix
- `refs:` - Comma-separated issue numbers to reference
- `reviewed:` - Reviewer name(s)
- `signed:` - Signed-off-by name and email

**Format:** `footer breaking:"API changed" closes:123,456`

## Workflow

### Step 1: Parse Parameters

Extract parameters from $ARGUMENTS:

```bash
# Parse footer components
breaking=$(echo "$ARGUMENTS" | grep -oP 'breaking:"\K[^"]+')
closes=$(echo "$ARGUMENTS" | grep -oP 'closes:\K[0-9,]+')
fixes=$(echo "$ARGUMENTS" | grep -oP 'fixes:\K[0-9,]+')
refs=$(echo "$ARGUMENTS" | grep -oP 'refs:\K[0-9,]+')
reviewed=$(echo "$ARGUMENTS" | grep -oP 'reviewed:"\K[^"]+')
signed=$(echo "$ARGUMENTS" | grep -oP 'signed:"\K[^"]+')
```

### Step 2: Validate Parameters

**Check at least one parameter provided:**
```bash
if [ -z "$breaking" ] && [ -z "$closes" ] && [ -z "$fixes" ] && [ -z "$refs" ] && [ -z "$reviewed" ] && [ -z "$signed" ]; then
  echo "ERROR: At least one footer parameter is required"
  echo "Usage: footer [breaking:\"<desc>\"] [closes:<nums>] [fixes:<nums>] [refs:<nums>]"
  exit 1
fi
```

### Step 3: Invoke Footer Builder Script

Pass parameters to the utility script for proper formatting:

```bash
# Prepare JSON input
cat <<EOF | /home/danie/projects/plugins/architect/open-plugins/plugins/git-commit-assistant/commands/message-generation/.scripts/footer-builder.py
{
  "breaking": "$breaking",
  "closes": "$closes",
  "fixes": "$fixes",
  "refs": "$refs",
  "reviewed": "$reviewed",
  "signed": "$signed"
}
EOF
```

The script will:
- Format BREAKING CHANGE properly
- Convert issue numbers to proper references
- Order footer elements correctly
- Ensure proper spacing and formatting

### Step 4: Format Output

Present the generated footer:

```
FOOTER GENERATED
═══════════════════════════════════════════════

FOOTER:
───────────────────────────────────────────────
<blank line>
<formatted footer content>

VALIDATION:
───────────────────────────────────────────────
✓ Blank line before footer
✓ BREAKING CHANGE format correct
✓ Issue references valid
✓ Proper formatting

COMPONENTS:
───────────────────────────────────────────────
Breaking Changes: <yes/no>
Issues Closed: X
Issues Fixed: X
References: X
Signed-off: <yes/no>

═══════════════════════════════════════════════
```

## Output Format

Return structured output:
- Formatted footer text
- Validation results
- Component breakdown
- Suggestions (if any)

## Error Handling

**No parameters provided:**
```
ERROR: At least one footer parameter is required
Usage: footer [breaking:"<desc>"] [closes:<nums>] [fixes:<nums>]

Example: footer breaking:"authentication API changed" closes:123
```

**Invalid issue number format:**
```
ERROR: Invalid issue number format
Expected: closes:123 or closes:123,456
Received: closes:abc
```

**Missing breaking change description:**
```
ERROR: breaking parameter requires description
Usage: footer breaking:"<description of breaking change>"

Example: footer breaking:"API endpoint /auth removed"
```

## Footer Format Rules

**Order of Elements:**
```
<blank line>
BREAKING CHANGE: <description>
Closes #<issue>
Fixes #<issue>
Refs #<issue>
Reviewed-by: <name>
Signed-off-by: <name> <email>
```

**Breaking Changes:**
- Always use `BREAKING CHANGE:` (uppercase, singular)
- Provide clear description
- Can also use `!` in subject: `feat!: change API`

**Issue References:**
- Use `Closes #123` for issues closed by this commit
- Use `Fixes #123` for bugs fixed by this commit
- Use `Refs #123` for related issues
- Multiple issues: `Closes #123, #456`

**Metadata:**
- `Reviewed-by:` for code review
- `Signed-off-by:` for DCO compliance
- Custom trailers as needed

## Integration with Agent

The commit-assistant agent uses this operation to:
1. Add breaking change notices
2. Link commits to issues
3. Add review metadata
4. Ensure proper footer formatting

## Usage Examples

### Example 1: Breaking Change

```bash
# Input
/message-generation footer breaking:"authentication API endpoint changed from /login to /auth/login"

# Output
FOOTER:

BREAKING CHANGE: authentication API endpoint changed from /login to
/auth/login
```

### Example 2: Close Issues

```bash
# Input
/message-generation footer closes:123,456,789

# Output
FOOTER:

Closes #123, #456, #789
```

### Example 3: Fix and Close

```bash
# Input
/message-generation footer fixes:42 closes:100

# Output
FOOTER:

Fixes #42
Closes #100
```

### Example 4: Complete Footer

```bash
# Input
/message-generation footer breaking:"remove deprecated API" closes:200 signed:"John Doe <john@example.com>"

# Output
FOOTER:

BREAKING CHANGE: remove deprecated API
Closes #200
Signed-off-by: John Doe <john@example.com>
```

### Example 5: Multiple Issue Fixes

```bash
# Input
/message-generation footer fixes:10,20,30 refs:100

# Output
FOOTER:

Fixes #10, #20, #30
Refs #100
```

## Best Practices

**Breaking Changes:**
- ✅ "BREAKING CHANGE: API endpoint changed"
- ❌ "Breaking change: api endpoint changed"
- ✅ Clear description of what broke
- ❌ Vague "things changed"

**Issue References:**
- ✅ "Closes #123" (actually closes)
- ❌ "Closes #123" (just mentions)
- ✅ "Refs #100" (related)
- ❌ "See issue 100"

**Issue Linking Semantics:**
- `Closes` - Pull request or feature complete
- `Fixes` - Bug fix
- `Refs` - Related but not closed
- `Resolves` - Alternative to Closes

## When to Include a Footer

**Include footer when:**
- Breaking changes introduced
- Closes or fixes issues
- Multiple reviewers
- DCO/signing required
- Related work references

**Omit footer when:**
- No breaking changes
- No issue tracking
- No special metadata
- Simple standalone commit

## Breaking Change Detection

**Patterns that indicate breaking changes:**
- API endpoint changes
- Function signature changes
- Removed features
- Changed behavior
- Dependency major version bumps
- Configuration format changes

**How to communicate breaking changes:**
```
BREAKING CHANGE: <brief description>

<longer explanation of what changed>
<migration path if applicable>
```

**Alternative notation:**
```
feat!: change API endpoint

# The ! indicates breaking change
```

## Footer Templates

**Feature with Issue:**
```
Closes #<issue>
```

**Bug Fix:**
```
Fixes #<issue>
```

**Breaking Change with Migration:**
```
BREAKING CHANGE: <what changed>

Migration: <how to update>
Closes #<issue>
```

**Multiple Issues:**
```
Fixes #<bug1>, #<bug2>
Closes #<feature>
Refs #<related>
```

**Signed Commit:**
```
Reviewed-by: <reviewer>
Signed-off-by: <author> <email>
```

## GitHub/GitLab Integration

**GitHub Keywords (auto-close issues):**
- Closes, Closed, Close
- Fixes, Fixed, Fix
- Resolves, Resolved, Resolve

**GitLab Keywords:**
- Closes, Closed, Close (same as GitHub)
- Fixes, Fixed, Fix
- Resolves, Resolved, Resolve
- Implements, Implemented, Implement

**Format:**
```
Closes #123                    # Same repository
Closes user/repo#123          # Different repository
Closes https://github.com/... # Full URL
```

## Footer Validation

**Valid footer format:**
```
✓ Blank line before footer
✓ BREAKING CHANGE in capitals
✓ Issue numbers have # prefix
✓ Proper token format (Closes, Fixes, etc.)
✓ Valid email in Signed-off-by
```

**Invalid footer format:**
```
✗ No blank line before footer
✗ "Breaking change:" (lowercase)
✗ "Closes 123" (missing #)
✗ "Resolves issue 123" (wrong format)
✗ Invalid email format
```
