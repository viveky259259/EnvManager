#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

ARCHIVE_PATH="${ARCHIVE_PATH:-$ROOT_DIR/dist/EnvManager.xcarchive}"
EXPORT_DIR="${EXPORT_DIR:-$ROOT_DIR/dist/export}"
APPLE_TEAM_ID="${APPLE_TEAM_ID:?APPLE_TEAM_ID is required for Developer ID export}"
SCHEME="${SCHEME:-EnvManager}"

mkdir -p "$EXPORT_DIR"

EXPORT_OPTIONS_PLIST="$(mktemp)"
cleanup() {
  rm -f "$EXPORT_OPTIONS_PLIST"
}
trap cleanup EXIT

cat > "$EXPORT_OPTIONS_PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>method</key>
  <string>developer-id</string>
  <key>signingStyle</key>
  <string>automatic</string>
  <key>teamID</key>
  <string>${APPLE_TEAM_ID}</string>
</dict>
</plist>
EOF

xcodebuild \
  -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportPath "$EXPORT_DIR" \
  -exportOptionsPlist "$EXPORT_OPTIONS_PLIST"

if [[ ! -d "$EXPORT_DIR/$SCHEME.app" ]]; then
  echo "Expected exported app at $EXPORT_DIR/$SCHEME.app" >&2
  exit 1
fi
