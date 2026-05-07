//
//  GamesOutput.swift
//  GamesLibrary
//
//  Created by Daniel Illescas Romero on 6/5/26.
//

import Foundation

struct GamesOutput: Decodable {

	let count: Int

	/// string <uri> Nullable
	let next: String?

	/// string <uri> Nullable
	let previous: String?

	let results: [Game]
}
