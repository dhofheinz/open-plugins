---
description: Analyze git history to learn project's commit style and conventions
---

# History Analysis Skill

**Purpose:** Analyze git commit history to learn project-specific commit patterns, conventions, scope usage, and message styles. Provides intelligent recommendations that match the team's existing practices.

## Router

Parse `$ARGUMENTS` to determine which history analysis operation to execute:

**Available Operations:**
- `analyze-style` - Learn commit style from recent history
- `detect-patterns` - Identify project-specific conventions
- `extract-scopes` - Discover commonly used scopes
- `suggest-conventions` - Recommend conventions based on history
- `learn-project` - Comprehensive project pattern learning
- `learn` - Alias for learn-project (full analysis)

**Base Directory:** `/home/danie/projects/plugins/architect/open-plugins/plugins/git-commit-assistant/commands/history-analysis`

## Routing Logic

```
Request: $ARGUMENTS
Parse: operation = first word, parameters = remainder

If operation is:
  - "analyze-style" → Read "./analyze-style.md" with parameters
  - "detect-patterns" → Read "./detect-patterns.md" with parameters
  - "extract-scopes" → Read "./extract-scopes.md" with parameters
  - "suggest-conventions" → Read "./suggest-conventions.md" with parameters
  - "learn-project" or "learn" → Read "./learn-project.md" with parameters
  - empty or unknown → Display usage information
```

## Usage Examples

```bash
# Analyze commit style from recent history
/history-analysis analyze-style

# Analyze with custom commit count
/history-analysis analyze-style count:100

# Detect project conventions
/history-analysis detect-patterns

# Extract common scopes
/history-analysis extract-scopes

# Get convention recommendations
/history-analysis suggest-conventions

# Full project learning (comprehensive analysis)
/history-analysis learn-project

# Short alias for full learning
/history-analysis learn
```

## Parameters

All operations support these optional parameters:
- `count:N` - Number of commits to analyze (default: 50)
- `branch:name` - Branch to analyze (default: current branch)
- `format:json|text` - Output format (default: text)

## Integration Points

This skill is designed to be invoked by:
- **commit-assistant agent** - Learn project conventions before generating messages
- **message-generation skill** - Validate messages against project style
- **User commands** - Understand project commit patterns

## Error Handling

If not in a git repository:
- Return error: "Not in a git repository. Please run this command from within a git project."

If no commit history exists:
- Return error: "No commit history found. This appears to be a new repository."

If git command fails:
- Return error with git error message and troubleshooting guidance

## Output Structure

All operations return structured data including:
- **Analysis results** - Patterns, frequencies, statistics
- **Recommendations** - Project-specific guidance
- **Examples** - Sample commits from project
- **Confidence score** - How reliable the analysis is

---

**Execution:**

1. Parse `$ARGUMENTS` to extract operation and parameters
2. Validate git repository exists
3. Read and execute the appropriate operation file
4. Return structured results

If operation is unrecognized, display:
```
Unknown operation: {operation}

Available operations:
  analyze-style       - Analyze commit message style
  detect-patterns     - Detect project conventions
  extract-scopes      - Extract common scopes
  suggest-conventions - Get convention recommendations
  learn-project       - Full project pattern learning

Usage: /history-analysis <operation> [parameters]
Example: /history-analysis analyze-style count:100
```
