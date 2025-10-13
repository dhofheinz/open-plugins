## Operation: Validate Example Quality

Validate example code quality, detecting placeholders and ensuring examples are complete and runnable.

### Parameters from $ARGUMENTS

- **path**: Target plugin/marketplace path (required)
- **no-placeholders**: Strict placeholder enforcement (optional, default: true)
- **recursive**: Check all markdown and code files recursively (optional, default: true)
- **extensions**: File extensions to check (optional, default: "md,txt,json,sh,py,js")

### Example Quality Requirements

**Complete Examples**:
- Concrete, runnable code or commands
- Real values, not placeholder text
- Proper syntax and formatting
- Context and explanations
- Expected output or results

**No Placeholder Patterns**:
- **TODO**: `TODO`, `@TODO`, `// TODO:`
- **FIXME**: `FIXME`, `@FIXME`, `// FIXME:`
- **XXX**: `XXX`, `@XXX`, `// XXX:`
- **Placeholders**: `placeholder`, `PLACEHOLDER`, `your-value-here`, `<your-value>`, `[YOUR-VALUE]`
- **Generic**: `example`, `sample`, `test`, `dummy`, `foo`, `bar`, `baz`
- **User substitution**: `<username>`, `<your-email>`, `your-api-key`, `INSERT-HERE`

**Acceptable Patterns** (not placeholders):
- Template variables: `{{variable}}`, `${variable}`, `$VARIABLE`
- Documentation examples: `<name>`, `[optional]` in usage syntax
- Actual values: Real plugin names, real commands, concrete examples

### Workflow

1. **Identify Files to Validate**
   ```
   Scan plugin directory for documentation files:
   - README.md (primary source)
   - CONTRIBUTING.md
   - docs/**/*.md
   - examples/**/*
   - *.sh, *.py, *.js (example scripts)

   If recursive:false, only check README.md
   ```

2. **Execute Example Validator**
   ```bash
   Execute .scripts/example-validator.sh with parameters:
   - Path to plugin directory
   - No-placeholders flag
   - Recursive flag
   - File extensions to check

   Script returns:
   - files_checked: Count of files analyzed
   - placeholders_found: Array of placeholder instances
   - files_with_issues: Array of files containing placeholders
   - example_count: Number of code examples found
   - quality_score: 0-100
   ```

3. **Detect Placeholder Patterns**
   ```bash
   Search for patterns (case-insensitive):

   # TODO/FIXME/XXX markers
   grep -iE '(TODO|FIXME|XXX|HACK)[:)]' <files>

   # Placeholder text
   grep -iE '(placeholder|your-.*-here|<your-|INSERT.?HERE)' <files>

   # Generic dummy values
   grep -iE '\b(foo|bar|baz|dummy|sample|test)\b' <files>

   # User substitution patterns
   grep -iE '(<username>|<email>|<api-key>|YOUR_[A-Z_]+)' <files>

   # Exclude:
   - Comments explaining placeholders
   - Documentation of template syntax
   - Proper template variables ({{x}}, ${x})
   ```

4. **Analyze Code Blocks**
   ```
   For each code block in markdown:
   - Extract language and content
   - Check for placeholder patterns
   - Verify syntax highlighting specified
   - Ensure examples are complete

   Example extraction:
   ```bash
   /plugin install my-plugin@marketplace  ✅ Concrete
   /plugin install <plugin-name>          ⚠️ Documentation (acceptable)
   /plugin install YOUR_PLUGIN            ❌ Placeholder
   ```
   ```

5. **Count and Categorize Examples**
   ```
   Count examples by type:
   - Command examples: /plugin install ...
   - Configuration examples: JSON snippets
   - Code examples: Script samples
   - Usage examples: Real-world scenarios

   Quality criteria:
   - At least 2-3 concrete examples
   - Examples cover primary use cases
   - Examples are copy-pasteable
   ```

6. **Calculate Quality Score**
   ```
   score = 100
   score -= (placeholder_instances × 10)  # -10 per placeholder
   score -= (todo_markers × 5)            # -5 per TODO/FIXME
   score -= (example_count < 2) ? 20 : 0  # -20 if < 2 examples
   score -= (incomplete_examples × 15)    # -15 per incomplete example
   score = max(0, score)
   ```

7. **Format Output**
   ```
   Display:
   - Files checked count
   - Examples found count
   - Placeholders detected
   - Quality score
   - Specific issues with file/line references
   - Improvement recommendations
   ```

### Examples

```bash
# Validate examples with strict placeholder checking (default)
/documentation-validation examples path:.

# Check only README.md (non-recursive)
/documentation-validation examples path:. recursive:false

# Allow placeholders (lenient mode)
/documentation-validation examples path:. no-placeholders:false

# Check specific file extensions
/documentation-validation examples path:. extensions:"md,sh,py"

# Strict validation of examples directory
/documentation-validation examples path:./examples no-placeholders:true recursive:true
```

