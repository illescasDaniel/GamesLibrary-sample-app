# Active Context

_Last updated: 2026-09-17_

## Branch

- `develop` (stub use cases for UI tests)

## Current focus

Continue hexagonal/SDD feature work on `develop`.

## Just changed

- `AppContainer` init now takes `urlCache`, `httpDataRequestHandler`, `requestInterceptors`, and `responseInterceptors` (nil request/cache → production defaults)
- `DebugAppContainer` passes `logger` + `overrides.urlCache` into `AppContainer`; `configureSharedURLCache` always forwards to production

## Next steps

1. Continue hexagonal/SDD feature work (new screens: IDs → async page accessors → feature UITest file)
2. Extend per-screen nested configs on `UITestConfiguration` when new stub scenarios appear (avoid new env keys)
3. Optional: dedicated slow-details field if a loading-overlay UI assertion is needed
