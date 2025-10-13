---
description: Create, validate, and update plugin metadata including plugin.json and marketplace entries
---

# Plugin Metadata Skill

Expert metadata management for Claude Code plugins with validation, versioning, and marketplace entry generation.

## Operations

- **validate** - Validate plugin.json completeness and correctness
- **update-version** - Update version with semantic versioning validation
- **add-keywords** - Add or update keywords for plugin discoverability
- **marketplace-entry** - Generate marketplace.json plugin entry

## Usage Examples

```bash
# Validate metadata
/plugin-metadata validate plugin:my-plugin

# Update version
/plugin-metadata update-version plugin:my-plugin version:1.1.0

# Add keywords
/plugin-metadata add-keywords plugin:my-plugin keywords:"testing,automation,python"

# Generate marketplace entry
/plugin-metadata marketplace-entry plugin:my-plugin source:"github:username/plugin-name"
```

## Router Logic

Parse operation from $ARGUMENTS and route to appropriate instruction file:
- "validate" → `{plugin-path}/commands/plugin-metadata/validate-metadata.md`
- "update-version" → `{plugin-path}/commands/plugin-metadata/update-version.md`
- "add-keywords" → `{plugin-path}/commands/plugin-metadata/add-keywords.md`
- "marketplace-entry" → `{plugin-path}/commands/plugin-metadata/create-marketplace-entry.md`

**Current request**: $ARGUMENTS
