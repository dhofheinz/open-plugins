---
description: Create test marketplaces and guide local plugin testing workflows
---

# Plugin Testing Skill

Expert plugin testing guidance with test marketplace creation and validation workflows.

## Operations

- **create-marketplace** - Generate test marketplace structure for local testing
- **install** - Guide local plugin installation process
- **validate-install** - Verify plugin installed correctly
- **test-commands** - Test plugin commands and verify functionality

## Usage Examples

```bash
# Create test marketplace
/plugin-test create-marketplace name:test-market plugin:my-plugin

# Install locally
/plugin-test install plugin:my-plugin@test-market

# Validate installation
/plugin-test validate-install plugin:my-plugin

# Test commands
/plugin-test test-commands plugin:my-plugin
```

## Router Logic

Parse operation from $ARGUMENTS and route to appropriate instruction file:
- "create-marketplace" → `{plugin-path}/commands/plugin-test/create-test-marketplace.md`
- "install" → `{plugin-path}/commands/plugin-test/install-locally.md`
- "validate-install" → `{plugin-path}/commands/plugin-test/validate-installation.md`
- "test-commands" → `{plugin-path}/commands/plugin-test/test-commands.md`

**Current request**: $ARGUMENTS
