#!/usr/bin/env python3

# ============================================================================
# Quality Report Generator
# ============================================================================
# Purpose: Generate comprehensive quality reports in multiple formats
# Version: 1.0.0
# Usage: ./report-generator.py --path <path> --format <format> [options]
# Returns: 0=success, 1=error
# Dependencies: Python 3.6+
# ============================================================================

import sys
import argparse
import json
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Any, Optional


class ReportGenerator:
    """Generate quality reports in multiple formats."""

    def __init__(self, path: str, context: Optional[Dict] = None):
        """
        Initialize report generator.

        Args:
            path: Target path being analyzed
            context: Validation context with results
        """
        self.path = path
        self.context = context or {}
        self.timestamp = datetime.now().isoformat()

    def generate(self, format_type: str = "markdown") -> str:
        """
        Generate report in specified format.

        Args:
            format_type: Report format (markdown, json, html)

        Returns:
            Formatted report string
        """
        if format_type == "json":
            return self._generate_json()
        elif format_type == "html":
            return self._generate_html()
        else:
            return self._generate_markdown()

    def _generate_markdown(self) -> str:
        """Generate markdown format report."""
        score = self.context.get("score", 0)
        rating = self.context.get("rating", "Unknown")
        stars = self.context.get("stars", "")
        readiness = self.context.get("publication_ready", "Unknown")

        p0_count = len(self.context.get("issues", {}).get("p0", []))
        p1_count = len(self.context.get("issues", {}).get("p1", []))
        p2_count = len(self.context.get("issues", {}).get("p2", []))
        total_issues = p0_count + p1_count + p2_count

        target_type = self.context.get("target_type", "plugin")

        report = f"""# Quality Assessment Report

**Generated**: {self.timestamp}
**Target**: {self.path}
**Type**: Claude Code {target_type.capitalize()}

## Executive Summary

**Quality Score**: {score}/100 {stars} ({rating})
**Publication Ready**: {readiness}
**Critical Issues**: {p0_count}
**Total Issues**: {total_issues}

"""

        if score >= 90:
            report += "🎉 Excellent! Your plugin is publication-ready.\n\n"
        elif score >= 75:
            report += "👍 Nearly ready! Address a few important issues to reach excellent status.\n\n"
        elif score >= 60:
            report += "⚠️ Needs work. Several issues should be addressed before publication.\n\n"
        else:
            report += "❌ Substantial improvements needed before this is ready for publication.\n\n"

        # Validation layers
        report += "## Validation Results\n\n"
        layers = self.context.get("validation_layers", {})

        for layer_name, layer_data in layers.items():
            status = layer_data.get("status", "unknown")
            issue_count = len(layer_data.get("issues", []))

            if status == "pass":
                status_icon = "✅ PASS"
            elif status == "warnings":
                status_icon = f"⚠️ WARNINGS ({issue_count} issues)"
            else:
                status_icon = f"❌ FAIL ({issue_count} issues)"

            report += f"### {layer_name.replace('_', ' ').title()} {status_icon}\n"

            if issue_count == 0:
                report += "- No issues found\n\n"
            else:
                for issue in layer_data.get("issues", [])[:3]:  # Show top 3
                    report += f"- {issue.get('message', 'Unknown issue')}\n"
                if issue_count > 3:
                    report += f"- ... and {issue_count - 3} more\n"
                report += "\n"

        # Issues breakdown
        report += "## Issues Breakdown\n\n"

        report += f"### Priority 0 (Critical): {p0_count} issues\n\n"
        if p0_count == 0:
            report += "None - excellent!\n\n"
        else:
            for idx, issue in enumerate(self.context.get("issues", {}).get("p0", []), 1):
                report += self._format_issue_markdown(idx, issue)

        report += f"### Priority 1 (Important): {p1_count} issues\n\n"
        if p1_count == 0:
            report += "None - great!\n\n"
        else:
            for idx, issue in enumerate(self.context.get("issues", {}).get("p1", []), 1):
                report += self._format_issue_markdown(idx, issue)

        report += f"### Priority 2 (Recommended): {p2_count} issues\n\n"
        if p2_count == 0:
            report += "No recommendations.\n\n"
        else:
            for idx, issue in enumerate(self.context.get("issues", {}).get("p2", [])[:5], 1):
                report += self._format_issue_markdown(idx, issue)
            if p2_count > 5:
                report += f"... and {p2_count - 5} more recommendations\n\n"

        # Improvement roadmap
        roadmap = self.context.get("improvement_roadmap", {})
        if roadmap:
            report += "## Improvement Roadmap\n\n"
            report += f"### Path to Excellent (90+)\n\n"
            report += f"**Current**: {roadmap.get('current_score', score)}/100\n"
            report += f"**Target**: {roadmap.get('target_score', 90)}/100\n"
            report += f"**Gap**: {roadmap.get('gap', 0)} points\n\n"

            recommendations = roadmap.get("recommendations", [])
            if recommendations:
                report += "**Top Recommendations**:\n\n"
                for idx, rec in enumerate(recommendations[:5], 1):
                    report += f"{idx}. [{rec.get('score_impact', 0):+d} pts] {rec.get('title', 'Unknown')}\n"
                    report += f"   - Priority: {rec.get('priority', 'Medium')}\n"
                    report += f"   - Effort: {rec.get('effort', 'Unknown')}\n"
                    report += f"   - Impact: {rec.get('impact', 'Unknown')}\n\n"

        # Footer
        report += "\n---\n"
        report += "Report generated by marketplace-validator-plugin v1.0.0\n"

        return report

    def _format_issue_markdown(self, idx: int, issue: Dict) -> str:
        """Format a single issue in markdown."""
        message = issue.get("message", "Unknown issue")
        impact = issue.get("impact", "Unknown impact")
        effort = issue.get("effort", "unknown")
        fix = issue.get("fix", "No fix available")
        score_impact = issue.get("score_impact", 0)

        return f"""#### {idx}. {message} [{score_impact:+d} pts]

**Impact**: {impact}
**Effort**: {effort.capitalize()}
**Fix**: {fix}

"""

    def _generate_json(self) -> str:
        """Generate JSON format report."""
        score = self.context.get("score", 0)
        rating = self.context.get("rating", "Unknown")
        stars = self.context.get("stars", "")
        readiness = self.context.get("publication_ready", "Unknown")

        p0_issues = self.context.get("issues", {}).get("p0", [])
        p1_issues = self.context.get("issues", {}).get("p1", [])
        p2_issues = self.context.get("issues", {}).get("p2", [])

        report = {
            "metadata": {
                "generated": self.timestamp,
                "target": self.path,
                "type": self.context.get("target_type", "plugin"),
                "validator_version": "1.0.0"
            },
            "executive_summary": {
                "score": score,
                "rating": rating,
                "stars": stars,
                "publication_ready": readiness,
                "critical_issues": len(p0_issues),
                "total_issues": len(p0_issues) + len(p1_issues) + len(p2_issues)
            },
            "validation_layers": self.context.get("validation_layers", {}),
            "issues": {
                "p0": p0_issues,
                "p1": p1_issues,
                "p2": p2_issues
            },
            "improvement_roadmap": self.context.get("improvement_roadmap", {})
        }

        return json.dumps(report, indent=2)

    def _generate_html(self) -> str:
        """Generate HTML format report."""
        score = self.context.get("score", 0)
        rating = self.context.get("rating", "Unknown")
        stars = self.context.get("stars", "")
        readiness = self.context.get("publication_ready", "Unknown")

        p0_count = len(self.context.get("issues", {}).get("p0", []))
        p1_count = len(self.context.get("issues", {}).get("p1", []))
        p2_count = len(self.context.get("issues", {}).get("p2", []))
        total_issues = p0_count + p1_count + p2_count

        # Determine score color
        if score >= 90:
            score_color = "#10b981"  # green
        elif score >= 75:
            score_color = "#3b82f6"  # blue
        elif score >= 60:
            score_color = "#f59e0b"  # orange
        else:
            score_color = "#ef4444"  # red

        html = f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quality Assessment Report</title>
    <style>
        * {{
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }}
        body {{
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            line-height: 1.6;
            color: #333;
            background: #f5f5f5;
            padding: 20px;
        }}
        .container {{
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            padding: 40px;
        }}
        h1 {{
            font-size: 32px;
            margin-bottom: 10px;
            color: #1f2937;
        }}
        .meta {{
            color: #6b7280;
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 2px solid #e5e7eb;
        }}
        .score-card {{
            background: linear-gradient(135deg, {score_color} 0%, {score_color}dd 100%);
            color: white;
            padding: 30px;
            border-radius: 8px;
            margin-bottom: 30px;
            text-align: center;
        }}
        .score-number {{
            font-size: 72px;
            font-weight: bold;
            line-height: 1;
        }}
        .score-label {{
            font-size: 18px;
            margin-top: 10px;
            opacity: 0.9;
        }}
        .stats {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }}
        .stat-card {{
            background: #f9fafb;
            padding: 20px;
            border-radius: 6px;
            border-left: 4px solid #3b82f6;
        }}
        .stat-label {{
            font-size: 14px;
            color: #6b7280;
            margin-bottom: 5px;
        }}
        .stat-value {{
            font-size: 24px;
            font-weight: bold;
            color: #1f2937;
        }}
        .section {{
            margin-bottom: 40px;
        }}
        h2 {{
            font-size: 24px;
            margin-bottom: 20px;
            color: #1f2937;
            border-bottom: 2px solid #e5e7eb;
            padding-bottom: 10px;
        }}
        h3 {{
            font-size: 18px;
            margin-bottom: 15px;
            color: #374151;
        }}
        .issue {{
            background: #f9fafb;
            padding: 20px;
            border-radius: 6px;
            margin-bottom: 15px;
            border-left: 4px solid #6b7280;
        }}
        .issue.p0 {{
            border-left-color: #ef4444;
            background: #fef2f2;
        }}
        .issue.p1 {{
            border-left-color: #f59e0b;
            background: #fffbeb;
        }}
        .issue.p2 {{
            border-left-color: #3b82f6;
            background: #eff6ff;
        }}
        .issue-title {{
            font-weight: bold;
            margin-bottom: 10px;
            font-size: 16px;
        }}
        .issue-detail {{
            font-size: 14px;
            color: #6b7280;
            margin: 5px 0;
        }}
        .badge {{
            display: inline-block;
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 600;
            margin-right: 8px;
        }}
        .badge.pass {{
            background: #d1fae5;
            color: #065f46;
        }}
        .badge.warning {{
            background: #fef3c7;
            color: #92400e;
        }}
        .badge.fail {{
            background: #fee2e2;
            color: #991b1b;
        }}
        .footer {{
            margin-top: 40px;
            padding-top: 20px;
            border-top: 2px solid #e5e7eb;
            color: #6b7280;
            font-size: 14px;
            text-align: center;
        }}
    </style>
