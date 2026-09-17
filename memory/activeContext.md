# Active Context

_Last updated: 2026-09-17_

## Branch

- `develop` (cleanup batch committed; next: POM conventions + `AppContainer.Overrides`)

## Current focus

POM scaling conventions for UI tests and a single `AppContainer.Overrides` bag for DEBUG/UITest seams.

## Just changed

- Committed cleanup: Infrastructure flatten, AccessibilityIdentifiers SPM, UI POM pages, Config.xcconfig sample, shared `httpClient` lazy vars, C API key

## Next steps

1. Introduce `AppContainer.Overrides` + single init; thin Debug bootstrap via `UITestSupport`
2. Extract `AppLauncher`, fluent page navigation, split UITest files; document in adaptations
3. Append decisions + finalize memory after DI/POM work
