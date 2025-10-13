# Plugin Marketplaces

Create and manage plugin marketplaces to distribute Claude Code extensions across teams and communities.

## Overview

A marketplace is a JSON file that lists available plugins and provides:

- Centralized discovery
- Version management
- Team distribution
- Flexible sources (git repositories, GitHub repos, local paths, package managers)

## Prerequisites

- Claude Code installed and running
- Basic familiarity with JSON file format
- For creating marketplaces: Git repository or local development environment

## Add and Use Marketplaces

### Add GitHub Marketplaces

```bash
/plugin marketplace add owner/repo
```

### Add Git Repositories

```bash
/plugin marketplace add https://gitlab.com/company/plugins.git
```

### Add Local Marketplaces for Development

```bash
/plugin marketplace add ./my-marketplace
/plugin marketplace add ./path/to/marketplace.json
/plugin marketplace add https://url.of/marketplace.json
```

### Install Plugins from Marketplaces

```bash
/plugin install plugin-name@marketplace-name
/plugin  # Browse available plugins interactively
```

## Create Your Own Marketplace

### Marketplace File Example

```json
{
  "name": "company-tools",
  "owner": {
    "name": "DevTools Team",
    "email": "devtools@example.com"
  },
  "plugins": [
    {
      "name": "code-formatter",
      "source": "./plugins/formatter",
      "description": "Automatic code formatting on save",
      "version": "2.1.0",
      "author": {
        "name": "DevTools Team"
      }
    }
  ]
}
```

## Key Marketplace Schema Fields

### Required Fields

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Marketplace identifier |
| `owner` | object | Marketplace maintainer information |
| `plugins` | array | List of available plugins |

### Optional Metadata

| Field | Type | Description |
|-------|------|-------------|
| `metadata.description` | string | Brief marketplace description |
| `metadata.version` | string | Marketplace version |

## Hosting and Distribution

### GitHub Repository

1. Create a repository
2. Add `marketplace.json` at root or in `.claude-plugin/` directory
3. Commit and push
4. Users add with: `/plugin marketplace add username/repo`

**Example repository structure**:
```
my-marketplace/
├── marketplace.json
├── README.md
└── plugins/
    ├── plugin-one/
    └── plugin-two/
```

### Git Repository (GitLab, Bitbucket, etc.)

1. Create repository on any Git hosting service
2. Add marketplace.json
3. Commit and push
4. Users add with full URL: `/plugin marketplace add https://gitlab.com/user/repo.git`

### Web Hosting

1. Host marketplace.json on any web server
2. Ensure proper CORS headers if needed
3. Users add with URL: `/plugin marketplace add https://example.com/marketplace.json`

### Local Development

For testing during development:

```bash
/plugin marketplace add ./path/to/local/marketplace
```

## Plugin Source Specifications

### Relative Paths (for monorepo-style marketplaces)

```json
{
  "plugins": [
    {
      "name": "my-plugin",
      "source": "./plugins/my-plugin"
    }
  ]
}
```

### GitHub Repositories

```json
{
  "plugins": [
    {
      "name": "external-plugin",
      "source": "github:username/repo"
    }
  ]
}
```

### Git URLs

```json
{
  "plugins": [
    {
      "name": "git-plugin",
      "source": "https://gitlab.com/user/plugin.git"
    }
  ]
}
```

### Direct URLs

```json
{
  "plugins": [
    {
      "name": "remote-plugin",
      "source": "https://example.com/plugins/my-plugin.zip"
    }
  ]
}
```

### NPM Packages (if supported)

```json
{
  "plugins": [
    {
      "name": "npm-plugin",
      "source": "npm:@company/claude-plugin"
    }
  ]
}
```

## Complete Marketplace Schema

```json
{
  "name": "enterprise-marketplace",
  "version": "1.0.0",
  "owner": {
    "name": "Engineering Team",
    "email": "engineering@company.com",
    "url": "https://company.com/devtools"
  },
  "metadata": {
    "description": "Company-approved Claude Code plugins",
    "homepage": "https://company.com/plugins",
    "repository": "https://github.com/company/plugins"
  },
  "plugins": [
    {
      "name": "code-review",
      "version": "2.0.0",
      "source": "./plugins/code-review",
      "description": "Automated code review with company standards",
      "author": {
        "name": "DevTools Team",
        "email": "devtools@company.com"
      },
      "keywords": ["review", "quality", "standards"],
      "license": "MIT",
      "homepage": "https://company.com/plugins/code-review"
    },
    {
      "name": "deploy-tools",
      "version": "1.5.3",
      "source": "github:company/deploy-plugin",
      "description": "Deployment automation and rollback tools",
      "author": {
        "name": "Platform Team"
      },
      "keywords": ["deployment", "devops", "automation"]
    }
  ]
}
```

