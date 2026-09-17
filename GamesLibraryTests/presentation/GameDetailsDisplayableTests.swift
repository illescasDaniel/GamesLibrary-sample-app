import Testing
import GamesLibraryCore
@testable import GamesLibrary

@Suite
@MainActor
struct GameDetailsDisplayableTests {

	@Test
	func `Given Game Details When Description Raw Exists Then Valid Description Prefers Raw`() {
		let summary = GameSummary(id: GameID(1), name: "Game")
		let details = GameDetails(
			summary: summary,
			descriptionHTML: "<p>HTML</p>",
			descriptionRaw: "Raw description"
		)

		#expect(details.validDescription == "Raw description")
	}

	@Test
	func `Given Game Details When Description Raw Is Whitespace Then Falls Back To HTML`() {
		let summary = GameSummary(id: GameID(1), name: "Game")
		let details = GameDetails(
			summary: summary,
			descriptionHTML: "HTML fallback",
			descriptionRaw: "   "
		)

		#expect(details.validDescription == "HTML fallback")
	}

	@Test
	func `Given Game Summary Then Valid Description Is Nil`() {
		let summary = GameSummary(id: GameID(1), name: "Game")

		#expect(summary.validDescription == nil)
	}
}
