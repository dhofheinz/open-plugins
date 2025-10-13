## Operation: Detect Target Type

Automatically detect whether the validation target is a marketplace or plugin based on file structure.

### Parameters from $ARGUMENTS

- **path**: Path to the target directory (required)
  - Format: `path:/path/to/target` or `path:.` for current directory
  - Default: `.` (current directory)

### Detection Logic

Execute the target detection algorithm:

```bash
# Run the target detector script
bash .scripts/target-detector.sh "$TARGET_PATH"
```

The detection script will:
1. Check for `.claude-plugin/marketplace.json` → **Marketplace**
2. Check for `.claude-plugin/plugin.json` → **Plugin**
3. Check for both → **Multi-target**
4. Check for neither → **Unknown**

### Workflow

1. **Extract Path Parameter**
   ```
   Parse $ARGUMENTS for path parameter
   IF path not provided:
     SET path="."
   ```

2. **Execute Detection**
   ```
   RUN .scripts/target-detector.sh "$path"
   CAPTURE output and exit code
   ```

3. **Report Results**
   ```
   Output format:
   {
     "target_type": "marketplace|plugin|multi-target|unknown",
     "path": "/absolute/path/to/target",
     "files_found": ["marketplace.json", "plugin.json"],
     "confidence": "high|medium|low"
   }
   ```

### Examples

**Detect current directory:**
```bash
/validation-orchestrator detect path:.
```

**Detect specific path:**
```bash
/validation-orchestrator detect path:/path/to/plugin
```

### Error Handling

- **Path does not exist**: Report error with clear message
- **No .claude-plugin directory**: Suggest target may not be a plugin/marketplace
- **Ambiguous structure**: List all potential targets found
- **Permission denied**: Report access issue with remediation steps

### Output Format

Return a structured detection report with:
- Target type identified
- Confidence level
- Files found
- Recommended validation command
- Next steps

**Request**: $ARGUMENTS
