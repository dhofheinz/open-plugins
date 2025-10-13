---
description: Compose commit message body with bullet points and proper formatting
---

# Operation: Write Commit Body

Compose a well-formatted commit message body with bullet points, proper wrapping, and clear explanation of changes.

## Parameters from $ARGUMENTS

**Required:**
- `changes:` - Comma-separated list of changes or file paths

**Optional:**
- `wrap:` - Line wrap length (default: 72)
- `format:` - Output format (bullets|paragraphs, default: bullets)
- `why:` - Additional context about why changes were made

**Format:** `body changes:"Change 1,Change 2,Change 3" [why:"explanation"]`

## Workflow

### Step 1: Parse Parameters

Extract parameters from $ARGUMENTS:

```bash
# Parse changes (supports both quoted and comma-separated)
changes=$(echo "$ARGUMENTS" | grep -oP 'changes:"\K[^"]+' || echo "$ARGUMENTS" | grep -oP 'changes:\K[^,]+')
wrap=$(echo "$ARGUMENTS" | grep -oP 'wrap:\K[0-9]+' || echo "72")
format=$(echo "$ARGUMENTS" | grep -oP 'format:\K[^ ]+' || echo "bullets")
why=$(echo "$ARGUMENTS" | grep -oP 'why:"\K[^"]+')
```

### Step 2: Validate Parameters

**Check required parameters:**
```bash
if [ -z "$changes" ]; then
  echo "ERROR: changes parameter is required"
  echo "Usage: body changes:\"<change1>,<change2>\" [why:\"<explanation>\"]"
  exit 1
fi
```

**Validate format:**
```bash
if [ "$format" != "bullets" ] && [ "$format" != "paragraphs" ]; then
  echo "ERROR: Invalid format '$format'"
  echo "Valid formats: bullets, paragraphs"
  exit 1
fi
```

### Step 3: Invoke Body Composer Script

Pass parameters to the utility script for intelligent formatting:

```bash
# Export variables for script
export CHANGES="$changes"
export WRAP_LENGTH="$wrap"
export FORMAT="$format"
export WHY_CONTEXT="$why"

# Run composer
/home/danie/projects/plugins/architect/open-plugins/plugins/git-commit-assistant/commands/message-generation/.scripts/body-composer.sh
```

The script will:
- Split changes into individual items
- Format as bullet points or paragraphs
- Wrap lines at specified length
- Add context if provided
- Ensure imperative mood

### Step 4: Format Output

Present the generated body:

```
COMMIT BODY GENERATED
═══════════════════════════════════════════════

BODY:
───────────────────────────────────────────────
<blank line>
<formatted body content with bullet points>
<wrapped at 72 characters>

VALIDATION:
───────────────────────────────────────────────
✓ Blank line before body
✓ Lines wrapped at 72 characters
✓ Bullet points used
✓ Imperative mood
✓ Proper formatting

STATISTICS:
───────────────────────────────────────────────
Lines: X
Longest line: XX chars
Bullet points: X

═══════════════════════════════════════════════
```

## Output Format

Return structured output:
- Formatted body text
- Validation results
- Statistics (line count, wrapping)
- Suggestions for improvement (if any)

## Error Handling

**Missing required parameters:**
```
ERROR: Missing required parameter 'changes'
Usage: body changes:"<change1>,<change2>" [why:"<explanation>"]

Example: body changes:"Implement OAuth2 flow,Add provider support"
```

**Line too long:**
```
WARNING: Line exceeds 72 characters (XX chars)
Line: "- Very long description that goes on and on..."

Suggestion: Split into multiple bullet points or wrap text
```

**Non-imperative mood:**
```
WARNING: Use imperative mood in body
Current: "- Added authentication"
Correct: "- Add authentication"
```

## Body Formatting Rules

**Structure:**
```
<blank line required between subject and body>
<body content>
- Bullet point 1
- Bullet point 2
- Bullet point 3
```

**Line Wrapping:**
- Target: 72 characters per line
- Hard limit: No line should exceed 80 characters
- Use hard wraps, not soft wraps

**Bullet Points:**
- Use `-` for bullet points
- Consistent indentation
- One thought per bullet
- Imperative mood

**Content Focus:**
- Explain WHAT and WHY, not HOW
- Focus on user-facing changes
- Provide context when needed
- Avoid implementation details

## Integration with Agent

The commit-assistant agent uses this operation to:
1. Generate body content from analyzed changes
2. Format file lists into readable bullet points
3. Add context about why changes were made
4. Ensure proper formatting and wrapping

## Usage Examples

### Example 1: Basic Body with Changes

```bash
# Input
/message-generation body changes:"Implement OAuth2 flow,Add Google provider,Add GitHub provider,Include middleware"

# Output
BODY:

- Implement OAuth2 flow
- Add Google provider
- Add GitHub provider
- Include middleware
```

### Example 2: Body with Context

```bash
# Input
/message-generation body changes:"Refactor database queries,Add connection pooling" why:"Improve performance under load"

# Output
BODY:

- Refactor database queries
- Add connection pooling

Improve performance under high load conditions.
```

### Example 3: Body from File List

```bash
# Input
/message-generation body changes:"src/auth/oauth.js,src/auth/providers/google.js,src/auth/providers/github.js"

# Output
BODY:

- Add OAuth authentication module
- Implement Google provider
- Implement GitHub provider
- Add provider configuration
```

### Example 4: Paragraph Format

```bash
# Input
/message-generation body changes:"Update authentication flow" why:"Previous implementation had security vulnerabilities" format:paragraphs

# Output
BODY:

Update authentication flow to address security vulnerabilities
discovered in the previous implementation. The new approach uses
industry-standard OAuth2 protocol with secure token handling.
```

## Best Practices

**Be Clear:**
- ✅ "Add user authentication with OAuth2"
- ❌ "Add stuff"

**Use Bullet Points:**
- ✅ Multiple related changes as bullets
- ❌ Long paragraphs of text

**Focus on What/Why:**
- ✅ "Add caching to improve performance"
- ❌ "Add Redis instance with 5-minute TTL"

**Keep It Concise:**
- ✅ Brief, clear explanations
- ❌ Essay-length descriptions

**Wrap Properly:**
- ✅ "This is a properly wrapped line that doesn't exceed\nthe 72 character limit"
- ❌ "This is a very long line that goes on and on and on and exceeds the character limit"

## When to Include a Body

**Include body when:**
- Multiple files changed
- Changes need explanation
- Context is important
- Implications not obvious

**Omit body when:**
- Change is self-explanatory
- Subject line is sufficient
- Trivial change
- Documentation only

## Body Templates

**Feature Addition:**
```
- Add <feature name>
- Implement <capability 1>
- Implement <capability 2>
- Include <supporting feature>
```

**Bug Fix:**
```
- Resolve <issue>
- Add validation for <edge case>
- Update error handling

Fixes issue where <description of bug>
```

**Refactoring:**
```
- Extract <component>
- Simplify <logic>
- Improve <aspect>

No functional changes, improves code maintainability.
```

**Performance:**
```
- Optimize <operation>
- Add caching for <data>
- Reduce <metric>

Improves performance by <measurement>.
```