## Plugin Entry Fields

### Required Plugin Fields

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Unique plugin identifier within marketplace |
| `source` | string | Where to download/locate the plugin |
| `description` | string | Brief description of plugin functionality |

### Optional Plugin Fields

| Field | Type | Description |
|-------|------|-------------|
| `version` | string | Plugin version (semantic versioning) |
| `author` | object | Plugin author information |
| `keywords` | array | Searchable keywords |
| `license` | string | License identifier (MIT, Apache-2.0, etc.) |
| `homepage` | string | Plugin documentation URL |
| `repository` | string | Source code repository URL |
| `dependencies` | object | Other required plugins |

## Versioning Best Practices

### Semantic Versioning

Follow semver (major.minor.patch):

- **Major**: Breaking changes
- **Minor**: New features (backward compatible)
- **Patch**: Bug fixes

```json
{
  "name": "my-plugin",
  "version": "2.1.3"
}
```

### Version Constraints

When specifying plugin dependencies:

```json
{
  "name": "composite-plugin",
  "dependencies": {
    "base-plugin": "^1.0.0",      // Compatible with 1.x.x
    "util-plugin": "~2.1.0",       // Compatible with 2.1.x
    "core-plugin": "3.0.0"         // Exact version
  }
}
```

## Marketplace Management

### Update Plugin Listings

1. Edit marketplace.json
2. Update plugin version, source, or metadata
3. Commit changes
4. Users run: `/plugin marketplace update`

### Deprecate Plugins

Add deprecation notice:

```json
{
  "name": "old-plugin",
  "version": "1.0.0",
  "source": "./plugins/old-plugin",
  "description": "DEPRECATED: Use new-plugin instead",
  "deprecated": true,
  "deprecationReason": "Replaced by new-plugin v2.0",
  "replacement": "new-plugin"
}
```

### Remove Plugins

Simply remove the plugin entry from the plugins array and commit.

## Access Control and Security

### Private Marketplaces

For internal team use:

1. Host marketplace in private Git repository
2. Users authenticate with Git credentials
3. Add marketplace: `/plugin marketplace add https://private-git.com/team/plugins.git`

### Plugin Verification

Recommended practices:

- **Code review**: Review all plugins before adding to marketplace
- **Version pinning**: Specify exact versions for stability
- **Source control**: Host plugin source in controlled repositories
- **Access logs**: Monitor marketplace access if hosted on web server

### Security Considerations

```json
{
  "plugins": [
    {
      "name": "secure-plugin",
      "version": "1.0.0",
      "source": "./plugins/secure-plugin",
      "description": "Secure plugin with verified source",
      "verified": true,
      "checksum": "sha256:abc123...",
      "security": {
        "scanned": true,
        "scanDate": "2025-10-01",
        "vulnerabilities": "none"
      }
    }
  ]
}
```

## Organization Patterns

### Team Marketplaces

Organize by team or function:

```
company-engineering/
├── frontend-marketplace.json
├── backend-marketplace.json
├── devops-marketplace.json
└── security-marketplace.json
```

### Environment-Specific

Separate by environment:

```
company-plugins/
├── dev-marketplace.json
├── staging-marketplace.json
└── prod-marketplace.json
```

### Tiered Access

Different marketplaces for different permissions:

```
plugins/
├── public-marketplace.json      # Anyone can use
├── internal-marketplace.json    # Company employees
└── admin-marketplace.json       # Admin-only tools
```

## Discovery and Documentation

### Marketplace README

Create comprehensive documentation:

```markdown
# Company Claude Code Plugins

Official marketplace for approved Claude Code plugins.

## Installation

/plugin marketplace add company/claude-plugins

## Available Plugins

### Code Review
Automated code review following company standards
/plugin install code-review

### Deploy Tools
Safe deployment automation with rollback
/plugin install deploy-tools

## Support
Contact devtools@company.com
```

### Plugin Discovery

Make plugins discoverable:

