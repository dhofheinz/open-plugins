## Operation: Check LICENSE File

Validate LICENSE file presence, format, and consistency with plugin metadata.

### Parameters from $ARGUMENTS

- **path**: Target plugin/marketplace path (required)
- **expected**: Expected license type (optional, reads from plugin.json if not provided)
- **strict**: Enable strict validation mode (optional, default: false)
- **check-consistency**: Verify consistency with plugin.json (optional, default: true)

### LICENSE Requirements

**File Presence**:
- LICENSE or LICENSE.txt in plugin root
- Also accept: LICENSE.md, COPYING, COPYING.txt

**OSI-Approved Licenses** (recommended):
- MIT License
- Apache License 2.0
- GNU General Public License (GPL) v2/v3
- BSD 2-Clause or 3-Clause License
- Mozilla Public License 2.0
- ISC License
- Creative Commons (for documentation)

**Validation Checks**:
1. **File exists**: LICENSE file present in root
2. **Valid content**: Contains recognized license text
3. **Complete**: Full license text, not just license name
4. **Consistency**: Matches license field in plugin.json
5. **OSI-approved**: Recognized open-source license

### Workflow

1. **Locate LICENSE File**
   ```
   Check for files in plugin root (case-insensitive):
   - LICENSE
   - LICENSE.txt
   - LICENSE.md
   - COPYING
   - COPYING.txt
   - LICENCE (UK spelling)

   If multiple found, prefer LICENSE over others
   ```

2. **Read Plugin Metadata**
   ```
   Read plugin.json
   Extract license field value
   Store expected license type for comparison
   ```

3. **Execute License Detector**
   ```bash
   Execute .scripts/license-detector.py with parameters:
   - License file path
   - Expected license type (from plugin.json)
   - Strict mode flag

   Script returns:
   - detected_license: Identified license type
   - confidence: 0-100 (match confidence)
   - is_osi_approved: Boolean
   - is_complete: Boolean (full text vs just name)
   - matches_manifest: Boolean
   - issues: Array of problems
   ```

4. **Validate License Content**
   ```
   Check for license text patterns:
   - MIT: "Permission is hereby granted, free of charge..."
   - Apache 2.0: "Licensed under the Apache License, Version 2.0"
   - GPL-3.0: "GNU GENERAL PUBLIC LICENSE Version 3"
   - BSD-2-Clause: "Redistribution and use in source and binary forms"

   Detect incomplete licenses:
   - Just "MIT" or "MIT License" (missing full text)
   - Just "Apache 2.0" (missing full text)
   - Links to license without including text
   ```

5. **Check Consistency**
   ```
   Compare detected license with plugin.json:
   - Exact match: ✅ PASS
   - Close match (e.g., "MIT" vs "MIT License"): ⚠️ WARNING
   - Mismatch: ❌ ERROR
   - Not specified in plugin.json: ⚠️ WARNING

   Normalize license names for comparison:
   - "MIT License" == "MIT"
   - "Apache-2.0" == "Apache License 2.0"
   - "GPL-3.0" == "GNU GPL v3"
   ```

6. **Verify OSI Approval**
   ```
   Check against OSI-approved license list:
   - MIT: ✅ Approved
   - Apache-2.0: ✅ Approved
   - GPL-2.0, GPL-3.0: ✅ Approved
   - BSD-2-Clause, BSD-3-Clause: ✅ Approved
   - Proprietary: ❌ Not approved
   - Custom/Unknown: ⚠️ Review required
   ```

7. **Format Output**
   ```
   Display:
   - ✅/❌ File presence
   - Detected license type
   - OSI approval status
   - Consistency with plugin.json
   - Completeness (full text vs name only)
   - Issues and recommendations
   ```

### Examples

```bash
# Check LICENSE with defaults (reads expected from plugin.json)
/documentation-validation license path:.

# Check with explicit expected license
/documentation-validation license path:. expected:MIT

# Strict validation (requires full license text)
/documentation-validation license path:. strict:true

# Skip consistency check (only validate file)
/documentation-validation license path:. check-consistency:false

# Check specific plugin
/documentation-validation license path:/path/to/plugin expected:Apache-2.0
```

