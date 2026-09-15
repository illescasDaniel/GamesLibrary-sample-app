import Testing
import Foundation
import HTTIES
@testable import GamesLibrary

@Suite
@MainActor
struct GamesNetworkDataSourceTests {

	@Test
	func givenNetworkDataSourceWhen404ThenReturnsEmptyResults() async throws {
		let mockHTTPClient = MockHTTPClient()
		mockHTTPClient.error = AppNetworkResponseError.unexpected(statusCode: 404)

		let dataSource = GamesNetworkDataSourceImpl(
			httpClient: mockHTTPClient,
			environment: AppEnvironment.production,
			jsonDecoder: JSONDecoder()
		)

		let output = try await dataSource.games(GamesInputDTO.dummy(page: 1))

		#expect(output.results.isEmpty)
		#expect(output.count == 0)
	}
}
