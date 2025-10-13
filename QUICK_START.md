# OpenPlugins - Quick Start

## For Users

### Add Marketplace
```bash
/plugin marketplace add dhofheinz/open-plugins
```

### Install Plugins
```bash
/plugin install plugin-name@open-plugins
```

### Browse Plugins
```bash
/plugin marketplace list open-plugins
```

---

## For Plugin Authors

### Submit Your Plugin

1. **Read Guidelines**: [CONTRIBUTING.md](CONTRIBUTING.md)
2. **Prepare Plugin**: Ensure it meets [quality standards](README.md#plugin-quality-standards)
3. **Test Locally**: Create test marketplace and verify installation
4. **Fork Repository**: Fork dhofheinz/open-plugins on GitHub
5. **Add Entry**: Add your plugin to `.claude-plugin/marketplace.json`
6. **Submit PR**: Create pull request with filled template

### Plugin Entry Format

```json
{
  "name": "your-plugin-name",
  "version": "1.0.0",
  "description": "Brief but informative description",
  "author": {
    "name": "Your Name",
    "email": "you@example.com"
  },
  "source": "github:username/plugin-repo",
  "license": "MIT",
  "keywords": ["keyword1", "keyword2", "keyword3"],
  "category": "development"
}
```

### Categories

Choose ONE:
- `development` - Code generation, scaffolding
- `testing` - Test generation, coverage
- `deployment` - CI/CD, infrastructure
- `documentation` - Docs generation
- `security` - Vulnerability scanning
- `database` - Schema, migrations
- `monitoring` - Performance, logging
- `productivity` - Workflow automation
- `quality` - Linting, formatting
- `collaboration` - Team tools

### Requirements Checklist

- [ ] Valid `plugin.json` with all required fields
- [ ] Comprehensive README.md
- [ ] Open-source license
- [ ] No hardcoded secrets
- [ ] Tested in Claude Code
- [ ] Semantic versioning
- [ ] Public repository

---

## For Maintainers

### Reviewing Submissions

1. **Check PR Template**: All sections completed
2. **Validate JSON**: Syntax is correct
3. **Test Plugin**: Install and verify functionality
4. **Security Review**: No vulnerabilities or secrets
5. **Quality Check**: Meets standards
6. **Merge or Request Changes**

### Adding Plugin to Marketplace

```bash
# Validate JSON
cat .claude-plugin/marketplace.json | python3 -m json.tool

# Test locally
/plugin marketplace add ./open-plugins
/plugin install plugin-name@open-plugins

# Merge PR
git merge --no-ff pr-branch
git push origin main
```

### Release Process

```bash
# Bump version if needed
# Update CHANGELOG.md

git tag -a v1.1.0 -m "Release notes"
git push origin v1.1.0

gh release create v1.1.0 --title "v1.1.0" --notes "Release notes"
```

---

## Common Commands

### Marketplace Management
```bash
/plugin marketplace add dhofheinz/open-plugins      # Add marketplace
/plugin marketplace list                            # List all marketplaces
/plugin marketplace update open-plugins             # Refresh catalog
/plugin marketplace remove open-plugins             # Remove marketplace
```

### Plugin Management
```bash
/plugin install name@open-plugins                   # Install plugin
/plugin uninstall name                              # Remove plugin
/plugin list                                        # List installed
/plugin info name                                   # Show details
/plugin enable name                                 # Enable plugin
/plugin disable name                                # Disable plugin
```

---

## Links

- **Full Documentation**: [README.md](README.md)
- **Contributing Guide**: [CONTRIBUTING.md](CONTRIBUTING.md)
- **Setup Guide**: [SETUP_GUIDE.md](SETUP_GUIDE.md)
- **Issues**: https://github.com/dhofheinz/open-plugins/issues
- **Discussions**: https://github.com/dhofheinz/open-plugins/discussions
- **Claude Code Docs**: https://docs.claude.com/en/docs/claude-code/plugins
