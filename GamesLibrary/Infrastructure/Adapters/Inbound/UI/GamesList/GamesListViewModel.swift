import Observation
import Foundation
import BetterLogger
import GamesLibraryCore

@Observable
final class GamesListViewModel {
    var games: [GameSummary] = []
    var gamesState: ListViewState = .loading
    var currentPage: Int = 1
    var searchText: String = ""
    var gamesTask: Task<Void, Never>?

    private let searchGames: any SearchGamesUseCasePort
    private let logger: BetterLogger

    init(searchGames: any SearchGamesUseCasePort, logger: BetterLogger) {
        self.searchGames = searchGames
        self.logger = logger
    }

    func searchGame(loadNextPage: Bool = false) async {
        let searchText = self.searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        gamesTask?.cancel()
        gamesState = .loading

        if loadNextPage {
            currentPage += 1
        } else {
            currentPage = 1
        }

        gamesTask = Task {
            do {
                if !searchText.isEmpty {
                    try await Task.sleep(for: .milliseconds(150))
                }
                await _searchGame(searchText, previousGames: loadNextPage ? games : [])
            } catch is CancellationError {
                logger.debug("Search cancelled due to throttling")
            } catch {
                logger.debug("Search cancelled due to throttling")
            }
        }

        await gamesTask?.value
    }

    private func _searchGame(_ searchText: String, previousGames: [GameSummary]) async {
        gamesState = .loading
        do {
            let newGames = try await searchGames(page: currentPage, searchText: searchText)
            if gamesTask?.isCancelled == true {
                logger.debug("Search cancelled due to newer search")
                setSuccessState()
                return
            }
            games = previousGames + newGames
            setSuccessState()
        } catch {
            logger.error("Search failed", context: ["error": error])
            if gamesTask?.isCancelled == true {
                logger.debug("Search cancelled due to newer search")
                setSuccessState()
                return
            }
            if (error as NSError).code == URLError.cancelled.rawValue {
                logger.debug("Search cancelled at URL Session level")
                setSuccessState()
                return
            }
            gamesState = .error
        }
    }

    private func setSuccessState() {
        gamesState = .success(isEmpty: games.isEmpty)
    }
}
