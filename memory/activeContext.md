# Active Context

_Last updated: 2026-10-01_

## Branch

- `main`

## Current focus

Continue hexagonal/SDD feature work. Code navigation now uses the Homebrew-installed `codenav-swift-mcp` instead of a local source build.

## Just changed

- `.mcp.json` is now checked in (removed from `.gitignore`) and registers `codenav-swift`, `ios-simulator`, and `xcode-tools` for Claude Code; no `CODENAV_SWIFT_WORKSPACE` needed because codenav resolves the repo from `CLAUDE_PROJECT_DIR` (verified with its `workspace` tool)
- All three servers verified connected; `xcode-tools` needs a first `XcodeOpenWorkspace` call on `GamesLibrary.xcodeproj` (with Xcode open) to approve the agent
- README MCP section updated accordingly; the old `.mcp.json` example was removed
- Build output / index store lives in `DerivedData/` (see `AGENTS.md`)

## Next steps

1. Continue hexagonal/SDD feature work (new screens: IDs → nested page accessors → feature UITest file)
2. Add search/pagination entries in `gamesList.responses` when a UI test needs typed search or page 2
3. If codenav results disagree with grep: `rm -rf DerivedData`, rebuild with `-derivedDataPath DerivedData/GamesLibrary`
