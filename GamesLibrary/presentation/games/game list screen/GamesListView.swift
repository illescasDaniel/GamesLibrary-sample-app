//
//  GamesListView.swift
//  GamesLibrary
//
//  Created by Daniel Illescas Romero on 6/5/26.
//

import SwiftUI

struct GameListView: View {

	let viewModel: GamesListViewModel = inject()

	var body: some View {
		NavigationStack {
			listContentState
		}
		.task {
			await viewModel.getListOfGames()
		}
	}

	@ViewBuilder
	private var listContentState: some View {
		switch viewModel.gamesState {
		case let .success(games):
			listContent(games)
		case let .error(error):
			Text("error: \(error.localizedDescription)") // TODO: improve
		case .loading:
			ProgressView()
		}
	}

	@ViewBuilder
	private func listContent(_ games: [Game]) -> some View {
		List(games) { game in
			Text(verbatim: game.name ?? "-")
		}
	}
}

#Preview {
	GameListView()
}
