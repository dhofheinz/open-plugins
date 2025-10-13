# Changelog

All notable changes to the Git Commit Assistant plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-01-12

### Added

#### Commands
- **/commit** - Create git commits with intelligent message generation
  - Automatic commit message generation from git diff analysis
  - Conventional commits format enforcement
  - Commit type detection (feat, fix, docs, etc.)
  - Scope identification from changed files
  - Interactive message approval workflow
  - Support for custom commit messages
  - Post-commit statistics and suggestions

- **/commit-review** - Analyze changes for atomic commit recommendations
  - Comprehensive change analysis (staged and unstaged)
  - Change type categorization (feat, fix, refactor, docs, test, etc.)
  - File grouping by scope and relatedness
  - Atomicity assessment
  - Split vs single commit recommendations
  - Suggested commit messages for each group
  - Next steps guidance

- **/commit-split** - Interactive atomic commit splitting
  - Intelligent file grouping by type and scope
  - Interactive commit creation workflow
  - Per-group message generation
  - User confirmation for each commit
  - Progress tracking through splitting process
  - Final summary with created commits
  - Support for editing messages and skipping groups

#### Agent
- **commit-assistant** - Specialized git commit expert agent
  - Proactive invocation on commit-related queries
  - Conventional commits expertise
  - Change analysis capabilities
  - Commit message generation
  - Atomic commit guidance
  - Git best practices education
  - Contextual help and examples

#### Hooks
- **PostToolUse hook** - Proactive commit suggestions
  - Triggers after Write/Edit operations
  - Non-intrusive suggestions when 5+ files modified
  - Warning for large change sets (15+ files)
  - Graceful handling of non-git directories

#### Documentation
- Comprehensive README with usage examples
- Conventional commits reference
- Atomic commits guide
- Best practices section
- Troubleshooting guide
- FAQ section
- Tips and tricks

#### Scripts
- **suggest-commit.sh** - Hook handler for proactive suggestions
  - Git repository detection
  - Change counting
  - Threshold-based suggestions
  - Non-blocking implementation

### Features

- **Intelligent Commit Message Generation**: Analyzes git diffs to generate semantic commit messages following conventional commits format
- **Conventional Commits Compliance**: Enforces industry-standard commit format with types, scopes, and subjects
- **Atomic Commit Guidance**: Helps users create focused, single-purpose commits
- **Change Analysis**: Categorizes and groups changes by type and scope
- **Interactive Splitting**: Guides users through creating multiple commits from large change sets
- **Proactive Workflow**: Automatically suggests commits when significant changes accumulate
- **Expert Assistance**: Specialized agent provides contextual help and education
- **Best Practices Enforcement**: Educates users on git workflows and commit quality

### Standards Compliance

- ✅ Complete plugin.json metadata
- ✅ Semantic versioning (1.0.0)
- ✅ MIT license
- ✅ Comprehensive documentation
- ✅ Working commands (3)
- ✅ Specialized agent
- ✅ Configured hooks
- ✅ Error handling
- ✅ No hardcoded secrets
- ✅ Executable scripts with proper permissions

### Technical Details

- **Plugin Category**: Productivity
- **Commands**: 3 (commit, commit-review, commit-split)
- **Agents**: 1 (commit-assistant)
- **Hooks**: 1 (PostToolUse)
- **Scripts**: 1 (suggest-commit.sh)
- **Git Integration**: Full (status, diff, add, commit, log)
- **Conventional Commits**: Full compliance
- **Model**: Inherits from conversation context

## [Unreleased]

### Planned Features

- **commit-amend**: Interactive commit amendment
- **commit-history**: Analyze commit history quality
- **commit-template**: Custom commit message templates
- **pre-commit integration**: Run linters/formatters before commit
- **co-author support**: Add co-authors to commits
- **commit-stats**: Statistics on commit quality over time

### Known Limitations

- Does not handle merge commits (use standard git commands)
- Does not support interactive rebase (use git directly)
- Hook only triggers on Write/Edit, not all file changes
- Single file with multiple unrelated changes requires manual splitting with git add -p

## Version History

### Version Numbering

This plugin follows semantic versioning (MAJOR.MINOR.PATCH):
- **MAJOR**: Breaking changes to commands or behavior
- **MINOR**: New features, commands, or capabilities
- **PATCH**: Bug fixes, documentation updates, performance improvements

### Upgrade Guide

**From**: N/A (initial release)
**To**: 1.0.0

This is the initial release. Install with:

```bash
/plugin_install git-commit-assistant@open-plugins
```

## Contributing

See [CONTRIBUTING.md](https://github.com/dhofheinz/open-plugins/blob/main/CONTRIBUTING.md) for guidelines on contributing to this plugin.

## Links

- **Repository**: https://github.com/dhofheinz/open-plugins
- **Issues**: https://github.com/dhofheinz/open-plugins/issues
- **Plugin Homepage**: https://github.com/dhofheinz/open-plugins/tree/main/plugins/git-commit-assistant
- **Conventional Commits**: https://www.conventionalcommits.org/

---

**Note**: This changelog follows the Keep a Changelog format. Each version documents Added, Changed, Deprecated, Removed, Fixed, and Security sections as applicable.