### Error Handling

**Error: Placeholders detected**
```
⚠️ WARNING: Placeholder patterns detected in examples

Placeholders found: <N> instances across <M> files

README.md:
- Line 45: /plugin install YOUR_PLUGIN_NAME
           ^ Should be concrete plugin name
- Line 67: API_KEY=your-api-key-here
           ^ Should be removed or use template syntax

examples/usage.sh:
- Line 12: # TODO: Add authentication example
           ^ Complete example or remove TODO

Remediation:
1. Replace "YOUR_PLUGIN_NAME" with actual plugin name
2. Use template syntax for user-provided values: ${API_KEY}
3. Remove TODO markers - complete examples or remove them
4. Provide concrete, copy-pasteable examples

Acceptable patterns:
- Template variables: ${VARIABLE}, {{variable}}
- Documentation syntax: <name> in usage descriptions
- Generic placeholders in template explanations
```

**Error: Too few examples**
```
⚠️ WARNING: Insufficient examples in documentation

Examples found: <N> (minimum recommended: 3)

README.md contains <N> code examples:
- Installation example ✅
- Basic usage ❌ Missing
- Advanced usage ❌ Missing

Remediation:
Add at least 2-3 concrete usage examples showing:
1. Basic usage (most common scenario)
2. Common configuration options
3. Advanced or specialized use case

Example structure:
```bash
# Basic usage
/my-plugin action param:value

# With options
/my-plugin action param:value option:true

# Advanced example
/my-plugin complex-action config:custom nested:value
```

Good examples are copy-pasteable and use real values.
```

**Error: Incomplete examples**
```
⚠️ WARNING: Incomplete or broken examples detected

Incomplete examples: <N>

README.md:
- Line 34: Code block with syntax error
- Line 56: Example missing expected output
- Line 78: Example truncated with "..."

Remediation:
1. Ensure all code examples are syntactically valid
2. Show expected output or results after examples
3. Complete truncated examples (no "..." placeholders)
4. Test examples before including in documentation

Example format:
```bash
# Command with description
/plugin install example-plugin@marketplace

# Expected output:
# ✓ Installing example-plugin@marketplace
# ✓ Plugin installed successfully
```
```

**Error: Generic dummy values**
```
⚠️ WARNING: Generic placeholder values detected

Generic values found:
- README.md:45 - "foo", "bar" used as example values
- examples/config.json:12 - "sample" as placeholder

While "foo/bar" are common in documentation, concrete examples
are more helpful for users.

Remediation:
Replace generic values with realistic examples:
- Instead of "foo", use actual plugin name
- Instead of "bar", use real parameter value
- Instead of "sample", use concrete example

Good: /my-plugin process file:README.md
Bad:  /my-plugin process file:foo.txt
```

### Output Format

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EXAMPLE QUALITY VALIDATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Files Checked: <N>
Code Examples Found: <N>

Example Count by Type:
- Command examples: <N> ✅
- Configuration examples: <N> ✅
- Usage examples: <N> ⚠️ (recommend 3+)

Placeholder Detection:
TODO/FIXME markers: <N> ❌
Placeholder patterns: <N> ❌
Generic values (foo/bar): <N> ⚠️

Quality Score: <0-100>/100

Issues by File:
README.md: <N> issues
├─ Line 45: YOUR_PLUGIN_NAME (placeholder)
├─ Line 67: TODO marker
└─ Line 89: Generic "foo" value

examples/usage.sh: <N> issues
└─ Line 12: Incomplete example

Recommendations:
1. Replace <N> placeholder patterns with concrete values [+10 pts]
2. Complete or remove <N> TODO markers [+5 pts]
3. Add <N> more usage examples [+15 pts]

Overall: <PASS|WARNINGS|FAIL>
```

### Integration

This operation is invoked by:
- `/documentation-validation examples path:.` (direct)
- `/documentation-validation full-docs path:.` (as part of complete validation)
- `/validation-orchestrator comprehensive path:.` (via orchestrator)

Results contribute to documentation quality score:
- High-quality examples (90+): +10 points
- Some issues (60-89): +5 points
- Poor quality (<60): 0 points
- Missing examples: -10 points

### Special Cases

**Template Documentation**:
If the plugin provides templates or scaffolding, some placeholders
are acceptable when properly documented as template variables.

Example:
```markdown
The generated code includes template variables:
- {{PROJECT_NAME}} - Will be replaced with actual project name
- {{AUTHOR}} - Will be replaced with author information
```

This is acceptable because the placeholders are documented as
intentional template syntax.

**Request**: $ARGUMENTS
