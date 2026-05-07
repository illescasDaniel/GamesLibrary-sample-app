//
//  GamesListView.swift
//  GamesLibrary
//
//  Created by Daniel Illescas Romero on 6/5/26.
//

import SwiftUI

struct GameListView: View {

	@Bindable var viewModel: GamesListViewModel = inject()

	var body: some View {
		NavigationStack {
			listContentState
		}
		.searchable(text: $viewModel.searchText)
		.onChange(of: viewModel.searchText, { oldValue, newValue in
			viewModel.searchGame(oldSearchText: oldValue, newSearchText: newValue)
		})
		.task {
			await viewModel.getGames()
		}
	}

	@ViewBuilder
	private var listContentState: some View {
		switch viewModel.gamesState {
		case let .success(games):
			listContent(games)
		case let .error(error):
			ContentUnavailableView {
				Text("An error ocurred. Try again")
			} actions: {
				Button("Retry") {
					Task {
						await viewModel.getGames()
					}
				}.buttonStyle(.glassProminent)
			}
		case .loading:
			ProgressView()
		}
	}

	@ViewBuilder
	private func listContent(_ games: [GameSearchItem]) -> some View {
		List(games) { game in
			NavigationLink {
				GameDetailsView(gameSearchItem: game)
			} label: {
				VStack {
					Text(verbatim: game.name ?? "-")
					if let url = game.backgroundImage.flatMap(URL.init) {
						AsyncImage(url: url)
					}
				}
			}
		}
	}
}

#Preview {
	GameListView()
}
