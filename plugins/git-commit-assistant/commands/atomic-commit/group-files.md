# Operation: Group Files

Group related files together for atomic commits.

## Parameters from $ARGUMENTS

- `strategy:type|scope|feature` - Grouping strategy (default: type)
- `show:all|summary` - Output detail level (default: summary)

## Workflow

### Step 1: Get Changed Files

Invoke Bash to get file list:
```bash
git status --porcelain
git diff --cached --name-only
git diff --name-only
```

Capture complete list of changed files.

### Step 2: Execute File Grouper

Run the file grouper script with selected strategy:
```bash
.claude/plugins/git-commit-assistant/commands/atomic-commit/.scripts/file-grouper.sh <strategy>
```

### Step 3: Parse Grouping Results

Process grouper output based on strategy:

**Strategy: type**
Groups files by commit type:
- `feat`: New features or enhancements
- `fix`: Bug fixes
- `docs`: Documentation changes
- `style`: Formatting, whitespace
- `refactor`: Code restructuring
- `test`: Test additions or changes
- `chore`: Build, dependencies, tooling

**Strategy: scope**
Groups files by module/component:
- Extract scope from file path
- Group by common directory structure
- Identify module boundaries
- Example: `auth/`, `api/`, `ui/`, `utils/`

**Strategy: feature**
Groups files by related functionality:
- Analyze dependencies between files
- Group interdependent changes
- Identify feature boundaries
- Requires dependency analysis

### Step 4: Validate Groups

Check each group for atomicity:
- Single logical purpose
- Reasonable size (≤10 files per group)
- Clear scope boundary
- Independent from other groups

### Step 5: Generate Output

Create structured grouping report:

**Summary format:**
```
📦 FILE GROUPS (strategy: type)

Group 1: feat (8 files)
  src/auth/oauth.ts
  src/auth/tokens.ts
  src/config/oauth.config.ts
  ...

Group 2: fix (3 files)
  src/api/endpoints.ts
  src/api/validation.ts
  tests/api.test.ts

Group 3: docs (2 files)
  README.md
  docs/authentication.md

Total: 3 groups, 13 files
```

**Detailed format (show:all):**
```
📦 GROUP 1: feat (8 files)

Files:
  ✓ src/auth/oauth.ts (+145, -0)
  ✓ src/auth/tokens.ts (+78, -0)
  ✓ src/auth/providers/github.ts (+95, -0)
  ✓ src/auth/providers/google.ts (+92, -0)
  ✓ src/config/oauth.config.ts (+34, -0)
  ✓ src/types/auth.types.ts (+56, -0)
  ✓ tests/auth/oauth.test.ts (+123, -0)
  ✓ tests/auth/tokens.test.ts (+67, -0)

Scope: auth
Purpose: OAuth 2.0 implementation
Dependencies: None
Atomic: ✅ Yes

Suggested commit:
  feat(auth): implement OAuth 2.0 authentication
```

## Output Format

Return structured groupings:
```yaml
strategy: type|scope|feature
groups:
  - id: 1
    type: feat|fix|docs|etc
    scope: module_name
    files: [list]
    stats:
      file_count: number
      additions: number
      deletions: number
    atomic: true|false
    suggested_message: "commit message"
summary:
  total_groups: number
  total_files: number
  ready_for_commit: true|false
```

## Error Handling

- **No changes**: "No files to group. Make changes first."
- **Invalid strategy**: "Invalid strategy. Use: type, scope, or feature"
- **Grouping failed**: "Could not group files. Check git status."
- **Too many groups**: "Warning: 10+ groups detected. Consider broader grouping."

## Grouping Strategies Explained

### Type-based Grouping
Groups files by conventional commit type. Best for:
- Mixed-type changes
- Clear type boundaries
- Standard workflow

Algorithm:
1. Analyze diff content for each file
2. Detect commit type from changes
3. Group files of same type
4. Validate each group

### Scope-based Grouping
Groups files by module/component. Best for:
- Changes across multiple modules
- Modular codebase structure
- Component isolation

Algorithm:
1. Extract directory structure
2. Identify module boundaries
3. Group files by module
4. Validate scope coherence

### Feature-based Grouping
Groups files by related functionality. Best for:
- Complex feature implementation
- Interdependent changes
- Logical feature units

Algorithm:
1. Analyze file dependencies
2. Build dependency graph
3. Group connected components
4. Validate feature boundaries

## Examples

**Example 1: Type grouping**
```bash
/atomic-commit group strategy:type
→ Groups: feat (5), fix (2), docs (1)
```

**Example 2: Scope grouping**
```bash
/atomic-commit group strategy:scope show:all
→ Detailed groups by module
```

**Example 3: Feature grouping**
```bash
/atomic-commit group strategy:feature
→ Groups by related functionality
```

## Integration Notes

This operation is typically called:
1. After `analyze-splitting` recommends splitting
2. Before `suggest-commits` generates messages
3. As part of `interactive-split` workflow

Results feed into commit suggestion and sequence planning.