</head>
<body>
    <div class="container">
        <h1>Quality Assessment Report</h1>
        <div class="meta">
            <strong>Generated:</strong> {self.timestamp}<br>
            <strong>Target:</strong> {self.path}<br>
            <strong>Type:</strong> Claude Code Plugin
        </div>

        <div class="score-card">
            <div class="score-number">{score}</div>
            <div class="score-label">{stars} {rating}</div>
            <div class="score-label">{readiness}</div>
        </div>

        <div class="stats">
            <div class="stat-card">
                <div class="stat-label">Critical Issues</div>
                <div class="stat-value">{p0_count}</div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Important Issues</div>
                <div class="stat-value">{p1_count}</div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Recommendations</div>
                <div class="stat-value">{p2_count}</div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Total Issues</div>
                <div class="stat-value">{total_issues}</div>
            </div>
        </div>

        <div class="section">
            <h2>Validation Layers</h2>
"""

        # Validation layers
        layers = self.context.get("validation_layers", {})
        for layer_name, layer_data in layers.items():
            status = layer_data.get("status", "unknown")
            badge_class = "pass" if status == "pass" else ("warning" if status == "warnings" else "fail")
            html += f'            <span class="badge {badge_class}">{layer_name.replace("_", " ").title()}: {status.upper()}</span>\n'

        html += """        </div>

        <div class="section">
            <h2>Issues Breakdown</h2>
