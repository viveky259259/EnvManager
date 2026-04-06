# Contributing

## Setup

1. Clone the repository.
2. Open `EnvManager.xcodeproj` in Xcode.
3. Build the `EnvManager` scheme on macOS.

You can also verify the project from the command line:

```bash
xcodebuild -project EnvManager.xcodeproj -scheme EnvManager -destination 'platform=macOS' build
```

## Guidelines

- Keep changes focused and easy to review.
- Prefer native SwiftUI and Foundation APIs unless a dependency is clearly justified.
- Preserve the existing behavior around shell-config backups and preview-before-save.
- Do not commit local tooling files or generated release artifacts.

## Pull Requests

- Describe the user-facing change and any behavior tradeoffs.
- Include manual verification steps.
- Make sure the project builds cleanly before opening the PR.
