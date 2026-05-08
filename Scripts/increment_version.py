#!/usr/bin/env python3
"""
Version Increment Script for WBMAnalytics

This script increments version numbers across all project files.
Usage:
    python Scripts/increment_version.py [major|minor|patch] [--dry-run]

Examples:
    python Scripts/increment_version.py patch        # 3.3.19 -> 3.3.20
    python Scripts/increment_version.py minor       # 3.3.19 -> 3.4.0
    python Scripts/increment_version.py major       # 3.3.19 -> 4.0.0
    python Scripts/increment_version.py patch --dry-run  # Show changes without applying
"""

import re
import sys
import argparse
from pathlib import Path
from typing import List, Tuple


class VersionIncrementer:
    def __init__(self, project_root: Path):
        self.project_root = project_root
        self.files_to_update = [
            "WBMAnalytics.podspec",
            "Podfile.example", 
            "README.md",
            "WBMAnalytics/WBMAnalytics/Sources/WBAnalytics/Models/Tag.swift",
            "WBMAnalytics/WBMAnalyticsTests/Batches/BatchProcessorImplTests.swift",
            "WBMAnalytics/WBMAnalyticsTests/Models/MetaTests.swift"
        ]
        
    def parse_version(self, version_str: str) -> Tuple[int, int, int]:
        """Parse version string into major, minor, patch components."""
        match = re.match(r'(\d+)\.(\d+)\.(\d+)', version_str)
        if not match:
            raise ValueError(f"Invalid version format: {version_str}")
        return int(match.group(1)), int(match.group(2)), int(match.group(3))
    
    def increment_version(self, version_str: str, increment_type: str) -> str:
        """Increment version based on type (major, minor, patch)."""
        major, minor, patch = self.parse_version(version_str)
        
        if increment_type == "major":
            major += 1
            minor = 0
            patch = 0
        elif increment_type == "minor":
            minor += 1
            patch = 0
        elif increment_type == "patch":
            patch += 1
        else:
            raise ValueError(f"Invalid increment type: {increment_type}")
            
        return f"{major}.{minor}.{patch}"
    
    def find_current_version(self) -> str:
        """Find current version from podspec file."""
        podspec_path = self.project_root / "WBMAnalytics.podspec"
        if not podspec_path.exists():
            raise FileNotFoundError(f"Podspec file not found: {podspec_path}")
            
        content = podspec_path.read_text()
        match = re.search(r'spec\.version\s*=\s*["\'](\d+\.\d+\.\d+)["\']', content)
        if not match:
            raise ValueError("Could not find version in podspec file")
            
        return match.group(1)
    
    def update_file_content(self, file_path: Path, old_version: str, new_version: str) -> Tuple[str, int]:
        """Update version in a single file and return new content and number of replacements."""
        if not file_path.exists():
            print(f"Warning: File not found: {file_path}")
            return "", 0
            
        content = file_path.read_text()
        
        # Different patterns for different file types
        patterns = [
            # Podspec version
            (r'(spec\.version\s*=\s*["\'])(\d+\.\d+\.\d+)(["\'])', r'\g<1>' + new_version + r'\g<3>'),
            # Pod dependency versions
            (r'(pod\s+["\']WBMAnalytics[^"\']*["\'],\s*["\']~>\s*)(\d+\.\d+\.\d+)(["\'])', r'\g<1>' + new_version + r'\g<3>'),
            # SPM exact version
            (r'(exact:\s*["\'])(\d+\.\d+\.\d+)(["\'])', r'\g<1>' + new_version + r'\g<3>'),
            # Swift static let version
            (r'(static let version:\s*String\s*=\s*["\'])(\d+\.\d+\.\d+)(["\'])', r'\g<1>' + new_version + r'\g<3>'),
            # Swift static let analyticsSdkVersion
            (r'(static let analyticsSdkVersion\s*=\s*["\'])(\d+\.\d+\.\d+)(["\'])', r'\g<1>' + new_version + r'\g<3>'),
            # Swift static let analyticsSDKVersion
            (r'(static let analyticsSDKVersion:\s*String\s*=\s*["\'])(\d+\.\d+\.\d+)(["\'])', r'\g<1>' + new_version + r'\g<3>'),
            # General version pattern (fallback)
            (r'\b' + re.escape(old_version) + r'\b', new_version)
        ]
        
        new_content = content
        total_replacements = 0
        
        for pattern, replacement in patterns:
            new_content, count = re.subn(pattern, replacement, new_content)
            total_replacements += count
            if count > 0:
                break  # Use first matching pattern to avoid double replacements
        
        return new_content, total_replacements
    
    def update_versions(self, increment_type: str, dry_run: bool = False) -> None:
        """Update version numbers in all relevant files."""
        try:
            current_version = self.find_current_version()
            new_version = self.increment_version(current_version, increment_type)
            
            print(f"Current version: {current_version}")
            print(f"New version: {new_version}")
            print(f"Increment type: {increment_type}")
            print()
            
            if dry_run:
                print("DRY RUN - No files will be modified")
                print()
            
            total_files_updated = 0
            total_replacements = 0
            
            for file_name in self.files_to_update:
                file_path = self.project_root / file_name
                new_content, replacements = self.update_file_content(file_path, current_version, new_version)
                
                if replacements > 0:
                    print(f"✓ {file_name}: {replacements} replacement(s)")
                    total_files_updated += 1
                    total_replacements += replacements
                    
                    if not dry_run:
                        file_path.write_text(new_content)
                else:
                    print(f"- {file_name}: No changes needed")
            
            print()
            print(f"Summary:")
            print(f"  Files updated: {total_files_updated}")
            print(f"  Total replacements: {total_replacements}")
            
            if not dry_run:
                print(f"  Version updated from {current_version} to {new_version}")
            else:
                print(f"  Would update version from {current_version} to {new_version}")
                
        except Exception as e:
            print(f"Error: {e}")
            sys.exit(1)


def main():
    parser = argparse.ArgumentParser(
        description="Increment version numbers across WBMAnalytics project files",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python Scripts/increment_version.py patch        # 3.3.19 -> 3.3.20
  python Scripts/increment_version.py minor       # 3.3.19 -> 3.4.0  
  python Scripts/increment_version.py major       # 3.3.19 -> 4.0.0
  python Scripts/increment_version.py patch --dry-run  # Preview changes
        """
    )
    
    parser.add_argument(
        "increment_type",
        choices=["major", "minor", "patch"],
        help="Type of version increment"
    )
    
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show what would be changed without making actual changes"
    )
    
    args = parser.parse_args()
    
    # Determine project root (script should be run from project root)
    project_root = Path.cwd()
    
    # Verify we're in the right directory
    if not (project_root / "WBMAnalytics.podspec").exists():
        print("Error: WBMAnalytics.podspec not found. Please run this script from the project root.")
        sys.exit(1)
    
    incrementer = VersionIncrementer(project_root)
    incrementer.update_versions(args.increment_type, args.dry_run)


if __name__ == "__main__":
    main() 