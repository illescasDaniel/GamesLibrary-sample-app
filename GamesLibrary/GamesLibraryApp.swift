//
//  GamesLibraryApp.swift
//  GamesLibrary
//
//  Created by Daniel Illescas Romero on 6/5/26.
//

import SwiftUI

@main
struct GamesLibraryApp: App {

	init() {
		URLCache.shared = inject()
	}

	var body: some Scene {
		WindowGroup {
			#if DEBUG
			if isTesting {
				EmptyView()
			} else {
				GameListView()
			}
			#else
			GameListView()
			#endif
		}
	}

	#if DEBUG
	private var isTesting: Bool {
		return ProcessInfo.processInfo.environment["IS_TESTING"] == "1"
	}
	#endif
}
