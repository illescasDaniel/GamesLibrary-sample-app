import Testing
import Foundation
@testable import GamesLibrary
import HTTIES

@Suite
@MainActor
struct GamesNetworkDataSourceTests {

	@Test
	func givenDataSourceWhenFetchingGamesSucceedsThenResultIsCorrect() async throws {
		// given
		let mockHTTPClient = MockHTTPClient()
		let dataSource = GamesNetworkDataSourceImpl(
			httpClient: mockHTTPClient,
			environment: .production,
			jsonDecoder: JSONDecoder()
		)

		let expectedOutput = GamesOutput.dummy(results: [GameSearchItem.dummy(id: 1)])
		mockHTTPClient.result = expectedOutput

		let input = GamesInput.dummy(page: 1, pageSize: 20)

		// when
		let result = try await dataSource.games(input)

		// then
		#expect(result.results.first?.id == 1)
		#expect(mockHTTPClient.lastRequest?.urlRequest.url?.absoluteString.contains("/games") == true)
	}

	@Test
	func givenDataSourceWhenFetchingGamesFailsThenThrowsError() async throws {
		// given
		let mockHTTPClient = MockHTTPClient()
		let dataSource = GamesNetworkDataSourceImpl(
			httpClient: mockHTTPClient,
			environment: .production,
			jsonDecoder: JSONDecoder()
		)

		mockHTTPClient.error = MockError.anyError

		let input = GamesInput.dummy(page: 1, pageSize: 20)

		// when / then
		await #expect(throws: MockError.anyError) {
			try await dataSource.games(input)
		}
	}
}
