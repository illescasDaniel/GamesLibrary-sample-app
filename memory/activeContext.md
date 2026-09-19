# Active Context

_Last updated: 2026-09-19_

## Branch

- `develop`

## Current focus

Continue hexagonal/SDD feature work on `develop`.

## Just changed

- UI-test deep link scheme (`gameslibrary-uitest`) moved to **Debug-only** `GamesLibrary/Info-Debug.plist`; Release uses generated Info.plist with no custom URL types.
- Deleted shared `GamesLibrary/Info.plist`; Debug `INFOPLIST_FILE` points at `Info-Debug.plist`; Release omits `INFOPLIST_FILE`.
- Adaptations doc + `GamesLibraryUITestTransport` comment updated to document Debug-only plist pattern (ASTK README reference).

## Next steps

1. Continue hexagonal/SDD feature work (new screens: IDs → nested page accessors → feature UITest file)
2. Add search/pagination entries in `gamesList.responses` when a UI test needs typed search or page 2
