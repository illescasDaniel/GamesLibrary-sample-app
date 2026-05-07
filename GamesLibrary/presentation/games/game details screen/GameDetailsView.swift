//
//  GameDetailsView.swift
//  GamesLibrary
//
//  Created by Daniel Illescas Romero on 6/5/26.
//

import SwiftUI

struct GameDetailsView: View {

	@Bindable var viewModel: GameDetailsViewModel = inject()

	let gameSearchItem: GameSearchItem

	var body: some View {
		contentState
			.task {
				guard let id = gameSearchItem.id else { return }
				await viewModel.getGameDetails(id: id)
			}
	}

	@ViewBuilder
	private var contentState: some View {
		switch viewModel.gamesState {
		case let .success(game):
			contentView(game)
		case let .error(error):
			Text("error: \(error.localizedDescription)") // TODO: improve
		case .loading:
			VStack {
				ProgressView("Loading full details")

				Text(verbatim: "game: \(gameSearchItem.name ?? "-")")
			}
		}
	}

	@ViewBuilder
	private func contentView(_ game: Game) -> some View {
		VStack {
			Text(verbatim: "full game: \(game.name ?? "-")")
			if let url = game.backgroundImage.flatMap(URL.init) {
				AsyncImage(url: url)
			}
		}
	}
}

#Preview {
	GameDetailsView(gameSearchItem: .init(id: nil, slug: nil, name: "test", released: nil, tba: nil, backgroundImage: nil, rating: nil, ratingTop: nil, ratings: nil, ratingsCount: nil, reviewsTextCount: nil, added: nil, addedByStatus: nil, metacritic: nil, playtime: nil, suggestionsCount: nil, updated: nil, esrbRating: nil, platforms: nil))
}
