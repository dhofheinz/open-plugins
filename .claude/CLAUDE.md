# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

**OpenPlugins** is a community-curated marketplace for Claude Code plugins. This repository contains:
- Marketplace infrastructure (`.claude-plugin/marketplace.json`)
- Sample plugins demonstrating best practices (`plugins/` directory)
- Publishing and validation automation (`scripts/`)
- Comprehensive documentation for contributors

## Repository Structure

```
open-plugins/
├── .claude-plugin/
│   └── marketplace.json          # Marketplace catalog and metadata
├── plugins/                       # Plugin implementations (mono-repo)
│   ├── git-commit-assistant/     # Intelligent git commit helper
│   ├── marketplace-validator-plugin/  # Validation and quality tools
│   └── plugin-quickstart-generator/   # Plugin scaffolding generator
├── scripts/
│   ├── publish-to-github.sh      # Automated GitHub publishing
│   └── validate-marketplace.sh    # Marketplace validation
├── .github/                       # Issue/PR templates
├── CONTRIBUTING.md                # Plugin submission guidelines
├── SETUP_GUIDE.md                # Publishing and setup instructions
└── README.md                      # User-facing documentation
```

## Common Commands

### Validation
```bash
# Validate marketplace.json syntax
cat .claude-plugin/marketplace.json | python3 -m json.tool

# Run comprehensive validation (includes schema, security, best practices)
./scripts/validate-marketplace.sh

# Validate specific plugin only
./scripts/validate-marketplace.sh --plugin plugin-name

# Validate with verbose output
./scripts/validate-marketplace.sh --verbose
```

### Local Testing
```bash
# Test marketplace installation locally
/plugin marketplace add ./

# Install plugin from local marketplace
/plugin install plugin-name@open-plugins

# List available plugins
/plugin marketplace list open-plugins

# Remove test marketplace
/plugin marketplace remove open-plugins
```

### Publishing
```bash
# Automated GitHub publishing (recommended)
./scripts/publish-to-github.sh

# Preview without making changes
./scripts/publish-to-github.sh --dry-run

# Non-interactive mode (for CI/CD)
./scripts/publish-to-github.sh --yes --owner dhofheinz
```

### Plugin Development
```bash
# Create new plugin structure (requires plugin-quickstart-generator installed)
/quickstart-plugin

# Validate plugin structure and quality
/validate-plugin ./plugins/your-plugin

# Test plugin locally before submission
mkdir test-marketplace/.claude-plugin
# Add plugin to test marketplace.json
/plugin marketplace add ./test-marketplace
/plugin install your-plugin@test-marketplace
```

## Architecture Patterns

### Marketplace Structure
The marketplace uses a **mono-repository pattern** where:
- Each plugin is self-contained in `plugins/<plugin-name>/`
- Plugins reference their local path via `"source": "./plugins/plugin-name"`
- Each plugin has its own `.claude-plugin/plugin.json` manifest
- Plugins can be independently developed and tested

### Plugin Architecture
Plugins in this marketplace follow the **skill-based architecture**:
- `skill.md` files act as routers/orchestrators
- Sub-commands provide specific operations (hidden from slash command list)
- Skills parse `$ARGUMENTS` and route to appropriate sub-commands
- Example: `/commit-analysis analyze` routes to `commands/commit-analysis/analyze-changes.md`

### Validation Architecture
The validator plugin uses **layered validation**:
1. **Schema Validation**: JSON structure and required fields
2. **Security Scanning**: Secrets, permissions, URLs
3. **Best Practices**: Naming, versioning, categories
4. **Documentation**: README, changelog, examples
5. **Quality Analysis**: Scoring and improvement suggestions

## Key Concepts

### Plugin Submission Flow
1. Author creates plugin meeting quality standards
2. Author forks this repository
3. Author adds entry to `.claude-plugin/marketplace.json`
4. Author submits PR using template
5. Maintainers review against checklist
6. Plugin merged → immediately available to all users

