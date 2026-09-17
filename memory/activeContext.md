# Active Context

_Last updated: 2026-09-17_

## Branch

- `develop` (AppContaining + DebugAppContainer)

## Current focus

Continue hexagonal/SDD feature work on `develop`.

## Just changed

- Release scheme clean: `#Preview` using `DebugAppContainer` wrapped in `#if DEBUG`; `unsafe String(cString:)` for API key under strict memory safety

## Next steps

1. Continue hexagonal/SDD feature work (new screens: IDs → async page accessors → feature UITest file)
2. Optional: dedicated slow-details env if a loading-overlay UI assertion is needed
