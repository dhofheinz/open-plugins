# Git Commit Assistant

> Intelligent git commit helper with semantic commit message generation, change analysis, and atomic commit guidance using conventional commits format.

## Overview

Git Commit Assistant is a comprehensive Claude Code plugin that helps you create clean, meaningful, and well-structured git commits. It analyzes your changes, generates conventional commit messages, guides you toward atomic commits, and proactively suggests when to commit.

### Features

- **Intelligent Commit Message Generation**: Automatically analyzes git diffs and generates conventional commit messages
- **Change Analysis**: Reviews your changes and recommends whether to create one commit or split into multiple atomic commits
- **Interactive Commit Splitting**: Guides you through creating multiple focused commits from large change sets
- **Conventional Commits Format**: Enforces industry-standard semantic commit messages (feat, fix, docs, etc.)
- **Atomic Commit Guidance**: Ensures each commit represents one logical change
- **Proactive Suggestions**: Automatically suggests commits when you've accumulated significant changes
- **Expert Agent**: Specialized commit-assistant agent for commit-related questions and guidance

### Why Use This Plugin?

**For Individual Developers:**
- Stop struggling with commit messages
- Learn git best practices through use
- Create commits that tell a clear story
- Never forget to commit your work

**For Teams:**
- Consistent commit message format across the team
- Cleaner git history for better collaboration
- Easier code review with focused commits
- Automated changelog generation capabilities

**For Projects:**
- Better maintainability through clear history
- Easier debugging with git bisect
- Safer reverts with atomic commits
- Professional-grade version control

## Installation

### From OpenPlugins Marketplace

```bash
# Add the OpenPlugins marketplace
/plugin marketplace add https://github.com/dhofheinz/open-plugins

# Install the plugin
/plugin install git-commit-assistant@open-plugins

# Restart Claude Code
# (Close and reopen your terminal session)
```

### From Local Development

```bash
# Clone the repository
git clone https://github.com/dhofheinz/open-plugins.git

# Add local marketplace
/plugin marketplace add ./open-plugins

# Install plugin
/plugin install git-commit-assistant@open-plugins
```

### Verification

After installation, verify the plugin is working:

```bash
# Check installed plugins
/plugin list

# Try the commit command
/commit --help
```

## Commands

### `/commit` - Create Intelligent Commits

Create git commits with optional automatic message generation.

**Usage:**

```bash
# Analyze changes and generate commit message automatically
/commit

# Use a custom commit message
/commit "feat(auth): add OAuth authentication"
```

**What it does:**

1. Verifies you're in a git repository
2. Checks for changes to commit
3. If no message provided:
   - Analyzes git diff to understand changes
   - Determines commit type (feat, fix, docs, etc.)
   - Identifies scope (module/component affected)
   - Generates semantic commit message
   - Presents message for approval
4. If message provided:
   - Uses your message directly
5. Stages all changes and creates commit
6. Shows commit summary and statistics
7. Checks for remaining uncommitted changes

**Example: Automatic Message Generation**

```bash
# You've added OAuth authentication across 5 files
/commit

# Output:
PROPOSED COMMIT MESSAGE:
─────────────────────────────────────────────
feat(auth): implement OAuth authentication system

- Add OAuth2 authentication flow
- Implement provider support for Google and GitHub
- Add authentication middleware
- Include configuration management
─────────────────────────────────────────────

FILES TO BE COMMITTED:
 M src/auth/oauth.js
 M src/auth/providers.js
 M src/auth/middleware.js
 M src/auth/config.js
 M src/auth/index.js

Would you like to:
1. Use this message (y)
2. Edit the message (e)
3. Provide your own message (m)
4. Cancel (n)
```

**Example: Custom Message**

```bash
/commit "fix: resolve login timeout issue"

# Creates commit with your message
```

### `/commit-review` - Analyze Changes

Review staged or unstaged changes and receive recommendations on whether to create a single commit or split into multiple atomic commits.

