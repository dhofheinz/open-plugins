---
description: Get detailed file change statistics for commit analysis
---

# Operation: File Statistics

Retrieve detailed statistics about file changes including counts, line changes, and file types.

## Parameters from $ARGUMENTS

Optional parameters:
- `format:json|text` - Output format (default: text)
- `detailed:true|false` - Include per-file breakdown (default: false)

## Workflow

### Step 1: Verify Repository

```bash
git rev-parse --git-dir 2>/dev/null
```

### Step 2: Collect File Statistics

```bash
# Get file status
git status --short

# Get statistics
git diff --stat HEAD

# Get detailed stats per file
git diff --numstat HEAD

# Count file types
git diff --name-only HEAD | wc -l
```

### Step 3: Categorize Files

Group files by status and type:

**By Status:**
- New files (A)
- Modified files (M)
- Deleted files (D)
- Renamed files (R)

**By Type:**
- Source code (.js, .ts, .py, .java, etc.)
- Tests (.test.js, .spec.ts, _test.py, etc.)
- Documentation (.md, .txt)
- Configuration (.json, .yml, .toml, .config.js)
- Styles (.css, .scss, .less)

### Step 4: Calculate Metrics

```
METRICS:
- Total files changed
- Total insertions (lines added)
- Total deletions (lines removed)
- Net change (insertions - deletions)
- Largest files (by lines changed)
- Files by type distribution
- New vs Modified vs Deleted ratio
```

### Step 5: Format Statistics Report

**Text Format (default):**
```
FILE STATISTICS
═══════════════════════════════════════════════

OVERVIEW:
───────────────────────────────────────────────
Total Files: X
Insertions: +XXX lines
Deletions: -XXX lines
Net Change: ±XXX lines

STATUS BREAKDOWN:
───────────────────────────────────────────────
New Files: X
Modified Files: X
Deleted Files: X
Renamed Files: X

FILE TYPE BREAKDOWN:
───────────────────────────────────────────────
Source Code: X files (+XXX -XXX lines)
Tests: X files (+XXX -XXX lines)
Documentation: X files (+XXX -XXX lines)
Configuration: X files (+XXX -XXX lines)
Styles: X files (+XXX -XXX lines)
Other: X files (+XXX -XXX lines)

TOP CHANGED FILES:
───────────────────────────────────────────────
1. <filename> (+XXX -XXX) = XXX lines
2. <filename> (+XXX -XXX) = XXX lines
3. <filename> (+XXX -XXX) = XXX lines
4. <filename> (+XXX -XXX) = XXX lines
5. <filename> (+XXX -XXX) = XXX lines

<if detailed:true>
PER-FILE BREAKDOWN:
───────────────────────────────────────────────
<status> <filename>
  Insertions: +XXX
  Deletions: -XXX
  Net: ±XXX

<status> <filename>
  Insertions: +XXX
  Deletions: -XXX
  Net: ±XXX

═══════════════════════════════════════════════
```

**JSON Format (if format:json):**
```json
{
  "overview": {
    "total_files": X,
    "insertions": XXX,
    "deletions": XXX,
    "net_change": XXX
  },
  "status_breakdown": {
    "new": X,
    "modified": X,
    "deleted": X,
    "renamed": X
  },
  "type_breakdown": {
    "source": {
      "count": X,
      "insertions": XXX,
      "deletions": XXX
    },
    "tests": {
      "count": X,
      "insertions": XXX,
      "deletions": XXX
    },
    "docs": {
      "count": X,
      "insertions": XXX,
      "deletions": XXX
    },
    "config": {
      "count": X,
      "insertions": XXX,
      "deletions": XXX
    }
  },
  "top_files": [
    {
      "path": "<filename>",
      "insertions": XXX,
      "deletions": XXX,
      "net": XXX
    }
  ],
  "files": [
    {
      "path": "<filename>",
      "status": "<status>",
      "insertions": XXX,
      "deletions": XXX,
      "net": XXX,
      "type": "<file-type>"
    }
  ]
}
```

## File Type Detection

**Source Code:**
```
.js, .jsx, .ts, .tsx (JavaScript/TypeScript)
.py (Python)
.java (Java)
.go (Go)
.rs (Rust)
.rb (Ruby)
.php (PHP)
.c, .cpp, .h (C/C++)
.swift (Swift)
.kt (Kotlin)
```

**Tests:**
```
.test.js, .spec.js
.test.ts, .spec.ts
_test.py, test_*.py
.test.jsx, .spec.tsx
```

**Documentation:**
```
.md (Markdown)
.txt (Text)
.rst (reStructuredText)
.adoc (AsciiDoc)
```

**Configuration:**
```
.json, .yml, .yaml, .toml
.config.js, .config.ts
.env, .env.*
.editorconfig, .gitignore
package.json, tsconfig.json
```

**Styles:**
```
.css, .scss, .sass, .less
```

## Statistical Insights

Provide insights based on stats:

**Large Changes:**
```
INSIGHT: Large change detected
You've changed 500+ lines across 15 files.
Consider splitting into smaller commits.
```

**Many New Files:**
```
INSIGHT: Many new files added
8 new files suggest a new feature (feat).
```

**Deletion Heavy:**
```
INSIGHT: More deletions than insertions
Significant code removal suggests refactoring or cleanup.
```

**Test Heavy:**
```
INSIGHT: High test coverage
40% of changes are in test files.
Good practice to include tests with features.
```

**Documentation Heavy:**
```
INSIGHT: Documentation focused
60% of changes are documentation.
Consider "docs" commit type.
```

## Usage Examples

**Basic stats:**
```bash
/commit-analysis file-stats
```

**JSON output:**
```bash
/commit-analysis file-stats format:json
```

**Detailed breakdown:**
```bash
/commit-analysis file-stats detailed:true
```

**JSON with details:**
```bash
/commit-analysis file-stats format:json detailed:true
```

## Output Format

Return:
- Overview statistics
- Status breakdown
- File type breakdown
- Top changed files
- Per-file details (if detailed:true)
- Statistical insights
- Format as specified (text or JSON)

## Error Handling

**No changes:**
```
NO CHANGES
Working tree is clean. No statistics to display.
```

**Invalid format parameter:**
```
ERROR: Invalid format
Valid formats: text, json
```

## Integration with Agent

The commit-assistant agent uses this operation to:
1. Understand change magnitude
2. Identify dominant change types
3. Provide context for commit decisions
4. Generate statistics for reports

## Usage Example

```bash
# Agent gathers stats before analysis
# User: "how big are my changes?"
# Agent: Invokes file-stats
# Operation: Returns comprehensive statistics
# Agent: "You've changed 15 files with 500+ lines"
```
