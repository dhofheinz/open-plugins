---
description: Perform comprehensive analysis of git changes including type, scope, and atomicity
---

# Operation: Analyze Changes

Perform full analysis of git repository changes to understand the nature, scope, commit type, and whether changes are atomic.

## Parameters from $ARGUMENTS

No parameters required. Analyzes all current changes.

## Workflow

### Step 1: Verify Git Repository

```bash
git rev-parse --git-dir 2>/dev/null
```

If this fails:
- Return error: "Not a git repository. Run 'git init' to initialize."
- Exit operation

### Step 2: Check for Changes

```bash
git status --short
```

If no changes:
- Return: "No changes to analyze. Working tree is clean."
- Exit operation

### Step 3: Gather Change Information

Run git commands to collect comprehensive data:

```bash
# Get detailed diff
git diff HEAD

# Get status summary
git status --short

# Get diff statistics
git diff --stat HEAD

# Count changed files
git status --short | wc -l
```

### Step 4: Invoke Analysis Scripts

Execute utility scripts to analyze different aspects:

**Type Detection:**
```bash
# Run type detector script
.scripts/type-detector.py
```
This script analyzes the diff output and returns the primary commit type (feat, fix, docs, etc.)

**Scope Identification:**
```bash
# Run scope identifier
.scripts/scope-identifier.sh
```
This script identifies the primary module/component affected

**Atomicity Assessment:**
```bash
# Run atomicity checker
.scripts/atomicity-checker.py
```
This script determines if changes should be split into multiple commits

**Diff Analysis:**
```bash
# Run git diff analyzer
.scripts/git-diff-analyzer.sh
```
This script parses diff output for detailed file and line change information

### Step 5: Compile Analysis Report

Format comprehensive analysis:

```
COMMIT ANALYSIS REPORT
═══════════════════════════════════════════════

CHANGE SUMMARY:
───────────────────────────────────────────────
Files Changed: X files
Insertions: +XXX lines
Deletions: -XXX lines
Net Change: ±XXX lines

COMMIT TYPE DETECTION:
───────────────────────────────────────────────
Primary Type: <feat|fix|docs|refactor|style|test|chore|perf|ci>
Confidence: <High|Medium|Low>
Reasoning: <explanation of why this type was chosen>

Alternative Types: <if applicable>

SCOPE IDENTIFICATION:
───────────────────────────────────────────────
Primary Scope: <module/component name>
Affected Areas: <list of all affected areas>
Scope Confidence: <High|Medium|Low>

ATOMICITY ASSESSMENT:
───────────────────────────────────────────────
Status: <Atomic|Should Split>
Reasoning: <explanation>

If Should Split:
  Recommended Splits:
    1. <type>(<scope>): <description> - X files
    2. <type>(<scope>): <description> - X files
    ...

FILE BREAKDOWN:
───────────────────────────────────────────────
<list files grouped by type/scope>

New Files: <count>
  - <file1>
  - <file2>

Modified Files: <count>
  - <file1> (+XX -YY)
  - <file2> (+XX -YY)

Deleted Files: <count>
  - <file1>

RECOMMENDATIONS:
───────────────────────────────────────────────
- <recommendation 1>
- <recommendation 2>
- <recommendation 3>

═══════════════════════════════════════════════
```

## Output Format

Return structured analysis with:
- Change statistics
- Detected commit type with confidence level
- Identified scope
- Atomicity assessment
- File breakdown
- Specific recommendations

## Error Handling

**Not a git repository:**
```
ERROR: Not a git repository
Initialize with: git init
```

**No changes to analyze:**
```
NO CHANGES
Working tree is clean. Make changes before analyzing.
```

**Git command fails:**
```
ERROR: Git command failed
<error message>
Ensure git is properly configured.
```

## Integration with Agent

The commit-assistant agent uses this operation to:
1. Understand change nature before suggesting commits
2. Determine if changes are atomic or need splitting
3. Identify appropriate commit type and scope
4. Provide context for message generation

## Usage Example

```bash
# Agent workflow:
# User: "analyze my changes"
# Agent invokes: analyze-changes operation
# Operation returns comprehensive report
# Agent presents findings to user
```
