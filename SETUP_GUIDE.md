# OpenPlugins Marketplace - Setup Guide

This guide will walk you through setting up and publishing the OpenPlugins marketplace to GitHub.

## Prerequisites

- Git installed and configured
- GitHub account
- GitHub CLI (`gh`) installed (optional but recommended)
- Claude Code installed

## Step 1: Verify Marketplace Structure

Ensure all files are in place:

```bash
cd /home/danie/projects/plugins/architect/open-plugins

# Verify structure
tree -L 3
```

Expected structure:
```
open-plugins/
├── .claude-plugin/
│   └── marketplace.json
├── .github/
│   ├── ISSUE_TEMPLATE/
│   │   ├── bug-report.md
│   │   ├── feature-request.md
│   │   └── plugin-submission.md
│   └── PULL_REQUEST_TEMPLATE.md
├── .gitignore
├── CHANGELOG.md
├── CODE_OF_CONDUCT.md
├── CONTRIBUTING.md
├── LICENSE
└── README.md
```

## Step 2: Validate Marketplace JSON

```bash
# Validate JSON syntax
cat .claude-plugin/marketplace.json | python3 -m json.tool

# Should output formatted JSON with no errors
```

## Step 3: Choose Your Publishing Method

You have three options for publishing to GitHub:

### **Option A: Automated Script (Recommended - Easiest)**

Use the provided automation script that handles everything:

```bash
cd /home/danie/projects/plugins/architect/open-plugins

# Interactive mode - prompts for all details
./scripts/publish-to-github.sh

# Or preview what it will do first
./scripts/publish-to-github.sh --dry-run

# Or fully automated (CI/CD)
./scripts/publish-to-github.sh --yes --owner dhofheinz

# Get help on all options
./scripts/publish-to-github.sh --help
```

**What the script does:**
1. ✅ Validates marketplace structure
2. ✅ Checks prerequisites (git, gh CLI)
3. ✅ Initializes git repository (if needed)
4. ✅ Creates initial commit
5. ✅ Creates GitHub repository
6. ✅ Pushes to GitHub
7. ✅ Creates release tag (optional)

**Script Features:**
- **Dry-run mode**: Preview changes before making them (`--dry-run`)
- **Verbose mode**: See detailed output for debugging (`--verbose`)
- **Automated mode**: Non-interactive for CI/CD (`--yes`)
- **Force mode**: Override safety checks (`--force`)
- **Idempotent**: Safe to run multiple times
- **Validation**: Input sanitization and error checking
- **Helpful errors**: Clear messages with solutions

**Examples:**

```bash
# Preview without making changes
./scripts/publish-to-github.sh --dry-run --verbose

# Fully automated publish
./scripts/publish-to-github.sh \
  --yes \
  --owner dhofheinz \
  --repo open-plugins

# Force republish existing repo
./scripts/publish-to-github.sh --force --owner dhofheinz
```

Skip to **Step 5** (Configure Repository Settings) if using the automated script.

---

### **Option B: Manual with GitHub CLI**

If you prefer manual control or want to learn the steps:

#### Step 3.1: Initialize Git Repository

```bash
# Initialize repository
git init

# Add all files
git add .

# Create initial commit
git commit -m "feat: initialize OpenPlugins marketplace

- Complete marketplace structure with metadata
- Comprehensive documentation (README, CONTRIBUTING, CODE_OF_CONDUCT)
- GitHub templates for issues and PRs
- Plugin quality standards and review process
- MIT License for marketplace structure
- Initial version 1.0.0
"

# Verify commit
git log --oneline
```

#### Step 3.2: Create GitHub Repository

```bash
# Create public repository
gh repo create dhofheinz/open-plugins \
  --public \
  --description "AI-curated marketplace of high-quality, open-source Claude Code plugins" \
  --homepage "https://github.com/dhofheinz/open-plugins"

# Push to GitHub
git remote add origin https://github.com/dhofheinz/open-plugins.git
git branch -M main
git push -u origin main
```

---

### **Option C: Manual with GitHub Web Interface**

If you don't have GitHub CLI installed:

#### Step 3.1: Initialize Git Repository

