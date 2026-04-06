#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

PROJECT_PATH="${PROJECT_PATH:-$ROOT_DIR/EnvManager.xcodeproj}"
SCHEME="${SCHEME:-EnvManager}"
CONFIGURATION="${CONFIGURATION:-Release}"
ARCHIVE_PATH="${ARCHIVE_PATH:-$ROOT_DIR/dist/$SCHEME.xcarchive}"
APPLE_TEAM_ID="${APPLE_TEAM_ID:-}"

mkdir -p "$(dirname "$ARCHIVE_PATH")"

CMD=(
  xcodebuild
  -project "$PROJECT_PATH"
  -scheme "$SCHEME"
  -configuration "$CONFIGURATION"
  -destination "generic/platform=macOS"
  -archivePath "$ARCHIVE_PATH"
  archive
)

if [[ -n "$APPLE_TEAM_ID" ]]; then
  CMD+=(DEVELOPMENT_TEAM="$APPLE_TEAM_ID")
fi

"${CMD[@]}"
