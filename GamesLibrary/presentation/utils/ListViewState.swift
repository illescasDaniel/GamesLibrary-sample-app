//
//  BasicViewState.swift
//  GamesLibrary
//
//  Created by Daniel Illescas Romero on 7/5/26.
//

enum ListViewState: Equatable {
	case success(isEmpty: Bool)
	case error
	case loading
}
