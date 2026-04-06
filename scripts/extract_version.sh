#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_FILE="$ROOT_DIR/EnvManager.xcodeproj/project.pbxproj"

awk '
  /MARKETING_VERSION = / {
    gsub(";", "", $3)
    print $3
    exit
  }
' "$PROJECT_FILE"
