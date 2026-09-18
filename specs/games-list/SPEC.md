# Games List

## Metadata

- **Feature:** Browse and search games from the RAWG catalog
- **API:** RAWG `/games` endpoint
- **Screens:** Games list (root)

## Triggers & routing

- **Entry:** App launch → Games list is the root screen inside `NavigationStack`.
- **Exit:** User taps a row → navigates to Game Details via `AppCoordinator.push(.details(summary))`.

## Visual & UI rules

- User-facing copy in this spec is the **English source**; localized strings live in `GamesLibrary/Resources/Localizable.xcstrings`.
- Navigation title: "Games Library"
- Search bar filters results as the user types (150 ms debounce when search text is non-empty)
- Pull-to-refresh reloads page 1
- Infinite scroll: loading next page when within 100 pt of list bottom
- Row shows thumbnail (48×48), name, rating chip, release year chip
- Loading overlay while fetching
- Empty search results: "No results" content unavailable view
- Error state: retry button

## Acceptance criteria (BDD)

### Scenario: Initial load shows games

- **Given** the app launches with network available
- **When** the games list appears
- **Then** a loading indicator is shown
- **And** games are displayed when the request succeeds

### Scenario: Search filters results

- **Given** the user is on the games list
- **When** the user types in the search field
- **Then** results update to match the search query
- **And** the list scrolls to the top

### Scenario: Empty search results

- **Given** the user searches for a term with no matches
- **When** the search completes
- **Then** the list shows "No results"

### Scenario: Network error with retry

- **Given** the search request fails with a non-404 error
- **When** the error is received
- **Then** an error state with a Retry button is shown
- **And** tapping Retry re-runs the search

### Scenario: End of pagination (404)

- **Given** the user scrolls to load more pages
- **When** the API returns 404 (no further results)
- **Then** the list stays in success state with existing games

### Scenario: Pagination appends results

- **Given** the user has loaded page 1
- **When** the user scrolls near the bottom
- **Then** page 2 results are appended to the list

## Out of scope

- User accounts / authentication
- Favorites or local persistence beyond in-memory TTL cache
- Offline mode
- Filters beyond text search (platform, genre, etc.)
