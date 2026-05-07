//
//  GamesInput.swift
//  GamesLibrary
//
//  Created by Daniel Illescas Romero on 6/5/26.
//

import Foundation

struct GamesInput: URLQueryEncodable, nonisolated Hashable, Sendable {

	/// A page number within the paginated result set.
	let page: Int?

	/// Number of results to return per page.
	let pageSize: Int?

	/// Search query.
	let search: String?

	/// Disable fuzziness for the search query.
	let searchPrecise: Bool?

	/// Mark the search query as exact.
	let searchExact: Bool?

	/// Filter by parent platforms, for example: 1,2,3.
	let parentPlatforms: String?

	/// Filter by platforms, for example: 4,5.
	let platforms: String?

	/// Filter by stores, for example: 5,6.
	let stores: String?

	/// Filter by developers, for example: 1612,18893 or valve-software,feral-interactive.
	let developers: String?

	/// Filter by publishers, for example: 354,20987 or electronic-arts,microsoft-studios.
	let publishers: String?

	/// Filter by genres, for example: 4,51 or action,indie.
	let genres: String?

	/// Filter by tags, for example: 31,7 or singleplayer,multiplayer.
	let tags: String?

	/// Filter by creators, for example: 78,28 or cris-velasco,mike-morasky.
	let creators: String?

	/// Filter by a release date, for example: 2010-01-01,2018-12-31.1960-01-01,1969-12-31.
	let dates: String?

	/// Filter by an update date, for example: 2020-12-01,2020-12-31.
	let updated: String?

	/// Filter by platforms count, for example: 1.
	let platformsCount: Int?

	/// Filter by a metacritic rating, for example: 80,100.
	let metacritic: String?

	/// Exclude games from a particular collection, for example: 123.
	let excludeCollection: Int?

	/// Exclude additions.
	let excludeAdditions: Bool?

	/// Exclude games which have additions.
	let excludeParents: Bool?

	/// Exclude games which included in a game series.
	let excludeGameSeries: Bool?

	/// Exclude stores, for example: 5,6.
	let excludeStores: String?

	/// Available fields: name, released, added, created, updated, rating, metacritic. You can reverse the sort order adding a hyphen, for example: -released.
	let ordering: String?

	var queryItems: [URLQueryItem] {
		return [
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
			ordering.map { URLQueryItem(name: "ordering", value: $0) }
		].compactMap { $0 }
	}
}
