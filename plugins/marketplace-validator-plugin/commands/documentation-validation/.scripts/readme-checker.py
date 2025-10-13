#!/usr/bin/env python3

# ============================================================================
# README Checker
# ============================================================================
# Purpose: Validate README.md completeness and quality
# Version: 1.0.0
# Usage: ./readme-checker.py <readme-path> [options]
# Returns: 0=success, 1=error, JSON output to stdout
# ============================================================================

import sys
import os
import re
import json
import argparse
from pathlib import Path
from typing import Dict, List, Tuple

# Required sections (case-insensitive patterns)
REQUIRED_SECTIONS = {
    "overview": r"(?i)^#{1,3}\s*(overview|description|about)",
    "installation": r"(?i)^#{1,3}\s*installation",
    "usage": r"(?i)^#{1,3}\s*usage",
    "examples": r"(?i)^#{1,3}\s*(examples?|demonstrations?)",
    "license": r"(?i)^#{1,3}\s*licen[cs]e"
}

# Optional but recommended sections
RECOMMENDED_SECTIONS = {
    "configuration": r"(?i)^#{1,3}\s*(configuration|setup|config)",
    "troubleshooting": r"(?i)^#{1,3}\s*(troubleshooting|faq|common.?issues)",
    "contributing": r"(?i)^#{1,3}\s*contribut",
    "changelog": r"(?i)^#{1,3}\s*(changelog|version.?history|releases)"
}

def find_readme(path: str) -> str:
    """Find README file in path."""
    path_obj = Path(path)

    # Check if path is directly to README
    if path_obj.is_file() and path_obj.name.lower().startswith('readme'):
        return str(path_obj)

    # Search for README in directory
    if path_obj.is_dir():
        for filename in ['README.md', 'readme.md', 'README.txt', 'README']:
            readme_path = path_obj / filename
            if readme_path.exists():
                return str(readme_path)

    return None

def analyze_sections(content: str) -> Tuple[List[str], List[str]]:
    """Analyze README sections."""
    lines = content.split('\n')
    found_sections = []
    missing_sections = []

    # Check required sections
    for section_name, pattern in REQUIRED_SECTIONS.items():
        found = False
        for line in lines:
            if re.match(pattern, line.strip()):
                found = True
                found_sections.append(section_name)
                break

        if not found:
            missing_sections.append(section_name)

    return found_sections, missing_sections

def count_examples(content: str) -> int:
    """Count code examples in README."""
    # Count code blocks (```...```)
    code_blocks = re.findall(r'```[\s\S]*?```', content)
    return len(code_blocks)

def check_quality_issues(content: str) -> List[str]:
    """Check for quality issues."""
    issues = []

    # Check for excessive placeholder text
    placeholder_patterns = [
        r'TODO',
        r'FIXME',
        r'XXX',
        r'placeholder',
        r'your-.*-here',
        r'<your-'
    ]

    for pattern in placeholder_patterns:
        matches = re.findall(pattern, content, re.IGNORECASE)
        if len(matches) > 5:  # More than 5 is excessive
            issues.append(f"Excessive placeholder patterns: {len(matches)} instances of '{pattern}'")

    # Check for very short sections
    lines = content.split('\n')
    current_section = None
    section_lengths = {}

    for line in lines:
        if re.match(r'^#{1,3}\s+', line):
            current_section = line.strip()
            section_lengths[current_section] = 0
        elif current_section and line.strip():
            section_lengths[current_section] += len(line)

    for section, length in section_lengths.items():
        if length < 100 and any(keyword in section.lower() for keyword in ['installation', 'usage', 'example']):
            issues.append(f"Section '{section}' is very short ({length} chars), consider expanding")

    return issues

def calculate_score(found_sections: List[str], missing_sections: List[str],
                   length: int, example_count: int, quality_issues: List[str]) -> int:
    """Calculate README quality score (0-100)."""
    score = 100

    # Deduct for missing required sections (15 points each)
    score -= len(missing_sections) * 15

    # Deduct if too short
    if length < 200:
        score -= 30  # Critical
    elif length < 500:
        score -= 10  # Warning

    # Deduct if no examples
    if example_count == 0:
        score -= 15
    elif example_count < 2:
        score -= 5

    # Deduct for quality issues (5 points each, max 20)
    score -= min(len(quality_issues) * 5, 20)

    return max(0, score)

