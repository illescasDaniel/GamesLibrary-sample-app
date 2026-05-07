import Foundation
@testable import GamesLibrary

extension GamesInput {
	@MainActor
	static func dummy(page: Int, pageSize: Int) -> GamesInput {
		GamesInput(page: page, pageSize: pageSize, search: nil, searchPrecise: nil, searchExact: nil, parentPlatforms: nil, platforms: nil, stores: nil, developers: nil, publishers: nil, genres: nil, tags: nil, creators: nil, dates: nil, updated: nil, platformsCount: nil, metacritic: nil, excludeCollection: nil, excludeAdditions: nil, excludeParents: nil, excludeGameSeries: nil, excludeStores: nil, ordering: nil)
	}
}
