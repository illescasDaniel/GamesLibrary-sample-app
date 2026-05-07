//
//  ViewState.swift
//  GamesLibrary
//
//  Created by Daniel Illescas Romero on 7/5/26.
//

enum ViewState<T, E: Error> {
	case success(T)
	case error(E)
	case loading
}
