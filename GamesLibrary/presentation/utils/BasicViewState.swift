//
//  BasicViewState.swift
//  GamesLibrary
//
//  Created by Daniel Illescas Romero on 7/5/26.
//

enum BasicViewState: Equatable {
	case success
	case error
	case loading

	var isLoading: Bool {
		switch self {
		case .loading:
			return true
		case .success, .error:
			return false
		}
	}
}
