import Foundation
import GamesLibraryCore
@testable import GamesLibrary

@MainActor
final class MockGetGameDetailsUseCase: GetGameDetailsUseCasePort {
    var result: Result<GameDetails, any Error>?
    private(set) var callCount = 0

    func callAsFunction(id: GameID) async throws -> GameDetails {
        callCount += 1
        if let result {
            return try result.get()
        }
        throw MockError.notConfigured
    }
}
