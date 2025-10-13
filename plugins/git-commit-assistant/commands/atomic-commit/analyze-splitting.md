# Operation: Analyze Splitting

Determine if current changes should be split into multiple commits.

## Parameters from $ARGUMENTS

- `verbose:true|false` - Detailed analysis output (default: false)
- `threshold:number` - File count threshold for splitting (default: 10)

## Workflow

### Step 1: Get Current Changes

Invoke Bash to get git status and diff:
```bash
git status --porcelain
git diff --cached --stat
git diff --cached --numstat
```

Capture:
- List of modified files
- Number of files changed
- Additions/deletions per file

### Step 2: Run Split Analyzer

Execute the split analyzer script:
```bash
.claude/plugins/git-commit-assistant/commands/atomic-commit/.scripts/split-analyzer.py
```

The script analyzes:
1. **Type diversity**: Multiple commit types (feat, fix, docs, etc.)
2. **Scope diversity**: Multiple modules/components affected
3. **File count**: Too many files changed
4. **Concern separation**: Mixed concerns in changes

### Step 3: Analyze Results

Parse analyzer output to determine:

**Should Split if:**
- Multiple commit types detected (feat + fix + docs)
- Multiple scopes detected (auth + api + ui)
- File count exceeds threshold (>10 files)
- Mixed concerns detected (feature + unrelated refactoring)

**Keep Together if:**
- Single logical change
- All files serve same purpose
- Interdependent changes
- Reasonable file count (≤10)

### Step 4: Generate Recommendation

Create actionable recommendation:

**If should split:**
```
🔀 SPLIT RECOMMENDED

Reason: Multiple types detected (feat, fix, docs)
Files affected: 15
Detected types: feat (8 files), fix (5 files), docs (2 files)

Recommendation: Split into 3 commits
- Commit 1: feat changes (8 files)
- Commit 2: fix changes (5 files)
- Commit 3: docs changes (2 files)

Next steps:
1. Run: /atomic-commit group strategy:type
2. Review groupings
3. Run: /atomic-commit suggest
```

**If already atomic:**
```
✅ ATOMIC COMMIT

Changes represent single logical unit:
- Single type: feat
- Single scope: auth
- File count: 5 files
- Logically cohesive: OAuth implementation

No splitting needed. Proceed with commit.
```

## Output Format

Return structured analysis:
```yaml
should_split: true|false
reason: "Primary reason for recommendation"
metrics:
  file_count: number
  types_detected: [list]
  scopes_detected: [list]
  concerns: [list]
recommendation: "Action to take"
next_steps: [ordered list of commands]
```

## Error Handling

- **No changes**: "No staged or unstaged changes detected. Make changes first."
- **Script failure**: "Analysis failed. Check git repository status."
- **Invalid parameters**: "Invalid parameter. Use verbose:true or threshold:number"

## MCP Tool Integration

Use workspace-mcp for script execution:
- Spawn isolated workspace if needed
- Execute analyzer script
- Parse and return results
- Clean up temporary files

## Examples

**Example 1: Large feature**
```bash
/atomic-commit analyze
→ Should split: 15 files, multiple types
```

**Example 2: Bug fix**
```bash
/atomic-commit analyze verbose:true
→ Atomic: 3 files, single fix
```

**Example 3: Custom threshold**
```bash
/atomic-commit analyze threshold:5
→ Should split: 8 files exceeds threshold
```
