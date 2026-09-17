#if DEBUG
import Foundation
import AccessibilityIdentifiers
import GamesLibraryCore

enum UITestSupport {
	static var isRunningUITests: Bool {
		ProcessInfo.processInfo.arguments.contains("-UITesting")
	}

	static var shouldForceEmptyResults: Bool {
		ProcessInfo.processInfo.environment[UITestEnvironment.forceEmptyResultsKey] == "1"
	}

	static var shouldForceDetailsFailure: Bool {
		ProcessInfo.processInfo.environment[UITestEnvironment.forceDetailsFailureKey] == "1"
	}

	/// Maps launch args/env to composition-root use-case overrides for deterministic UI tests.
	static func makeOverrides() -> DebugAppContainer.Overrides? {
		guard isRunningUITests else { return nil }
		let stub = StubGamesRepository(
			games: shouldForceEmptyResults ? [] : StubGamesRepository.defaultGames,
			detailsFailuresRemaining: shouldForceDetailsFailure ? 1 : 0
		)
		return DebugAppContainer.Overrides(
			searchGamesUseCase: SearchGamesUseCase(repository: stub),
			getGameDetailsUseCase: GetGameDetailsUseCase(repository: stub),
			urlCache: URLCache(memoryCapacity: 0, diskCapacity: 0)
		)
	}
}
#endif
