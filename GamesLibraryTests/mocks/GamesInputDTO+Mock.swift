import Foundation
@testable import GamesLibrary

extension GamesInputDTO {
    static func dummy(page: Int = 1, pageSize: Int = 20, search: String? = nil) -> GamesInputDTO {
        GamesInputDTO(
            page: page,
            pageSize: pageSize,
            search: search,
            searchPrecise: true,
            searchExact: true,
            parentPlatforms: nil,
            platforms: nil,
            stores: nil,
            developers: nil,
            publishers: nil,
            genres: nil,
            tags: nil,
            creators: nil,
            dates: nil,
            updated: nil,
            platformsCount: nil,
            metacritic: nil,
            excludeCollection: nil,
            excludeAdditions: nil,
            excludeParents: nil,
            excludeGameSeries: nil,
            excludeStores: nil,
            ordering: nil
        )
    }
}
