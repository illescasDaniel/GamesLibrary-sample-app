import Observation
import AccessibilityIdentifiers

/// Mutable inbound stub host for shared-process UI tests.
/// Each `apply` replaces stub tables and bumps `sessionGeneration` so SwiftUI resets root state.
@MainActor
@Observable
public final class UITestScenarioHost {
	public private(set) var sessionGeneration = 0

	public let searchGamesUseCase = StubSearchGamesUseCase()
	public let getGameDetailsUseCase = StubGetGameDetailsUseCase()

	public init() {}

	public func apply(_ configuration: UITestConfiguration) {
		let stubs = UITestSupport.makeStubTables(from: configuration)
		searchGamesUseCase.apply(responses: stubs.searchResponses)
		getGameDetailsUseCase.apply(responses: stubs.detailsResponses)
		sessionGeneration += 1
	}
}
