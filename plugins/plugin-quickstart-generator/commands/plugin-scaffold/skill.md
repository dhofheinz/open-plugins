---
description: Generate complete plugin directory structures with all necessary files and proper scaffolding
---

# Plugin Scaffold Skill

Expert plugin structure generation with complete directory scaffolding, metadata creation, and file templates.

## Operations

- **create** - Generate complete plugin directory structure
- **manifest** - Create or update plugin.json with validation
- **readme** - Generate comprehensive README template
- **license** - Add LICENSE file with selected license type
- **complete** - All-in-one: create full plugin structure with all files

## Usage Examples

```bash
# Generate complete structure
/plugin-scaffold create name:my-plugin author:"John Doe"

# Create plugin.json
/plugin-scaffold manifest name:my-plugin version:1.0.0 description:"Plugin description" license:MIT

# Generate README
/plugin-scaffold readme name:my-plugin description:"Full description"

# Add license
/plugin-scaffold license type:MIT plugin:my-plugin

# All-in-one scaffolding
/plugin-scaffold complete name:my-plugin author:"John Doe" license:MIT description:"Complete plugin"
```

## Router Logic

Parse the first word of $ARGUMENTS to determine the requested operation:

1. Extract operation from first word of $ARGUMENTS
2. Parse remaining arguments as key:value parameters
3. Route to appropriate operation file:
   - "create" → Read and execute `{plugin-path}/commands/plugin-scaffold/create-structure.md`
   - "manifest" → Read and execute `{plugin-path}/commands/plugin-scaffold/generate-manifest.md`
   - "readme" → Read and execute `{plugin-path}/commands/plugin-scaffold/create-readme.md`
   - "license" → Read and execute `{plugin-path}/commands/plugin-scaffold/add-license.md`
   - "complete" → Read and execute `{plugin-path}/commands/plugin-scaffold/complete-scaffold.md`

**Error Handling**:
- If operation unknown → List available operations with usage
- If required parameters missing → Request with expected format
- If plugin name invalid → Suggest valid naming pattern (lowercase-hyphen)
- If directory exists → Warn and ask for confirmation to overwrite

**Base directory**: Plugin commands directory
**Current request**: $ARGUMENTS

Parse operation and route to appropriate instruction file now.
