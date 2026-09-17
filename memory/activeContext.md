# Active Context

_Last updated: 2026-09-17_

## Branch

- `cursor/stub-games-repository-uitest-4f36`

## Current focus

Compilation fix for MainActor isolation under `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`.

## Just changed

- `UITestSupport.shouldForceEmptyResults` — removed incorrect `nonisolated` (key + accessor stay MainActor)
- `StubGamesRepository.forUITests()` — marked `@MainActor` so it can read `UITestSupport`
- Reverted accidental `project.pbxproj` SDKROOT move (project-level `SDKROOT = iphoneos` restored)
- Xcode build-for-testing succeeds

## Next steps

1. Commit compilation fix (and prior stub work if not already) / push / open PR to `develop`
2. Run unit + UI tests on simulator