**Usage:**

```bash
/commit-review
```

**What it does:**

1. Analyzes all changes (staged and unstaged)
2. Categorizes changes by type (feat, fix, refactor, docs, test, etc.)
3. Groups related files together
4. Assesses whether changes are atomic
5. Recommends single commit or splitting
6. Suggests commit messages for each group
7. Provides next steps

**Example: Split Recommended**

```bash
/commit-review

# Output:
COMMIT REVIEW ANALYSIS
═════════════════════════════════════════════

CURRENT CHANGES SUMMARY:
────────────────────────────────────────────
Total Files: 12
Insertions: 847 (+)
Deletions: 234 (-)

CHANGE TYPE BREAKDOWN:
────────────────────────────────────────────
FEAT (5 files) - New authentication system
TEST (2 files) - Authentication tests
REFACTOR (3 files) - Code cleanup
DOCS (2 files) - Documentation updates

═══════════════════════════════════════════

RECOMMENDATION: SPLIT INTO ATOMIC COMMITS

Your changes cover multiple concerns and should be
split into separate commits for better history.

═══════════════════════════════════════════

SUGGESTED COMMIT PLAN:
────────────────────────────────────────────

Commit 1: feat(auth): implement OAuth authentication
Commit 2: test(auth): add comprehensive tests
Commit 3: refactor: simplify utility functions
Commit 4: docs: add OAuth authentication guide

═══════════════════════════════════════════

NEXT STEPS:
Run /commit-split for interactive splitting
```

**Example: Single Commit Appropriate**

```bash
/commit-review

# Output:
RECOMMENDATION: SINGLE ATOMIC COMMIT

Your changes are well-organized and form a single
logical unit. A single commit is appropriate here.

NEXT STEPS:
Run /commit to create the commit
```

### `/commit-split` - Interactive Commit Splitting

Guide you through splitting large changes into multiple atomic commits interactively.

**Usage:**

```bash
/commit-split
```

**What it does:**

1. Analyzes all changes in working directory
2. Groups files by change type and scope
3. Presents a splitting plan
4. Guides you through creating each commit interactively
5. For each group:
   - Shows files and changes
   - Generates commit message
   - Asks for confirmation
   - Creates commit
6. Provides final summary

**Example: Interactive Flow**

```bash
/commit-split

# Output:
INTERACTIVE COMMIT SPLITTING
═════════════════════════════════════════════

I've analyzed your changes and identified 4 logical
commits to create.

SPLITTING PLAN:
────────────────────────────────────────────
📦 Commit 1: Authentication Feature (5 files)
📦 Commit 2: Authentication Tests (2 files)
📦 Commit 3: Utility Refactoring (2 files)
📦 Commit 4: Documentation Updates (2 files)
════════════════════════════════════════════

Ready to start? (y/n)
> y

═══════════════════════════════════════════
COMMIT 1 of 4: Authentication Feature
═══════════════════════════════════════════

FILES TO COMMIT (5 files):
 M src/auth/oauth.js          +156
 M src/auth/providers.js      +89
 M src/auth/middleware.js     +73

PROPOSED COMMIT MESSAGE:
feat(auth): implement OAuth authentication system

- Add OAuth2 authentication flow
- Implement provider support
- Add authentication middleware

What would you like to do?
1. Create commit with this message
2. Edit the message
3. Skip this group
4. Abort splitting

> 1

✅ Commit 1 created successfully

Continue to next commit? (y/n)
> y

[... continues for each commit ...]

═══════════════════════════════════════════
COMMIT SPLITTING COMPLETE
═══════════════════════════════════════════

CREATED COMMITS:
✅ abc1234 - feat(auth): implement OAuth
✅ def5678 - test(auth): add comprehensive tests
✅ ghi9012 - refactor: simplify utilities
✅ jkl3456 - docs: add authentication guide

Great job creating atomic commits!
```

## Agent