### Marketplace Categories
Standard categories (choose ONE per plugin):
- `development` - Code generation, scaffolding, refactoring
- `testing` - Test generation, coverage, quality assurance
- `deployment` - CI/CD, infrastructure, release automation
- `documentation` - Docs generation, API documentation
- `security` - Vulnerability scanning, secret detection
- `database` - Schema design, migrations, queries
- `monitoring` - Performance analysis, logging
- `productivity` - Workflow automation, task management
- `quality` - Linting, formatting, code review
- `collaboration` - Team tools, communication

### Quality Standards (Enforced)
- **Required**: Valid `plugin.json`, README, LICENSE, semantic versioning, no secrets
- **Recommended**: CHANGELOG, examples, error handling, best practices compliance
- **Security**: No hardcoded credentials, safe input handling, HTTPS for external resources

## File Format Conventions

### marketplace.json Structure
```json
{
  "name": "marketplace-name",
  "owner": { "name": "", "email": "", "url": "" },
  "plugins": [
    {
      "name": "lowercase-hyphen-format",
      "version": "MAJOR.MINOR.PATCH",
      "description": "50-200 character description",
      "author": { "name": "", "email": "", "url": "" },
      "source": "./plugins/plugin-name" or "github:user/repo",
      "license": "MIT | Apache-2.0 | GPL-3.0",
      "keywords": ["3-7", "searchable", "terms"],
      "category": "one-of-standard-categories"
    }
  ]
}
```

### Plugin Manifest (plugin.json)
Each plugin must have `.claude-plugin/plugin.json`:
```json
{
  "name": "plugin-name",
  "version": "1.0.0",
  "description": "Plugin purpose",
  "author": { "name": "", "email": "" },
  "license": "MIT",
  "repository": { "type": "git", "url": "" },
  "homepage": "https://...",
  "keywords": ["relevant", "terms"]
}
```

## Important Workflows

### Adding a New Plugin to Marketplace
1. Validate plugin meets requirements: `./scripts/validate-marketplace.sh --plugin new-plugin`
2. Add entry to `plugins` array in `.claude-plugin/marketplace.json` (at END)
3. Test locally: `/plugin marketplace add ./ && /plugin install new-plugin@open-plugins`
4. Commit with conventional commit message: `feat: add new-plugin to marketplace`
5. Create PR with complete template

### Updating Plugin Version
1. Update plugin's own `plugin.json` version
2. Update version in marketplace.json entry
3. Ensure plugin has changelog entry
4. Test installation: `/plugin marketplace update open-plugins && /plugin install name@open-plugins`
5. Commit: `chore: update new-plugin to v1.1.0`

### Removing a Plugin
1. Add deprecation notice to marketplace.json (90-day grace period)
2. Update documentation with removal notice
3. After grace period, remove from plugins array
4. Document in CHANGELOG.md
5. Notify via GitHub Discussions

## Testing Strategy

### Pre-Submission Testing (Authors)
```bash
# Create test marketplace structure
mkdir -p my-test-marketplace/.claude-plugin

# Create test marketplace.json pointing to your plugin
cat > my-test-marketplace/.claude-plugin/marketplace.json <<'EOF'
{
  "name": "test-marketplace",
  "owner": {"name": "Test"},
  "plugins": [{
    "name": "my-plugin",
    "source": "/absolute/path/to/my-plugin",
    ...
  }]
}
EOF

# Add test marketplace
/plugin marketplace add ./my-test-marketplace

# Test installation
/plugin install my-plugin@test-marketplace

# Verify commands work
/my-command-name arg1 arg2
```

### Validation Testing (Maintainers)
```bash
# Full validation before merging PR
./scripts/validate-marketplace.sh --verbose

# Test specific plugin from PR
git fetch origin pull/123/head:pr-123
git checkout pr-123
./scripts/validate-marketplace.sh --plugin submitted-plugin

# Test installation from updated marketplace
/plugin marketplace add ./
/plugin install submitted-plugin@open-plugins
```

## Git Workflow

### Commit Message Format
Follow conventional commits:
```
feat: add new-plugin to marketplace
fix: correct plugin source URL for existing-plugin
chore: update marketplace metadata
docs: improve contribution guidelines
```

