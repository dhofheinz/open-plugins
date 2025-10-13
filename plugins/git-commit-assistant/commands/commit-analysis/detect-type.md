---
description: Detect the appropriate conventional commit type based on git diff analysis
---

# Operation: Detect Commit Type

Analyze git changes to determine the conventional commit type (feat, fix, docs, refactor, style, test, chore, perf, ci).

## Parameters from $ARGUMENTS

No parameters required. Analyzes current git diff.

## Workflow

### Step 1: Verify Git Repository and Changes

```bash
git rev-parse --git-dir 2>/dev/null
git diff HEAD
```

If no repository or no changes, exit with appropriate message.

### Step 2: Run Type Detection Algorithm

Execute the type detector script with git diff output:

```bash
git diff HEAD | .scripts/type-detector.py
```

The script implements the decision tree algorithm:

### Detection Algorithm (Implemented in type-detector.py)

```
Priority Order (check in sequence):

1. Check for new files or new exports
   → IF new files OR new functions/classes/exports
   → RETURN "feat"

2. Check for bug fixes
   → IF error handling OR bug keywords (fix, resolve, correct)
   → RETURN "fix"

3. Check for docs-only changes
   → IF only .md files OR only comments changed
   → RETURN "docs"

4. Check for code restructuring
   → IF code moved/renamed but no behavior change
   → RETURN "refactor"

5. Check for style changes
   → IF only whitespace OR formatting changed
   → RETURN "style"

6. Check for test changes
   → IF only test files changed
   → RETURN "test"

7. Check for dependency changes
   → IF package.json OR build files changed
   → RETURN "build"

8. Check for CI changes
   → IF .github/workflows OR CI configs changed
   → RETURN "ci"

9. Check for performance improvements
   → IF optimization keywords OR caching added
   → RETURN "perf"

10. Default
    → RETURN "chore"
```

### Step 3: Analyze Confidence Level

Determine confidence in the detected type:

**High Confidence:**
- Only one type detected
- Clear indicators present
- No ambiguity

**Medium Confidence:**
- Multiple possible types
- Mixed indicators
- Requires human judgment

**Low Confidence:**
- Unclear changes
- Multiple types with equal weight
- Recommend manual review

### Step 4: Identify Alternative Types

If changes could fit multiple types, list alternatives:

```
Primary: feat (High confidence)
Alternatives:
  - test (if test files are significant)
  - docs (if documentation is substantial)
```

### Step 5: Format Detection Result

Return structured type detection:

```
COMMIT TYPE DETECTION
═══════════════════════════════════════════════

DETECTED TYPE: <type>
CONFIDENCE: <High|Medium|Low>

REASONING:
───────────────────────────────────────────────
<detailed explanation of why this type was chosen>

Key Indicators:
- <indicator 1>
- <indicator 2>
- <indicator 3>

FILE ANALYSIS:
───────────────────────────────────────────────
New Files: X (suggests feat)
Bug Fixes: X (suggests fix)
Documentation: X (suggests docs)
Refactoring: X (suggests refactor)
Formatting: X (suggests style)
Tests: X (suggests test)
Dependencies: X (suggests build/chore)
CI/CD: X (suggests ci)

ALTERNATIVE TYPES:
───────────────────────────────────────────────
<if applicable>
- <type>: <reasoning>

RECOMMENDATION:
───────────────────────────────────────────────
<specific recommendation based on analysis>

═══════════════════════════════════════════════
```

## Type Detection Rules

### feat (Feature)
**Indicators:**
- New files created
- New functions/classes exported
- New functionality added
- New components/modules
- Keywords: "add", "implement", "introduce", "create"

**Example Patterns:**
```diff
+export function newFeature() {
+export class NewComponent {
+++ new-file.js
```

### fix (Bug Fix)
**Indicators:**
- Error handling added
- Null/undefined checks
- Validation corrections
- Bug keywords in code
- Keywords: "fix", "resolve", "correct", "handle"

**Example Patterns:**
```diff
+if (!value) throw new Error
+try { ... } catch
-return null
+return value || default
```

### docs (Documentation)
**Indicators:**
- Only .md files changed
- Only comments changed
- JSDoc additions
- README updates
- No code logic changes

**Example Patterns:**
```diff
+++ README.md
+// This function does...
+/** @param {string} name */
```

### refactor (Code Restructuring)
**Indicators:**
- Code moved/reorganized
- Variables/functions renamed
- Logic extracted
- No behavior change
- Keywords: "extract", "rename", "simplify", "reorganize"

**Example Patterns:**
```diff
-function oldName() {
+function newName() {
-inline code block
+extractedFunction()
```

### style (Formatting)
**Indicators:**
- Only whitespace changes
- Indentation fixes
- Semicolon additions/removals
- Code formatting
- No logic changes

**Example Patterns:**
```diff
-  const x = 1
+    const x = 1;
-function(a,b) {
+function(a, b) {
```

### test (Tests)
**Indicators:**
- Only test files changed (.test.js, .spec.js, _test.py)
- Test additions/updates
- Mock/fixture changes
- Keywords: "describe", "it", "test", "expect"

**Example Patterns:**
```diff
+++ tests/feature.test.js
+describe('Feature', () => {
+it('should work', () => {
```

### build (Build System)
**Indicators:**
- package.json changes
- Dependency updates
- Build configuration
- Build scripts

**Example Patterns:**
```diff
+++ package.json
+"dependencies": {
+  "new-lib": "^1.0.0"
```

### ci (CI/CD)
**Indicators:**
- .github/workflows changes
- .gitlab-ci.yml changes
- CI configuration
- Deployment scripts

**Example Patterns:**
```diff
+++ .github/workflows/test.yml
+++ .gitlab-ci.yml
```

### perf (Performance)
**Indicators:**
- Optimization changes
- Caching implementation
- Algorithm improvements
- Keywords: "optimize", "cache", "performance", "faster"

**Example Patterns:**
```diff
+const cache = new Map()
+if (cache.has(key)) return cache.get(key)
-O(n²) algorithm
+O(n log n) algorithm
```

### chore (Other)
**Indicators:**
- Maintenance tasks
- Tooling configuration
- Repository housekeeping
- Doesn't fit other types

## Output Format

Return:
- Detected type
- Confidence level
- Detailed reasoning
- Key indicators found
- Alternative types (if any)
- Specific recommendation

## Error Handling

**No changes:**
```
NO CHANGES TO ANALYZE
Working tree is clean.
```

**Ambiguous changes:**
```
AMBIGUOUS TYPE DETECTION
Multiple types detected with equal weight.
Manual review recommended.

Detected types:
- feat (40%)
- refactor (35%)
- test (25%)
```

## Integration with Agent

The commit-assistant agent uses this operation to:
1. Automatically determine commit type
2. Validate user-provided types
3. Suggest alternative types if ambiguous
4. Guide users in type selection

## Usage Example

```bash
# Agent detects type before generating message
# User: "commit these changes"
# Agent: Invokes detect-type
# Operation: Returns "feat" with high confidence
# Agent: Generates message with "feat" type
```