### `commit-assistant` - Git Commit Expert

A specialized agent that provides intelligent guidance on git commits, message generation, and best practices.

**Invoked automatically when you:**
- Say "create a commit"
- Say "help me commit"
- Ask "what should my commit message be"
- Discuss git commits or messages

**Capabilities:**
- commit-message-generation
- change-analysis
- semantic-commit-formatting
- atomic-commit-guidance
- conventional-commits-enforcement
- git-best-practices

**Example Interactions:**

```
You: "I added authentication, help me commit"

commit-assistant:
Let me analyze your changes...

I see you've implemented OAuth authentication across
5 files. Here's my suggested commit:

feat(auth): implement OAuth authentication system

- Add OAuth2 authentication flow
- Implement provider support for Google and GitHub
- Add authentication middleware

Would you like me to create this commit?
```

```
You: "commit my changes"

commit-assistant:
I've analyzed your changes and found multiple types:

FEAT (3 files): Authentication system
FIX (2 files): Login timeout bug
DOCS (1 file): README update

These should be split into 3 separate commits.
Run /commit-split for interactive splitting.
```

## Hook

### Proactive Commit Suggestions

The plugin includes a PostToolUse hook that monitors file changes and proactively suggests commits when you've accumulated significant modifications.

**Behavior:**
- Triggers after Write or Edit operations
- Checks if you're in a git repository
- Counts modified files
- Suggests commit when 5+ files changed
- Warns when 15+ files changed

**Example:**

After modifying 6 files, you'll see:

```
💡 TIP: You have 6 modified files. Consider running /commit to save your progress.
   Or run /commit-review to analyze your changes first.
```

**Note:** The hook is non-intrusive and only provides helpful suggestions. It never blocks your workflow or forces commits.

## Conventional Commits Reference

This plugin follows the Conventional Commits specification for semantic commit messages.

### Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

| Type | Description | Example |
|------|-------------|---------|
| **feat** | New feature | `feat(auth): add OAuth support` |
| **fix** | Bug fix | `fix(api): resolve null pointer error` |
| **docs** | Documentation | `docs(readme): update installation guide` |
| **style** | Formatting, no code change | `style: apply prettier formatting` |
| **refactor** | Code restructuring | `refactor(utils): extract validation logic` |
| **perf** | Performance improvement | `perf(render): optimize component rendering` |
| **test** | Test updates | `test(auth): add OAuth integration tests` |
| **build** | Build system changes | `build: upgrade webpack to v5` |
| **ci** | CI/CD changes | `ci: add automated testing workflow` |
| **chore** | Maintenance tasks | `chore: update dependencies` |
| **revert** | Revert previous commit | `revert: feat(auth): add OAuth support` |

### Scope

The scope specifies what part of the codebase is affected:
- Module name: `auth`, `api`, `ui`, `database`
- Component name: `login-form`, `user-profile`
- Feature area: `payments`, `notifications`

### Subject Guidelines

- Use imperative mood: "add" not "added" or "adds"
- Keep under 50 characters
- Don't capitalize first letter after colon
- No period at the end
- Be specific and descriptive

### Body (Optional)

- Explain what and why, not how
- Wrap at 72 characters
- Use bullet points for multiple items
- Separate from subject with blank line

### Footer (Optional)

- Breaking changes: `BREAKING CHANGE: description`
- Issue references: `Closes #123`, `Fixes #456`

### Examples

**Good Commits:**

```
feat(auth): add two-factor authentication support

- Implement TOTP-based 2FA
- Add QR code generation for authenticator apps
- Include backup codes for account recovery

Closes #234
```

```
fix(api): resolve race condition in user creation

Race condition occurred when multiple requests
created users simultaneously. Added transaction
locking to prevent duplicate user records.

Fixes #567
```

```
docs(contributing): update PR review guidelines

- Add section on commit message requirements
- Include examples of good PR descriptions
- Document code review checklist
```

**Bad Commits:**