### Branch Naming
```
add-plugin-name          # For new plugin submissions
update-plugin-name       # For version updates
fix-plugin-name-issue    # For bug fixes
docs/improve-readme      # For documentation changes
```

### PR Requirements
- Use provided PR template (`.github/PULL_REQUEST_TEMPLATE.md`)
- Complete all checklist items
- Ensure CI validation passes
- Respond to review feedback within 1 week

## Scripts Reference

### publish-to-github.sh
Automated GitHub publishing with validation and safety checks.

**Options:**
- `--dry-run`: Preview without making changes
- `--verbose`: Show detailed output
- `--yes`: Skip confirmations (CI/CD mode)
- `--force`: Override safety checks
- `--owner USER`: GitHub username/org
- `--repo REPO`: Repository name

**Exit codes:**
- 0: Success
- 1: Validation failed
- 2: Git error
- 3: GitHub error
- 4: User cancelled
- 5: Missing prerequisites
- 6: Invalid input

### validate-marketplace.sh
Comprehensive marketplace and plugin validation.

**Options:**
- `--plugin NAME`: Validate specific plugin only
- `--verbose`: Detailed validation output
- `--json`: Output results in JSON format
- `--fail-fast`: Exit on first error

**Validates:**
- JSON syntax
- Required fields presence
- Semantic versioning format
- Source URL accessibility
- Category validity
- Keyword appropriateness
- License compliance
- Security issues (hardcoded secrets, suspicious patterns)

## Troubleshooting

### "Plugin not found" after marketplace update
- Verify plugin source path is correct (relative paths must be `./plugins/name`)
- Check plugin has valid `.claude-plugin/plugin.json`
- Ensure plugin directory structure is correct
- Try removing and re-adding marketplace: `/plugin marketplace remove open-plugins && /plugin marketplace add ./`

### JSON validation fails
- Run: `cat .claude-plugin/marketplace.json | python3 -m json.tool`
- Common issues: trailing commas, missing commas between entries, unescaped quotes
- Use JSON validator: https://jsonlint.com/

### Plugin installs but commands don't work
- Verify command files are in `commands/` directory at plugin root
- Check command files have proper frontmatter with `description` field
- Ensure commands use `.md` extension
- Restart Claude Code after installation
- Check permissions: `find plugins/plugin-name -name "*.md" -ls`

### Local marketplace testing fails
- Use absolute paths or `./` relative paths in test marketplace
- Ensure `.claude-plugin` directory exists in both marketplace and plugin
- Verify plugin.json has all required fields
- Check marketplace.json `plugins` array syntax

## Security Considerations

### What to Check in PRs
- No hardcoded API keys, tokens, or passwords
- No suspicious external script downloads
- Bash commands use safe input handling
- External URLs use HTTPS
- Permissions are minimal and justified
- Dependencies are from trusted sources

### Automatic Security Scans
The validator automatically checks for:
- Common secret patterns (API keys, tokens, passwords)
- Suspicious file operations
- Unsafe URL patterns
- Excessive permissions in hooks
- Malicious code patterns

### Manual Review Required
Even with automation, manually verify:
- Purpose and legitimacy of external dependencies
- Appropriateness of requested permissions
- Plugin functionality matches description
- Author reputation and plugin provenance

## Resources

### Official Documentation
- Claude Code Plugins: https://docs.claude.com/en/docs/claude-code/plugins
- Plugin Reference: https://docs.claude.com/en/docs/claude-code/plugins-reference
- Marketplaces: https://docs.claude.com/en/docs/claude-code/plugin-marketplaces

### Community Resources
- Repository: https://github.com/dhofheinz/open-plugins
- Issues: https://github.com/dhofheinz/open-plugins/issues
- Discussions: https://github.com/dhofheinz/open-plugins/discussions

### Development Tools
- JSON Validator: https://jsonlint.com/
- Regex Tester: https://regex101.com/
- Semantic Versioning: https://semver.org/
- Keep a Changelog: https://keepachangelog.com/