```bash
# Initialize repository
git init

# Add all files
git add .

# Create initial commit
git commit -m "feat: initialize OpenPlugins marketplace

- Complete marketplace structure with metadata
- Comprehensive documentation (README, CONTRIBUTING, CODE_OF_CONDUCT)
- GitHub templates for issues and PRs
- Plugin quality standards and review process
- MIT License for marketplace structure
- Initial version 1.0.0
"
```

#### Step 3.2: Create GitHub Repository

1. Go to https://github.com/new
2. Fill in repository details:
   - **Owner**: dhofheinz
   - **Repository name**: open-plugins
   - **Description**: AI-curated marketplace of high-quality, open-source Claude Code plugins
   - **Visibility**: Public
   - **Do NOT** initialize with README, .gitignore, or license (we already have these)
3. Click "Create repository"
4. Follow GitHub's instructions to push existing repository:

```bash
git remote add origin https://github.com/dhofheinz/open-plugins.git
git branch -M main
git push -u origin main
```

---

## Step 4: Configure Repository Settings (All Methods)

After creating the repository on GitHub:

1. **Enable Discussions**:
   - Go to repository Settings → Features
   - Check "Discussions"
   - Create initial categories: General, Q&A, Ideas, Show and Tell

2. **Configure Issues**:
   - Go to repository Issues
   - Verify issue templates appear correctly

3. **Set Repository Topics**:
   - Go to repository home page
   - Click gear icon next to "About"
   - Add topics: `claude-code`, `plugins`, `marketplace`, `open-source`, `community`

4. **Enable Branch Protection** (Optional but recommended):
   - Settings → Branches → Add rule
   - Branch name pattern: `main`
   - Enable: "Require pull request reviews before merging"
   - Enable: "Require status checks to pass before merging"

## Step 5: Create Initial Release (Optional)

**Note:** The automated script (Option A) can create the release automatically. If you used that, skip this step.

For manual publishing:

```bash
# Create annotated tag for v1.0.0
git tag -a v1.0.0 -m "Initial release of OpenPlugins marketplace

Features:
- Complete marketplace infrastructure
- Comprehensive documentation
- Plugin submission process
- Quality standards and review guidelines
- Community governance
"

# Push tag to GitHub
git push origin v1.0.0

# Create GitHub release (if using gh CLI)
gh release create v1.0.0 \
  --title "OpenPlugins v1.0.0 - Initial Release" \
  --notes "First public release of OpenPlugins marketplace. Ready for community plugin submissions."
```

## Step 6: Test Marketplace Installation

Test that users can add your marketplace:

```bash
# Add marketplace using GitHub URL
/plugin marketplace add dhofheinz/open-plugins

# Or use raw URL
/plugin marketplace add https://raw.githubusercontent.com/dhofheinz/open-plugins/main/.claude-plugin/marketplace.json

# Verify marketplace was added
/plugin marketplace list
```

Expected output:
```
✓ open-plugins marketplace added successfully
  Source: https://github.com/openplugins/open-plugins
  Plugins: 0 (marketplace is new, plugins coming soon!)
```

## Step 7: Update Placeholder URLs (If Needed)

After GitHub repository is created, update placeholder URLs if you used a different owner/repo name:

```bash
# Update README.md badges and links (if needed)
# Update CONTRIBUTING.md links (if needed)
# Update marketplace.json URLs to actual repository

# Example: Update marketplace.json if using different org/repo name
# Replace "openplugins/open-plugins" with your actual repo
```

Note: This marketplace is already configured for dhofheinz/open-plugins. If you need to publish to a different GitHub organization or username, update these files:

1. `.claude-plugin/marketplace.json`:
   - `metadata.homepage`
   - `metadata.repository`
   - `owner.url`

2. `README.md`:
   - All GitHub links
   - Installation commands
   - Badge URLs

3. `CONTRIBUTING.md`:
   - Repository URLs
   - Example commands

## Step 8: Announce and Promote

Once published:

1. **Create Announcement**:
   - Post in GitHub Discussions → Announcements
   - Share on social media
   - Post in Claude Code communities

2. **Invite Contributors**:
   - Share submission guidelines
   - Reach out to plugin authors
   - Encourage community participation

3. **Monitor Submissions**:
   - Watch for new issues and PRs
   - Respond promptly to submissions
   - Review plugins thoroughly

## Usage Examples for End Users

Once your marketplace is live, users can:

### Add the Marketplace

