#!/usr/bin/env python3
"""
Simple Module Version Manager

Updates version and date in the simplified artifact.json file.

Usage:
    python version_manager.py --version 0.0.2
    python version_manager.py --bump patch
    python version_manager.py --bump minor  
    python version_manager.py --bump major
"""

import json
import argparse
import sys
from datetime import datetime
from pathlib import Path

def load_artifact():
    """Load the artifact.json file."""
    artifact_path = Path(__file__).parent / "artifact.json"
    if not artifact_path.exists():
        print(f"Error: artifact.json not found at {artifact_path}")
        sys.exit(1)
    
    with open(artifact_path, 'r') as f:
        return json.load(f)

def save_artifact(data):
    """Save the artifact.json file."""
    artifact_path = Path(__file__).parent / "artifact.json"
    with open(artifact_path, 'w') as f:
        json.dump(data, f, indent=4)
    print(f"Updated {artifact_path}")

def parse_version(version_str):
    """Parse version string into major, minor, patch."""
    try:
        parts = version_str.split('.')
        if len(parts) != 3:
            raise ValueError("Version must be in format MAJOR.MINOR.PATCH")
        return tuple(int(part) for part in parts)
    except ValueError as e:
        print(f"Error parsing version '{version_str}': {e}")
        sys.exit(1)

def bump_version(current_version, bump_type):
    """Bump version based on type (major, minor, patch)."""
    major, minor, patch = parse_version(current_version)
    
    if bump_type == "major":
        return f"{major + 1}.0.0"
    elif bump_type == "minor":
        return f"{major}.{minor + 1}.0"
    elif bump_type == "patch":
        return f"{major}.{minor}.{patch + 1}"
    else:
        print(f"Error: Invalid bump type '{bump_type}'. Use major, minor, or patch.")
        sys.exit(1)

def main():
    parser = argparse.ArgumentParser(description="Simple module version manager for artifact.json")
    parser.add_argument("--version", help="Set specific version (e.g., 0.1.0)")
    parser.add_argument("--bump", choices=["major", "minor", "patch"], help="Bump version type")
    
    args = parser.parse_args()
    
    if not any([args.version, args.bump]):
        parser.print_help()
        sys.exit(1)
    
    # Load current artifact
    data = load_artifact()
    
    # Determine new version
    current_version = data["version"]
    new_version = None
    
    if args.version:
        new_version = args.version
        # Validate the provided version
        parse_version(new_version)
    elif args.bump:
        new_version = bump_version(current_version, args.bump)
    
    if new_version:
        print(f"Updating version from {current_version} to {new_version}")
        
        # Update version and date
        data["version"] = new_version
        data["updated"] = datetime.now().strftime("%Y-%m-%d")
        
        # Save updated artifact
        save_artifact(data)
        print(f"Successfully updated to version {new_version}")

if __name__ == "__main__":
    main()