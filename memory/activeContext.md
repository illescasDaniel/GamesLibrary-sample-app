# Active Context

_Last updated: 2026-09-17_

## Branch

- `develop` (use-case-only Debug Overrides)

## Current focus

Continue hexagonal/SDD feature work on `develop`.

## Just changed

- Committed `AppContaining` + `DebugAppContainer` (`3d0142a`)
- Overrides: use cases + urlCache + logger only; response logging on `AppContainer` DEBUG
- `DebugAppContainer` always builds VMs via `override ?? production` (no `needsCustomViewModels`)

## Next steps

1. Continue hexagonal/SDD feature work (new screens: IDs → async page accessors → feature UITest file)
2. Optional: dedicated slow-details env if a loading-overlay UI assertion is needed
