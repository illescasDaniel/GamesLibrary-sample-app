#if DEBUG
import Foundation
import AccessibilityIdentifiers
import GamesLibraryUITestKit

extension DebugAppContainer.Overrides {
	static func uitest(_ configuration: UITestConfiguration) -> Self {
		let stubs = UITestSupport.makeStubTables(from: configuration)
		return Self(
			searchGamesUseCase: StubSearchGamesUseCase(responses: stubs.searchResponses),
			getGameDetailsUseCase: StubGetGameDetailsUseCase(responses: stubs.detailsResponses),
			urlCache: URLCache(memoryCapacity: 0, diskCapacity: 0)
		)
	}
}
#endif