```json
{
  "plugins": [
    {
      "name": "feature-plugin",
      "description": "Detailed description with use cases and examples",
      "keywords": ["feature", "automation", "productivity"],
      "category": "development",
      "featured": true,
      "examples": [
        "/feature command-example",
        "/feature another-example"
      ]
    }
  ]
}
```

## Testing Marketplaces

### Local Testing Workflow

1. Create local marketplace:
```bash
mkdir test-marketplace
cd test-marketplace
# Create marketplace.json
```

2. Add local plugins:
```bash
mkdir -p plugins/test-plugin/.claude-plugin
# Create plugin files
```

3. Test installation:
```bash
claude
/plugin marketplace add ./test-marketplace
/plugin list
/plugin install test-plugin@test-marketplace
```

4. Verify functionality:
```bash
# Test plugin commands, agents, hooks
```

### Automated Testing

Example CI/CD validation:

```bash
#!/bin/bash
# validate-marketplace.sh

# Validate JSON syntax
jq empty marketplace.json

# Check required fields
jq -e '.name' marketplace.json
jq -e '.owner' marketplace.json
jq -e '.plugins' marketplace.json

# Validate each plugin
jq -c '.plugins[]' marketplace.json | while read plugin; do
  echo $plugin | jq -e '.name'
  echo $plugin | jq -e '.source'
  echo $plugin | jq -e '.description'
done

echo "Marketplace validation passed!"
```

## Common Issues and Solutions

### Marketplace Won't Load

**Issue**: Error adding marketplace

**Solutions**:
- Verify JSON syntax with validator
- Check file is accessible at specified URL/path
- Ensure proper permissions for private repositories
- Confirm marketplace.json is at root or in .claude-plugin/

### Plugin Installation Fails

**Issue**: Can't install plugin from marketplace

**Solutions**:
- Verify plugin source path is correct
- Check plugin has valid plugin.json
- Ensure dependencies are available
- Try installing dependencies first

### Updates Not Appearing

**Issue**: Marketplace changes not reflected

**Solutions**:
- Run `/plugin marketplace update` to refresh
- Clear cache if needed
- Verify Git repository has latest commits
- Check network connectivity for remote marketplaces

## Examples

### Minimal Marketplace

```json
{
  "name": "simple-marketplace",
  "owner": {
    "name": "Developer"
  },
  "plugins": [
    {
      "name": "hello-world",
      "source": "./plugins/hello-world",
      "description": "Simple greeting plugin"
    }
  ]
}
```

### Full-Featured Marketplace

```json
{
  "name": "enterprise-tools",
  "version": "2.0.0",
  "owner": {
    "name": "Engineering Excellence Team",
    "email": "eng-excellence@company.com",
    "url": "https://company.com/engineering"
  },
  "metadata": {
    "description": "Curated collection of enterprise-approved Claude Code plugins",
    "homepage": "https://company.com/devtools/plugins",
    "repository": "https://github.com/company/claude-plugins",
    "license": "MIT",
    "keywords": ["enterprise", "productivity", "standards"]
  },
  "plugins": [
    {
      "name": "code-standards",
      "version": "3.1.0",
      "source": "./plugins/code-standards",
      "description": "Enforce company coding standards and best practices",
      "author": {
        "name": "Standards Team",
        "email": "standards@company.com"
      },
      "keywords": ["standards", "linting", "quality"],
      "license": "MIT",
      "homepage": "https://company.com/plugins/code-standards",
      "category": "quality",
      "featured": true
    },
    {
      "name": "security-scanner",
      "version": "2.5.1",
      "source": "github:company/security-scanner-plugin",
      "description": "Automated security vulnerability scanning",
      "author": {
        "name": "Security Team"
      },
      "keywords": ["security", "scanning", "vulnerabilities"],
      "license": "Proprietary",
      "dependencies": {
        "code-standards": "^3.0.0"
      },
      "verified": true
    },
    {
      "name": "deployment-assistant",
      "version": "1.8.0",
      "source": "./plugins/deployment-assistant",
      "description": "Safe deployment workflows with automated rollback",
      "author": {
        "name": "Platform Team"
      },
      "keywords": ["deployment", "devops", "automation"],
      "category": "infrastructure"
    }
  ]
}
```

## Resources

- [Plugin Development Guide](https://docs.claude.com/en/docs/claude-code/plugins)
- [Plugin Reference](https://docs.claude.com/en/docs/claude-code/plugins-reference)
- [Example Marketplaces](https://github.com/anthropics/claude-code)