```bash
# Using GitHub shorthand
/plugin marketplace add dhofheinz/open-plugins

# Using full GitHub URL
/plugin marketplace add https://github.com/dhofheinz/open-plugins

# Using raw JSON URL
/plugin marketplace add https://raw.githubusercontent.com/dhofheinz/open-plugins/main/.claude-plugin/marketplace.json
```

### Browse Plugins

```bash
# List all plugins in marketplace
/plugin marketplace list open-plugins

# Search for specific plugins
/plugin search keyword
```

### Install Plugins

```bash
# Install plugin from OpenPlugins marketplace
/plugin install plugin-name@open-plugins

# Install specific version
/plugin install plugin-name@open-plugins@1.2.0
```

### Update Marketplace Catalog

```bash
# Refresh to get latest plugin list
/plugin marketplace update open-plugins
```

## Team/Organization Setup

For team use, add marketplace to `.claude/settings.json`:

```json
{
  "marketplaces": [
    "dhofheinz/open-plugins"
  ],
  "plugins": [
    "recommended-plugin@open-plugins",
    "another-plugin@open-plugins"
  ]
}
```

This automatically adds the marketplace for all team members.

## Maintenance Tasks

### Adding Plugins

When accepting plugin submissions:

1. Review PR against quality checklist
2. Test plugin installation and functionality
3. Verify no security issues
4. Merge PR to add plugin to `marketplace.json`
5. Plugin becomes immediately available to users

### Updating Plugin Versions

When plugin authors submit version updates:

1. Verify new version exists in plugin repository
2. Test updated version
3. Update version in `marketplace.json`
4. Merge and tag new marketplace release (optional)

### Removing Plugins

If plugin needs removal:

1. Add deprecation notice (90-day warning)
2. Update `marketplace.json` after grace period
3. Document removal in CHANGELOG.md
4. Notify users via Discussions

## Troubleshooting

### Users Can't Add Marketplace

Check:
- Repository is public
- `marketplace.json` is in `.claude-plugin/` directory
- JSON syntax is valid
- GitHub repository is accessible

### Plugins Don't Install

Verify:
- Plugin source URL is correct
- Plugin repository is public
- Plugin has valid `plugin.json`
- Plugin structure follows Claude Code standards

### JSON Validation Fails

```bash
# Validate locally
cat .claude-plugin/marketplace.json | python3 -m json.tool

# Check for common issues:
# - Missing commas
# - Trailing commas
# - Invalid escaping
# - Unclosed brackets
```

## Support and Resources

- **Issues**: https://github.com/dhofheinz/open-plugins/issues
- **Discussions**: https://github.com/dhofheinz/open-plugins/discussions
- **Claude Code Docs**: https://docs.claude.com/en/docs/claude-code/plugins
- **Plugin Reference**: https://docs.claude.com/en/docs/claude-code/plugins-reference

## Quick Reference: Automated Script Options

The `publish-to-github.sh` script supports these options:

```bash
# Show all options
./scripts/publish-to-github.sh --help

# Common usage patterns
./scripts/publish-to-github.sh                    # Interactive
./scripts/publish-to-github.sh --dry-run          # Preview
./scripts/publish-to-github.sh --verbose          # Debug
./scripts/publish-to-github.sh --yes --owner USER # Automated

# Advanced options
--force              # Override safety checks
--skip-validation    # Skip marketplace validation
--owner OWNER        # GitHub username/org
--repo REPO          # Repository name
```

**Exit Codes:**
- `0` - Success
- `1` - Validation failed
- `2` - Git error
- `3` - GitHub error
- `4` - User cancelled
- `5` - Missing prerequisites
- `6` - Invalid input

## Next Steps

### Quick Start (Using Automated Script):
1. Run `./scripts/publish-to-github.sh --dry-run` to preview
2. Run `./scripts/publish-to-github.sh` to publish
3. Configure repository settings (Step 4)
4. Test marketplace installation (Step 6)
5. Announce to community (Step 8)

### Manual Publishing:
1. Follow Steps 3B or 3C for manual git/GitHub setup
2. Configure repository settings (Step 4)
3. Create release (Step 5)
4. Test marketplace installation (Step 6)
5. Update URLs if needed (Step 7)
6. Announce to community (Step 8)

---

**Ready to publish?** Use the automated script for the easiest experience, or follow the manual steps for full control!
