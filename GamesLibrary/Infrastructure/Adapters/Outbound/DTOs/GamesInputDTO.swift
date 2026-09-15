import Foundation

struct GamesInputDTO: URLQueryEncodable, nonisolated Hashable, Sendable {
	let page: Int?
	let pageSize: Int?
	let search: String?
	let searchPrecise: Bool?
	let searchExact: Bool?
	let parentPlatforms: String?
	let platforms: String?
	let stores: String?
	let developers: String?
	let publishers: String?
	let genres: String?
	let tags: String?
	let creators: String?
	let dates: String?
	let updated: String?
	let platformsCount: Int?
	let metacritic: String?
	let excludeCollection: Int?
	let excludeAdditions: Bool?
	let excludeParents: Bool?
	let excludeGameSeries: Bool?
	let excludeStores: String?
	let ordering: String?

	var queryItems: [URLQueryItem] {
		[
			page.map { URLQueryItem(name: "page", value: String($0)) },
			pageSize.map { URLQueryItem(name: "page_size", value: String($0)) },
			search.map { URLQueryItem(name: "search", value: $0) },
			searchPrecise.map { URLQueryItem(name: "search_precise", value: String($0)) },
			searchExact.map { URLQueryItem(name: "search_exact", value: String($0)) },
			parentPlatforms.map { URLQueryItem(name: "parent_platforms", value: $0) },
			platforms.map { URLQueryItem(name: "platforms", value: $0) },
			stores.map { URLQueryItem(name: "stores", value: $0) },
			developers.map { URLQueryItem(name: "developers", value: $0) },
			publishers.map { URLQueryItem(name: "publishers", value: $0) },
			genres.map { URLQueryItem(name: "genres", value: $0) },
			tags.map { URLQueryItem(name: "tags", value: $0) },
			creators.map { URLQueryItem(name: "creators", value: $0) },
			dates.map { URLQueryItem(name: "dates", value: $0) },
			updated.map { URLQueryItem(name: "updated", value: $0) },
			platformsCount.map { URLQueryItem(name: "platforms_count", value: String($0)) },
			metacritic.map { URLQueryItem(name: "metacritic", value: $0) },
			excludeCollection.map { URLQueryItem(name: "exclude_collection", value: String($0)) },
			excludeAdditions.map { URLQueryItem(name: "exclude_additions", value: String($0)) },
			excludeParents.map { URLQueryItem(name: "exclude_parents", value: String($0)) },
			excludeGameSeries.map { URLQueryItem(name: "exclude_game_series", value: String($0)) },
			excludeStores.map { URLQueryItem(name: "exclude_stores", value: $0) },
			ordering.map { URLQueryItem(name: "ordering", value: $0) },
		].compactMap { $0 }
	}
}