```
Update files
(Too vague, no type, no description)

WIP
(Not descriptive, meaningless)

feat(auth): Added OAuth2 support.
(Wrong tense, unnecessary period)

Fixed bug
(No scope, not specific, no type)
```

## Atomic Commits

### What is an Atomic Commit?

An atomic commit is a single, focused commit that:
- Contains **one logical change**
- Can be **reverted independently** without breaking other functionality
- Has **all tests passing** after the commit
- Is **self-contained and complete**
- Has a **clear, single purpose**

### Why Atomic Commits?

**Benefits:**
- **Easier code review**: Reviewers see one change at a time
- **Safer reverts**: Revert one feature without affecting others
- **Clearer history**: Each commit tells a clear story
- **Better bisecting**: Find bugs by commit efficiently
- **Simpler cherry-picking**: Apply specific changes to other branches

### How to Create Atomic Commits

**Good Atomic Commits:**
- ✅ Add authentication feature (all auth files together)
- ✅ Fix login bug (only the fix, not other changes)
- ✅ Update dependencies (package updates together)
- ✅ Add tests for authentication (test files together)

**Bad Non-Atomic Commits:**
- ❌ Add feature + fix unrelated bug + update docs
- ❌ Refactor + add new functionality
- ❌ Mix of formatting changes and logic changes
- ❌ "WIP" or "misc changes" commits

### Workflow

1. **Before Committing**: Run `/commit-review` to check atomicity
2. **If Split Needed**: Use `/commit-split` for interactive splitting
3. **Create Commits**: Use `/commit` for each atomic change
4. **Verify**: Review commits with `git log -p`

## Best Practices

### Commit Workflow

1. **Make changes** to your code
2. **Run tests** to ensure everything works
3. **Review changes** with `/commit-review`
4. **Split if needed** with `/commit-split`
5. **Create commit** with `/commit`
6. **Verify commit** with `git log -p`
7. **Push** when ready: `git push`

### When to Commit

**Commit when:**
- You've completed a logical unit of work
- All tests pass
- Code is in a working state
- You're about to switch tasks
- End of day (save your work)

**Don't commit when:**
- Code doesn't compile
- Tests are failing
- In the middle of a refactor
- Debug code is still present

### Writing Good Commit Messages

**DO:**
- Use conventional commits format
- Be specific and descriptive
- Explain why, not just what
- Reference issues when applicable
- Keep subject line under 50 characters

**DON'T:**
- Use vague messages ("update files", "fix bug")
- Make "WIP" commits
- Ignore conventional format
- Write novels (be concise)
- Forget to explain non-obvious changes

## Troubleshooting

### Plugin Not Found

**Problem**: `/commit` command not recognized

**Solution**:
```bash
# Check if plugin is installed
/plugin list

# If not installed, install it
/plugin install git-commit-assistant@open-plugins

# Restart Claude Code
```

### Not a Git Repository

**Problem**: "ERROR: Not a git repository"

**Solution**:
```bash
# Initialize git repository
git init

# Or navigate to your git repository
cd /path/to/your/repo
```

### No Changes to Commit

**Problem**: "No changes to commit"

**Solution**:
- Ensure you've saved your files
- Verify you're in the correct directory
- Check git status: `git status`
- Make some changes first

### Git Configuration Missing

**Problem**: "Git requires user.name and user.email"

**Solution**:
```bash
# Configure globally (all repositories)
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Or locally (current repository only)
git config user.name "Your Name"
git config user.email "your.email@example.com"
```

### Hook Not Working

**Problem**: Not seeing proactive commit suggestions

**Solution**:
```bash
# Verify hooks are configured
cat ~/.claude/plugins/git-commit-assistant/hooks/hooks.json

# Check script permissions
ls -l ~/.claude/plugins/git-commit-assistant/scripts/suggest-commit.sh

# Make script executable if needed
chmod +x ~/.claude/plugins/git-commit-assistant/scripts/suggest-commit.sh

# Restart Claude Code
```

