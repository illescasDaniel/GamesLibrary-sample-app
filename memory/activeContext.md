# Active Context

_Last updated: 2026-09-17_

## Branch

- `develop` (SwiftUI section/row View structs)

## Current focus

Continue hexagonal/SDD feature work on `develop`.

## Just changed

- Extracted list/details UI into narrow-input `View` structs (`GameRowView`, `GameThumbnailView`, `GameDetailsContentView` / `Header` / `Description`, private `GamesListContentView`)
- Documented extract-vs-computed rule of thumb in `docs/playbooks/GamesLibrary-adaptations.md` + `.cursor/skills/hexagonal-ios/SKILL.md`
- Unit + UI tests green after refactor

## Next steps

1. Continue hexagonal/SDD feature work (new screens: IDs → async page accessors → feature UITest file)
2. Add `SearchResponse` rows in `UITEST_CONFIG` when a UI test needs typed search or page 2
3. Optional: dedicated slow-details field if a loading-overlay UI assertion is needed