def generate_recommendations(found_sections: List[str], missing_sections: List[str],
                            length: int, example_count: int, quality_issues: List[str]) -> List[Dict]:
    """Generate actionable recommendations."""
    recommendations = []

    # Missing sections
    for section in missing_sections:
        impact = 15
        recommendations.append({
            "priority": "critical" if section in ["overview", "installation", "usage"] else "important",
            "action": f"Add {section.title()} section",
            "impact": impact,
            "effort": "medium" if section == "examples" else "low",
            "description": f"Include a comprehensive {section} section with clear explanations"
        })

    # Length issues
    if length < 500:
        gap = 500 - length
        recommendations.append({
            "priority": "important" if length >= 200 else "critical",
            "action": f"Expand README by {gap} characters",
            "impact": 10 if length >= 200 else 30,
            "effort": "medium",
            "description": "Add more detail to existing sections or include additional sections"
        })

    # Example issues
    if example_count < 3:
        needed = 3 - example_count
        recommendations.append({
            "priority": "important",
            "action": f"Add {needed} more code example{'s' if needed > 1 else ''}",
            "impact": 15 if example_count == 0 else 5,
            "effort": "medium",
            "description": "Include concrete, copy-pasteable usage examples"
        })

    # Quality issues
    for issue in quality_issues:
        recommendations.append({
            "priority": "recommended",
            "action": "Address quality issue",
            "impact": 5,
            "effort": "low",
            "description": issue
        })

    return sorted(recommendations, key=lambda x: (
        {"critical": 0, "important": 1, "recommended": 2}[x["priority"]],
        -x["impact"]
    ))

def main():
    parser = argparse.ArgumentParser(description='Validate README.md quality')
    parser.add_argument('path', help='Path to README.md or directory containing it')
    parser.add_argument('--sections', help='Comma-separated required sections', default=None)
    parser.add_argument('--min-length', type=int, default=500, help='Minimum character count')
    parser.add_argument('--strict', action='store_true', help='Enable strict validation')
    parser.add_argument('--json', action='store_true', help='Output JSON format')

    args = parser.parse_args()

    # Find README file
    readme_path = find_readme(args.path)

    if not readme_path:
        result = {
            "error": "README.md not found",
            "path": args.path,
            "present": False,
            "score": 0,
            "issues": ["README.md file not found in specified path"]
        }
        print(json.dumps(result, indent=2))
        return 1

    # Read README content
    try:
        with open(readme_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        result = {
            "error": f"Failed to read README: {str(e)}",
            "path": readme_path,
            "present": True,
            "score": 0
        }
        print(json.dumps(result, indent=2))
        return 1

    # Analyze README
    length = len(content)
    found_sections, missing_sections = analyze_sections(content)
    example_count = count_examples(content)
    quality_issues = check_quality_issues(content)

    # Calculate score
    score = calculate_score(found_sections, missing_sections, length, example_count, quality_issues)

    # Generate recommendations
    recommendations = generate_recommendations(found_sections, missing_sections, length, example_count, quality_issues)

    # Build result
    result = {
        "present": True,
        "path": readme_path,
        "length": length,
        "min_length": args.min_length,
        "meets_min_length": length >= args.min_length,
        "sections": {
            "found": found_sections,
            "missing": missing_sections,
            "required_count": len(REQUIRED_SECTIONS),
            "found_count": len(found_sections)
        },
        "examples": {
            "count": example_count,
            "sufficient": example_count >= 2
        },
        "quality_issues": quality_issues,
        "score": score,
        "rating": (
            "excellent" if score >= 90 else
            "good" if score >= 75 else
            "fair" if score >= 60 else
            "needs_improvement" if score >= 40 else
            "poor"
        ),
        "recommendations": recommendations[:10],  # Top 10
        "status": "pass" if score >= 60 and not missing_sections else "warning" if score >= 40 else "fail"
    }

    # Output
    if args.json:
        print(json.dumps(result, indent=2))
    else:
        # Human-readable output
        print(f"\nREADME Validation Results")
        print("=" * 50)
        print(f"File: {readme_path}")
        print(f"Length: {length} characters (min: {args.min_length})")
        print(f"Score: {score}/100 ({result['rating'].title()})")
        print(f"\nSections Found: {len(found_sections)}/{len(REQUIRED_SECTIONS)}")
        for section in found_sections:
            print(f"  ✓ {section.title()}")

        if missing_sections:
            print(f"\nMissing Sections: {len(missing_sections)}")
            for section in missing_sections:
                print(f"  ✗ {section.title()}")

        print(f"\nCode Examples: {example_count}")

        if quality_issues:
            print(f"\nQuality Issues: {len(quality_issues)}")
            for issue in quality_issues[:5]:  # Top 5
                print(f"  • {issue}")

        if recommendations:
            print(f"\nTop Recommendations:")
            for i, rec in enumerate(recommendations[:5], 1):
                print(f"  {i}. [{rec['priority'].upper()}] {rec['action']} (+{rec['impact']} pts)")

        print()

    return 0 if score >= 60 else 1

if __name__ == "__main__":
    sys.exit(main())
