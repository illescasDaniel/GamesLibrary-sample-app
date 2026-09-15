import Testing
import GamesLibraryCore
@testable import GamesLibrary

@Suite
@MainActor
struct GameDetailsDisplayableTests {

    @Test
    func givenGameDetailsWhenDescriptionRawExistsThenValidDescriptionPrefersRaw() {
        let summary = GameSummary(id: GameID(1), name: "Game")
        let details = GameDetails(
            summary: summary,
            descriptionHTML: "<p>HTML</p>",
            descriptionRaw: "Raw description"
        )

        #expect(details.validDescription == "Raw description")
    }

    @Test
    func givenGameDetailsWhenDescriptionRawIsWhitespaceThenFallsBackToHTML() {
        let summary = GameSummary(id: GameID(1), name: "Game")
        let details = GameDetails(
            summary: summary,
            descriptionHTML: "HTML fallback",
            descriptionRaw: "   "
        )

        #expect(details.validDescription == "HTML fallback")
    }

    @Test
    func givenGameSummaryThenValidDescriptionIsNil() {
        let summary = GameSummary(id: GameID(1), name: "Game")

        #expect(summary.validDescription == nil)
    }
}
