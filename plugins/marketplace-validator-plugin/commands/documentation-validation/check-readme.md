## Operation: Check README Completeness

Validate README.md completeness, structure, and quality against OpenPlugins standards.

### Parameters from $ARGUMENTS

- **path**: Target plugin/marketplace path (required)
- **sections**: Comma-separated required sections (optional, defaults to standard set)
- **min-length**: Minimum character count (optional, default: 500)
- **strict**: Enable strict validation mode (optional, default: false)

### README Requirements

**Required Sections** (case-insensitive matching):
1. **Overview/Description**: Plugin purpose and functionality
2. **Installation**: How to install and configure
3. **Usage**: How to use the plugin with examples
4. **Examples**: At least 2-3 concrete usage examples
5. **License**: License information or reference

**Quality Criteria**:
- Minimum 500 characters (configurable)
- No excessive placeholder text
- Proper markdown formatting
- Working links (if present)
- Code blocks properly formatted

### Workflow

1. **Locate README File**
   ```
   Check for README.md in plugin root
   If not found, check for README.txt or readme.md
   If still not found, report critical error
   ```

2. **Execute README Checker Script**
   ```bash
   Execute .scripts/readme-checker.py with parameters:
   - File path to README.md
   - Required sections list
   - Minimum length threshold
   - Strict mode flag

   Script returns JSON with:
   - sections_found: Array of detected sections
   - sections_missing: Array of missing sections
   - length: Character count
   - quality_score: 0-100
   - issues: Array of specific problems
   ```

3. **Analyze Results**
   ```
   CRITICAL (blocking):
   - README.md file missing
   - Length < 200 characters
   - Missing 3+ required sections

   WARNING (should fix):
   - Length < 500 characters
   - Missing 1-2 required sections
   - Missing examples section

   RECOMMENDATION (nice to have):
   - Add troubleshooting section
   - Expand examples
   - Add badges or visual elements
   ```

4. **Calculate Section Score**
   ```
   score = 100
   score -= (missing_required_sections × 15)
   score -= (length < 500) ? 10 : 0
   score -= (no_examples) ? 15 : 0
   score = max(0, score)
   ```

5. **Format Output**
   ```
   Display:
   - ✅/❌ File presence
   - ✅/⚠️/❌ Each required section
   - Length statistics
   - Quality score
   - Specific improvement recommendations
   ```

### Examples

```bash
# Check README with defaults
/documentation-validation readme path:.

# Check with custom sections
/documentation-validation readme path:./my-plugin sections:"overview,installation,usage,examples,contributing,license"

# Strict validation with higher standards
/documentation-validation readme path:. min-length:1000 strict:true

# Check specific plugin
/documentation-validation readme path:/path/to/plugin sections:"overview,usage,license"
```

### Error Handling

**Error: README.md not found**
```
❌ CRITICAL: README.md file not found in <path>

Remediation:
1. Create README.md in plugin root directory
2. Include required sections: Overview, Installation, Usage, Examples, License
3. Ensure minimum 500 characters of meaningful content
4. See https://github.com/dhofheinz/open-plugins/blob/main/README.md for example

This is a BLOCKING issue - plugin cannot be submitted without README.
```

**Error: README too short**
```
⚠️ WARNING: README.md is only <X> characters (minimum: 500)

Current length: <X> characters
Required: 500 characters minimum
Gap: <500-X> characters

Remediation:
- Expand installation instructions with examples
- Add 2-3 usage examples with code blocks
- Include configuration options
- Add troubleshooting section
```

**Error: Missing required sections**
```
❌ ERROR: Missing <N> required sections

Missing sections:
- Installation: How to install the plugin
- Examples: At least 2 concrete usage examples
- License: License information or reference to LICENSE file

Remediation:
Add each missing section with meaningful content.
See CONTRIBUTING.md for section requirements.
```

### Output Format

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
README VALIDATION RESULTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

File: ✅ README.md found

Required Sections:
✅ Overview/Description
✅ Installation
✅ Usage
⚠️  Examples (found 1, recommended: 3+)
✅ License

Length: <X> characters (minimum: 500) ✅

Quality Score: <0-100>/100

Issues Found: <N>

Critical (blocking): <count>
Warnings (should fix): <count>
Recommendations: <count>

Top Recommendations:
1. Add 2 more usage examples with code blocks [+15 pts]
2. Expand installation section with configuration options [+5 pts]
3. Include troubleshooting section [+5 pts]

Overall: <PASS|WARNINGS|FAIL>
```

### Integration

This operation is invoked by:
- `/documentation-validation readme path:.` (direct)
- `/documentation-validation full-docs path:.` (as part of complete validation)
- `/validation-orchestrator comprehensive path:.` (via orchestrator)

Results feed into quality-analysis scoring system.

**Request**: $ARGUMENTS
