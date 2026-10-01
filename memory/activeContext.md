# Active Context

_Last updated: 2026-10-01_

## Branch

- `main`

## Current focus

Continue hexagonal/SDD feature work. Code navigation now uses the Homebrew-installed `codenav-swift-mcp` instead of a local source build.

## Just changed

- `.mcp.json` (local, gitignored) now runs `codenav-swift-mcp` from `PATH` (Homebrew `illescasDaniel/tap`, 0.1.1) with `CODENAV_SWIFT_WORKSPACE` pinned to the repo
- Verified all codenav tools natively after an MCP restart (`workspace`, `symbol_info`, `implementations`, `callers`, `outline`, `diagnostics`, `search_symbol`, `references`, `type_at`); index ready, no phantom hits
- README documents `codenav-swift` (MCP table, setup, `.mcp.json` example, features list)
- Build output / index store lives in `DerivedData/` (see `AGENTS.md`)

## Next steps

1. Continue hexagonal/SDD feature work (new screens: IDs → nested page accessors → feature UITest file)
2. Add search/pagination entries in `gamesList.responses` when a UI test needs typed search or page 2
3. If codenav results disagree with grep: `rm -rf DerivedData`, rebuild with `-derivedDataPath DerivedData/GamesLibrary`