### Error Handling

**Error: LICENSE file not found**
```
❌ CRITICAL: LICENSE file not found in <path>

Remediation:
1. Create LICENSE file in plugin root directory
2. Include full license text (not just the name)
3. Use an OSI-approved open-source license (MIT recommended)
4. Ensure license field in plugin.json matches LICENSE file

Recommended licenses for plugins:
- MIT: Simple, permissive (most common)
- Apache 2.0: Permissive with patent grant
- GPL-3.0: Copyleft (requires derivatives to use same license)
- BSD-3-Clause: Permissive, similar to MIT

Full license texts available at: https://choosealicense.com/

This is a BLOCKING issue - plugin cannot be submitted without a LICENSE.
```

**Error: Incomplete license text**
```
⚠️ WARNING: LICENSE file contains only license name, not full text

Current content: "MIT License"
Required: Full MIT License text

The LICENSE file should contain the complete license text, not just the name.

For MIT License, include:
MIT License

Copyright (c) [year] [fullname]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction...
[full license text]

Get full text: https://opensource.org/licenses/MIT
```

**Error: License mismatch with plugin.json**
```
❌ ERROR: LICENSE file does not match plugin.json declaration

plugin.json declares: "Apache-2.0"
LICENSE file contains: "MIT License"

Remediation:
1. Update plugin.json to declare "MIT" license, OR
2. Replace LICENSE file with Apache 2.0 license text

Consistency is required - both files must specify the same license.
```

**Error: Non-OSI-approved license**
```
❌ ERROR: License is not OSI-approved

Detected license: "Proprietary" or "Custom License"

OpenPlugins marketplace requires OSI-approved open-source licenses.

Recommended licenses:
- MIT License (most permissive)
- Apache License 2.0
- GNU GPL v3
- BSD 3-Clause

Choose a license: https://choosealicense.com/
OSI-approved list: https://opensource.org/licenses

This is a BLOCKING issue - plugin cannot be submitted with proprietary license.
```

**Error: Unrecognized license**
```
⚠️ WARNING: Unable to identify license type

The LICENSE file content does not match known license patterns.

Possible issues:
- Custom or modified license (not allowed)
- Corrupted or incomplete license text
- Non-standard format

Remediation:
1. Use standard, unmodified license text from official source
2. Choose from OSI-approved licenses
3. Do not modify standard license text (except copyright holder)
4. Get standard text from https://choosealicense.com/

If using a valid OSI license, ensure text matches standard format exactly.
```

### Output Format

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
LICENSE VALIDATION RESULTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

File: ✅ LICENSE found

License Type: <detected-license>
Confidence: <0-100>% ✅

OSI Approved: ✅ Yes
Complete Text: ✅ Yes (full license included)

Consistency Check:
plugin.json declares: "<license>"
LICENSE file contains: "<detected-license>"
Match: ✅ Consistent

Validation: ✅ PASS

Recommendations:
- License is valid and properly formatted
- Meets OpenPlugins requirements
- Ready for submission

Overall: <PASS|WARNINGS|FAIL>
```

### Integration

This operation is invoked by:
- `/documentation-validation license path:.` (direct)
- `/documentation-validation full-docs path:.` (as part of complete validation)
- `/validation-orchestrator comprehensive path:.` (via orchestrator)

Results contribute to documentation quality score:
- Present, valid, consistent: +5 points
- Present but issues: 0 points (with warnings)
- Missing: BLOCKING issue (-20 points)

### Common License Patterns

**MIT License Detection**:
```
Pattern: "Permission is hereby granted, free of charge"
Confidence: 95%+
```

**Apache 2.0 Detection**:
```
Pattern: "Licensed under the Apache License, Version 2.0"
Confidence: 95%+
```

**GPL-3.0 Detection**:
```
Pattern: "GNU GENERAL PUBLIC LICENSE" + "Version 3"
Confidence: 95%+
```

**BSD Detection**:
```
Pattern: "Redistribution and use in source and binary forms"
Confidence: 90%+
```

**Request**: $ARGUMENTS