## Tips and Tricks

### Quick Commit

For simple changes where the auto-generated message is good:

```bash
/commit
# Review generated message
# Press 'y' to accept
```

### Review Before Committing

Always run review first for complex changes:

```bash
/commit-review    # Analyze first
/commit-split     # Split if recommended
```

### Custom Messages

When you know exactly what you want:

```bash
/commit "feat(api): add rate limiting to endpoints"
```

### Learn Conventional Commits

Ask the agent for help:

```
You: "What's the difference between feat and fix?"
commit-assistant: [explains with examples]

You: "Show me examples of good commit messages"
commit-assistant: [provides examples]
```

### Check Remaining Changes

After committing, check if more work needed:

```bash
git status
/commit-review
```

## Examples

### Example 1: Simple Feature

```bash
# Make changes to add login feature
# Edit src/auth/login.js, src/components/LoginForm.js

# Create commit
/commit

# Output shows:
# feat(auth): add user login functionality
# - Implement login form component
# - Add authentication logic

# Accept and commit
```

### Example 2: Complex Changes

```bash
# Made many changes: auth feature, bug fixes, docs

# Review changes
/commit-review

# Output shows:
# RECOMMENDATION: SPLIT INTO ATOMIC COMMITS
# - feat(auth): 5 files
# - fix(api): 2 files
# - docs: 1 file

# Split interactively
/commit-split

# Creates 3 separate commits
```

### Example 3: Bug Fix

```bash
# Fixed a critical bug

/commit

# Output suggests:
# fix(api): resolve null pointer in user endpoint
#
# Race condition in user creation endpoint caused
# null pointer exceptions. Added null checks and
# improved error handling.

# Accept message
```

## FAQ

**Q: Do I have to use conventional commits format?**
A: No, but it's highly recommended. Conventional commits enable automated tooling, clearer history, and better collaboration.

**Q: Can I override the generated commit message?**
A: Yes! You can edit the message or provide your own with `/commit "your message"`.

**Q: What if I want to commit only some files?**
A: Use git's built-in commands: `git add <files>` then `git commit`. The plugin is designed for committing all changes or using `/commit-split` for selective commits.

**Q: Does this work with GitHub/GitLab/Bitbucket?**
A: Yes! This is a git plugin and works with any git repository regardless of remote hosting.

**Q: Can I disable proactive suggestions?**
A: Yes, remove or modify `hooks/hooks.json` to disable the PostToolUse hook.

**Q: How do I commit to a specific branch?**
A: Switch branches with `git checkout <branch>` first, then use `/commit` as usual.

**Q: What about merge commits?**
A: This plugin is for regular commits. Use standard git commands for merges: `git merge <branch>`.

**Q: Can the agent help with rebase/squash?**
A: The agent provides guidance, but complex git operations should use git commands directly.

## Contributing

Contributions are welcome! This plugin is part of the OpenPlugins project.

**How to contribute:**
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

**See**: [CONTRIBUTING.md](https://github.com/dhofheinz/open-plugins/blob/main/CONTRIBUTING.md) in the main repository.

## License

MIT License

Copyright (c) 2025 OpenPlugins Team

See [LICENSE](LICENSE) file for full license text.

## Support

**Issues**: [GitHub Issues](https://github.com/dhofheinz/open-plugins/issues)

**Documentation**: [OpenPlugins Wiki](https://github.com/dhofheinz/open-plugins/wiki)

**Community**: [Discussions](https://github.com/dhofheinz/open-plugins/discussions)

## Acknowledgments

- Inspired by the [Conventional Commits](https://www.conventionalcommits.org/) specification
- Built for the [Claude Code](https://claude.ai/code) plugin ecosystem
- Part of the [OpenPlugins](https://github.com/dhofheinz/open-plugins) project

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history and changes.

---

**Made with ❤️ for better git commits**

Happy committing! 🎉