"""

        # Issues
        for priority, priority_name in [("p0", "Critical"), ("p1", "Important"), ("p2", "Recommended")]:
            issues = self.context.get("issues", {}).get(priority, [])
            html += f'            <h3>Priority {priority[1]}: {priority_name} ({len(issues)} issues)</h3>\n'

            for issue in issues[:5]:  # Show top 5 per priority
                message = issue.get("message", "Unknown issue")
                impact = issue.get("impact", "Unknown")
                effort = issue.get("effort", "unknown")
                fix = issue.get("fix", "No fix available")

                html += f"""            <div class="issue {priority}">
                <div class="issue-title">{message}</div>
                <div class="issue-detail"><strong>Impact:</strong> {impact}</div>
                <div class="issue-detail"><strong>Effort:</strong> {effort.capitalize()}</div>
                <div class="issue-detail"><strong>Fix:</strong> {fix}</div>
            </div>
"""

        html += """        </div>

        <div class="footer">
            Report generated by marketplace-validator-plugin v1.0.0
        </div>
    </div>
</body>
</html>
"""

        return html


def main():
    """Main CLI interface."""
    parser = argparse.ArgumentParser(
        description="Generate comprehensive quality reports",
        formatter_class=argparse.RawDescriptionHelpFormatter
    )

    parser.add_argument(
        "--path",
        required=True,
        help="Target path being analyzed"
    )

    parser.add_argument(
        "--format",
        choices=["markdown", "json", "html"],
        default="markdown",
        help="Output format (default: markdown)"
    )

    parser.add_argument(
        "--output",
        help="Output file path (optional, defaults to stdout)"
    )

    parser.add_argument(
        "--context",
        help="Path to JSON file with validation context"
    )

    args = parser.parse_args()

    # Load context if provided
    context = {}
    if args.context:
        try:
            with open(args.context, 'r') as f:
                context = json.load(f)
        except FileNotFoundError:
            print(f"Warning: Context file not found: {args.context}", file=sys.stderr)
        except json.JSONDecodeError as e:
            print(f"Error: Invalid JSON in context file: {e}", file=sys.stderr)
            return 1

    # Generate report
    generator = ReportGenerator(args.path, context)
    report = generator.generate(args.format)

    # Output report
    if args.output:
        try:
            with open(args.output, 'w') as f:
                f.write(report)
            print(f"Report generated: {args.output}")
        except IOError as e:
            print(f"Error writing to file: {e}", file=sys.stderr)
            return 1
    else:
        print(report)

    return 0


if __name__ == "__main__":
    sys.exit(main())
