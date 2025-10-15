#!/usr/bin/env python3
"""
Purpose: Calculate code complexity metrics for architecture assessment
Version: 1.0.0
Usage: python3 complexity-metrics.py [path] [--format json|text]
Returns: Complexity metrics including cyclomatic complexity, maintainability index
Exit codes: 0=success, 1=error, 2=invalid input

Dependencies: radon (install with: pip install radon)
If radon is not available, provides simplified metrics
"""

import os
import sys
import json
import argparse
from pathlib import Path
from typing import Dict, List, Tuple, Any
from datetime import datetime


class ComplexityAnalyzer:
    """Analyzes code complexity across a codebase."""

    def __init__(self, root_path: str):
        self.root_path = Path(root_path)
        self.results = {
            "analysis_date": datetime.utcnow().isoformat() + "Z",
            "root_path": str(self.root_path),
            "files_analyzed": 0,
            "total_lines": 0,
            "total_functions": 0,
            "complexity": {
                "average": 0.0,
                "max": 0,
                "distribution": {"simple": 0, "moderate": 0, "complex": 0, "very_complex": 0}
            },
            "maintainability": {
                "average": 0.0,
                "distribution": {"high": 0, "medium": 0, "low": 0}
            },
            "files": []
        }
        self.has_radon = self._check_radon()

    def _check_radon(self) -> bool:
        """Check if radon is available."""
        try:
            import radon
            return True
        except ImportError:
            print("Warning: radon not installed. Using simplified metrics.", file=sys.stderr)
            print("Install with: pip install radon", file=sys.stderr)
            return False

    def analyze(self) -> Dict[str, Any]:
        """Perform complexity analysis on the codebase."""
        if not self.root_path.exists():
            raise FileNotFoundError(f"Path not found: {self.root_path}")

        # Find all source files
        source_files = self._find_source_files()

        for file_path in source_files:
            self._analyze_file(file_path)

        # Calculate summary statistics
        self._calculate_summary()

        return self.results

    def _find_source_files(self) -> List[Path]:
        """Find all source code files in the directory."""
        extensions = {'.py', '.js', '.ts', '.jsx', '.tsx', '.java', '.go', '.rb', '.php', '.c', '.cpp', '.cs'}
        source_files = []

        for ext in extensions:
            source_files.extend(self.root_path.rglob(f"*{ext}"))

        # Exclude common non-source directories
        excluded_dirs = {'node_modules', 'venv', 'env', '.venv', 'dist', 'build', '.git', 'vendor', '__pycache__'}
        source_files = [f for f in source_files if not any(excluded in f.parts for excluded in excluded_dirs)]

        return source_files

    def _analyze_file(self, file_path: Path):
        """Analyze a single file."""
        try:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
                lines = content.split('\n')
                self.results["total_lines"] += len(lines)
                self.results["files_analyzed"] += 1

                if self.has_radon:
                    self._analyze_with_radon(file_path, content)
                else:
                    self._analyze_simplified(file_path, content, lines)

        except Exception as e:
            print(f"Warning: Could not analyze {file_path}: {e}", file=sys.stderr)

    def _analyze_with_radon(self, file_path: Path, content: str):
        """Analyze file using radon library."""
        from radon.complexity import cc_visit
        from radon.metrics import mi_visit

        try:
            # Cyclomatic complexity
            complexity_results = cc_visit(content, no_assert=True)

            for result in complexity_results:
                self.results["total_functions"] += 1
                complexity = result.complexity

                # Classify complexity
                if complexity <= 5:
                    self.results["complexity"]["distribution"]["simple"] += 1
                elif complexity <= 10:
                    self.results["complexity"]["distribution"]["moderate"] += 1
                elif complexity <= 20:
                    self.results["complexity"]["distribution"]["complex"] += 1
                else:
                    self.results["complexity"]["distribution"]["very_complex"] += 1

                # Track maximum complexity
                if complexity > self.results["complexity"]["max"]:
                    self.results["complexity"]["max"] = complexity

            # Maintainability index
            mi_score = mi_visit(content, multi=True)
            if mi_score:
                avg_mi = sum(mi_score) / len(mi_score)
                if avg_mi >= 70:
                    self.results["maintainability"]["distribution"]["high"] += 1
                elif avg_mi >= 50:
                    self.results["maintainability"]["distribution"]["medium"] += 1
                else:
                    self.results["maintainability"]["distribution"]["low"] += 1

        except Exception as e:
            print(f"Warning: Radon analysis failed for {file_path}: {e}", file=sys.stderr)

    def _analyze_simplified(self, file_path: Path, content: str, lines: List[str]):
        """Simplified analysis without radon."""
        # Count functions (simplified heuristic)
        function_keywords = ['def ', 'function ', 'func ', 'fn ', 'sub ', 'public ', 'private ', 'protected ']
        function_count = sum(1 for line in lines if any(keyword in line.lower() for keyword in function_keywords))

        self.results["total_functions"] += function_count

        # Estimate complexity based on control flow keywords
        complexity_keywords = ['if ', 'else', 'elif', 'for ', 'while ', 'switch', 'case ', 'catch', '?', '&&', '||']
        total_complexity = sum(1 for line in lines if any(keyword in line for keyword in complexity_keywords))

        if function_count > 0:
            avg_complexity = total_complexity / function_count

            # Classify based on average
            if avg_complexity <= 5:
                self.results["complexity"]["distribution"]["simple"] += function_count
            elif avg_complexity <= 10:
                self.results["complexity"]["distribution"]["moderate"] += function_count
            elif avg_complexity <= 20:
                self.results["complexity"]["distribution"]["complex"] += function_count
            else:
                self.results["complexity"]["distribution"]["very_complex"] += function_count

        # Estimate maintainability based on line count and function size
        avg_lines_per_func = len(lines) / max(function_count, 1)
        if avg_lines_per_func <= 20:
            self.results["maintainability"]["distribution"]["high"] += 1
        elif avg_lines_per_func <= 50:
            self.results["maintainability"]["distribution"]["medium"] += 1
        else:
            self.results["maintainability"]["distribution"]["low"] += 1

    def _calculate_summary(self):
        """Calculate summary statistics."""
        total_funcs = self.results["total_functions"]

        if total_funcs > 0:
            # Average complexity
            dist = self.results["complexity"]["distribution"]
            weighted_sum = (dist["simple"] * 3 + dist["moderate"] * 7.5 +
                          dist["complex"] * 15 + dist["very_complex"] * 25)
            self.results["complexity"]["average"] = round(weighted_sum / total_funcs, 2)

            # Average maintainability
            mi_dist = self.results["maintainability"]["distribution"]
            total_mi = sum(mi_dist.values())
            if total_mi > 0:
                weighted_mi = (mi_dist["high"] * 85 + mi_dist["medium"] * 60 + mi_dist["low"] * 30)
                self.results["maintainability"]["average"] = round(weighted_mi / total_mi, 2)

        # Add health score (0-10 scale)
        self.results["health_score"] = self._calculate_health_score()

        # Add recommendations
        self.results["recommendations"] = self._generate_recommendations()

    def _calculate_health_score(self) -> float:
        """Calculate overall code health score (0-10)."""
        score = 10.0

        # Deduct for high average complexity
        avg_complexity = self.results["complexity"]["average"]
        if avg_complexity > 20:
            score -= 4
        elif avg_complexity > 10:
            score -= 2
        elif avg_complexity > 5:
            score -= 1

        # Deduct for very complex functions
        very_complex = self.results["complexity"]["distribution"]["very_complex"]
        total_funcs = self.results["total_functions"]
        if total_funcs > 0:
            very_complex_ratio = very_complex / total_funcs
            if very_complex_ratio > 0.2:
                score -= 3
            elif very_complex_ratio > 0.1:
                score -= 2
            elif very_complex_ratio > 0.05:
                score -= 1

        # Deduct for low maintainability
        low_mi = self.results["maintainability"]["distribution"]["low"]
        total_files = self.results["files_analyzed"]
        if total_files > 0:
            low_mi_ratio = low_mi / total_files
            if low_mi_ratio > 0.3:
                score -= 2
            elif low_mi_ratio > 0.2:
                score -= 1

        return max(0.0, min(10.0, round(score, 1)))

    def _generate_recommendations(self) -> List[Dict[str, str]]:
        """Generate recommendations based on analysis."""
        recommendations = []

        avg_complexity = self.results["complexity"]["average"]
        if avg_complexity > 10:
            recommendations.append({
                "priority": "high",
                "action": f"Reduce average cyclomatic complexity from {avg_complexity} to below 10",
                "impact": "Improves code readability and testability"
            })

        very_complex = self.results["complexity"]["distribution"]["very_complex"]
        if very_complex > 0:
            recommendations.append({
                "priority": "high",
                "action": f"Refactor {very_complex} very complex functions (complexity > 20)",
                "impact": "Reduces bug risk and maintenance burden"
            })

        low_mi = self.results["maintainability"]["distribution"]["low"]
        if low_mi > 0:
            recommendations.append({
                "priority": "medium",
                "action": f"Improve maintainability of {low_mi} low-scored files",
                "impact": "Easier code changes and onboarding"
            })

        total_funcs = self.results["total_functions"]
        total_lines = self.results["total_lines"]
        if total_funcs > 0:
            avg_lines_per_func = total_lines / total_funcs
            if avg_lines_per_func > 50:
                recommendations.append({
                    "priority": "medium",
                    "action": f"Break down large functions (avg {avg_lines_per_func:.0f} lines/function)",
                    "impact": "Improves code organization and reusability"
                })

        return recommendations


