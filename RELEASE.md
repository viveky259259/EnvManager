# Release Guide

EnvManager is set up for Developer ID distribution outside the Mac App Store.

## Requirements

- Apple Developer membership
- `Developer ID Application` certificate
- Xcode 15+
- Apple ID app-specific password for notarization

## Local Release

Set the notarization environment variables:

```bash
export APPLE_TEAM_ID="YOUR_TEAM_ID"
export APPLE_ID="you@example.com"
export APPLE_APP_SPECIFIC_PASSWORD="xxxx-xxxx-xxxx-xxxx"
```

Run the full release pipeline:

```bash
./scripts/release.sh --version 1.0.0
```

Artifacts are written to:

```text
dist/release/
```

The pipeline performs:

1. Xcode archive
2. Developer ID export
3. DMG packaging
4. notarization
5. stapling
6. SHA256 generation

## Local Dry Run

If you want to test the packaging flow without notarization:

```bash
./scripts/release.sh --version 1.0.0 --skip-notarize
```

## GitHub Actions Release

The repository includes a tag-driven workflow at `.github/workflows/release.yml`.

Create these repository secrets before using it:

- `APPLE_TEAM_ID`
- `APPLE_ID`
- `APPLE_APP_SPECIFIC_PASSWORD`
- `DEVELOPER_ID_APPLICATION_P12_BASE64`
- `DEVELOPER_ID_APPLICATION_P12_PASSWORD`

The workflow:

1. imports the Developer ID certificate into a temporary keychain
2. archives and exports the app
3. creates and notarizes a DMG
4. uploads the DMG and checksum to a GitHub Release

## Tagging a Release

Push a semantic version tag:

```bash
git tag v1.0.0
git push origin v1.0.0
```

That triggers the release workflow and publishes the assets.
