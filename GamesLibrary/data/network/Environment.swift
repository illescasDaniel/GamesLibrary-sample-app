//
//  Environment.swift
//  GamesLibrary
//
//  Created by Daniel Illescas Romero on 6/5/26.
//

import Foundation

enum Environment {
	case production

	var baseURL: URL {
		switch self {
		case .production: URL(string: "https://api.rawg.io/api")!
		}
	}
}