def format_output(results: Dict[str, Any], output_format: str) -> str:
    """Format analysis results."""
    if output_format == "json":
        return json.dumps(results, indent=2)

    # Text format
    output = []
    output.append("\n" + "=" * 60)
    output.append("Code Complexity Metrics Report")
    output.append("=" * 60)
    output.append(f"\nAnalysis Date: {results['analysis_date']}")
    output.append(f"Root Path: {results['root_path']}")
    output.append(f"Files Analyzed: {results['files_analyzed']}")
    output.append(f"Total Lines: {results['total_lines']:,}")
    output.append(f"Total Functions: {results['total_functions']:,}")

    output.append("\n--- Cyclomatic Complexity ---")
    output.append(f"Average Complexity: {results['complexity']['average']}")
    output.append(f"Maximum Complexity: {results['complexity']['max']}")
    output.append("\nDistribution:")
    dist = results['complexity']['distribution']
    total = sum(dist.values())
    if total > 0:
        output.append(f"  Simple (1-5):        {dist['simple']:4d} ({dist['simple']/total*100:5.1f}%)")
        output.append(f"  Moderate (6-10):     {dist['moderate']:4d} ({dist['moderate']/total*100:5.1f}%)")
        output.append(f"  Complex (11-20):     {dist['complex']:4d} ({dist['complex']/total*100:5.1f}%)")
        output.append(f"  Very Complex (>20):  {dist['very_complex']:4d} ({dist['very_complex']/total*100:5.1f}%)")

    output.append("\n--- Maintainability Index ---")
    output.append(f"Average Score: {results['maintainability']['average']}")
    output.append("\nDistribution:")
    mi_dist = results['maintainability']['distribution']
    total_mi = sum(mi_dist.values())
    if total_mi > 0:
        output.append(f"  High (70-100):    {mi_dist['high']:4d} ({mi_dist['high']/total_mi*100:5.1f}%)")
        output.append(f"  Medium (50-69):   {mi_dist['medium']:4d} ({mi_dist['medium']/total_mi*100:5.1f}%)")
        output.append(f"  Low (0-49):       {mi_dist['low']:4d} ({mi_dist['low']/total_mi*100:5.1f}%)")

    output.append(f"\n--- Health Score: {results['health_score']}/10 ---")

    if results['recommendations']:
        output.append("\n--- Recommendations ---")
        for i, rec in enumerate(results['recommendations'], 1):
            output.append(f"\n{i}. [{rec['priority'].upper()}] {rec['action']}")
            output.append(f"   Impact: {rec['impact']}")

    output.append("\n" + "=" * 60 + "\n")

    return "\n".join(output)


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description="Analyze code complexity metrics for architecture assessment"
    )
    parser.add_argument(
        "path",
        nargs="?",
        default=".",
        help="Path to analyze (default: current directory)"
    )
    parser.add_argument(
        "--format",
        choices=["json", "text"],
        default="json",
        help="Output format (default: json)"
    )

    args = parser.parse_args()

    try:
        analyzer = ComplexityAnalyzer(args.path)
        results = analyzer.analyze()
        output = format_output(results, args.format)
        print(output)
        sys.exit(0)
    except FileNotFoundError as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(2)
    except Exception as e:
        print(f"Error during analysis: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
