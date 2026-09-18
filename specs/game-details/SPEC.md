# Game Details

## Metadata

- **Feature:** Full game details for a selected catalog item
- **API:** RAWG `/games/{id}` endpoint
- **Screens:** Game details (pushed from list)

## Triggers & routing

- **Entry:** User taps a game row on the games list → `Route.details(GameSummary)`.
- **Exit:** Back navigation pops the stack.

## Visual & UI rules

- User-facing copy in this spec is the **English source**; localized strings live in `GamesLibrary/Resources/Localizable.xcstrings`.
- Inline navigation title from game name (fallback: "Game Details")
- Shows placeholder content from list item while loading full details
- Full details: hero image (128×128), rating/year/playtime chips, ESRB chip, platform chips, description (HTML stripped), website link
- Loading overlay: "Loading full details"
- Error state with Retry when fetch fails and a valid id exists
- If id is missing, show list-item data without retry

## Acceptance criteria (BDD)

### Scenario: Load full details

- **Given** the user navigates to a game with a valid id
- **When** the details screen appears
- **Then** placeholder data from the list item is shown immediately
- **And** full details replace placeholders when the request succeeds

### Scenario: Details fetch error with retry

- **Given** the details request fails
- **When** the game has a valid id
- **Then** an error state with Retry is shown
- **And** tapping Retry re-fetches details

## Out of scope

- Missing-id navigation (domain model requires `GameID`; reintroduce if optional ids are added later)
- Screenshots gallery, videos, reviews
- Share sheet
- Deep linking to details
- Related games / recommendations
