# Operation: Handle No Repository Error

Detect and resolve "not a git repository" errors.

## Purpose

When git commands fail with `fatal: not a git repository (or any of the parent directories): .git`, guide users to resolve the issue.

## Parameters

None required - detection is automatic.

## Workflow

### 1. Verify Repository Status

Execute the repository checker script:

```bash
/home/danie/projects/plugins/architect/open-plugins/plugins/git-commit-assistant/commands/commit-error-handling/.scripts/repo-checker.sh
```

This will return JSON:
```json
{
  "is_repo": false,
  "git_dir": null,
  "error": "not a git repository"
}
```

### 2. Analyze Context

Check the current directory:
```bash
pwd
ls -la
```

Determine if:
- User is in the wrong directory
- Repository was never initialized
- .git directory was deleted
- User needs to clone a repository

### 3. Provide Solutions

Present clear, actionable solutions based on the scenario:

#### Scenario A: Need to Initialize New Repository

```
ERROR: Not a Git Repository
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Current directory: /path/to/directory
This is not a git repository.

SOLUTION 1: Initialize a New Repository
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

If you want to start version control here:

1. Initialize git:
   git init

2. Add files:
   git add .

3. Create first commit:
   git commit -m "Initial commit"

4. (Optional) Connect to remote:
   git remote add origin <url>
   git push -u origin main
```

#### Scenario B: Wrong Directory

```
SOLUTION 2: Navigate to Your Repository
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

If your git repository is elsewhere:

1. Find your repository:
   find ~ -type d -name ".git" 2>/dev/null

2. Navigate to it:
   cd /path/to/your/repo

3. Try your command again
```

#### Scenario C: Clone Existing Repository

```
SOLUTION 3: Clone an Existing Repository
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

If you need to clone a remote repository:

1. Clone the repository:
   git clone <repository-url>

2. Navigate into it:
   cd <repository-name>

3. Verify:
   git status
```

### 4. Interactive Guidance

If context is unclear, ask clarifying questions:

```
What would you like to do?

A) Initialize a new git repository here
B) Navigate to an existing repository
C) Clone a repository from a URL
D) Not sure, need more help

Please respond with A, B, C, or D.
```

## Error Handling

### If pwd fails
```
Unable to determine current directory.
Please manually navigate to your git repository.
```

### If user has no permissions
```
Permission denied: Cannot initialize repository here.
Try a directory where you have write permissions.
```

## Output Format

Always provide:
1. **Clear error description** - What's wrong
2. **Context** - Current directory and state
3. **Multiple solutions** - Ordered by likelihood
4. **Specific commands** - Copy-pasteable
5. **Next steps** - What to do after resolution

## Success Indicators

After user follows guidance:
- `git status` works without errors
- User can proceed with git operations
- `.git` directory exists and is valid

## Related Operations

- After resolution, run **diagnose-issues** to verify full repository health
- Before committing, run **handle-no-changes** to ensure there are changes
