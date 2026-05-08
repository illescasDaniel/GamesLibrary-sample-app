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
			.navigationTitle(gameSearchItem.name ?? String())
			.navigationBarTitleDisplayMode(.inline)
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
		ScrollView {
			LazyVStack(alignment: .leading, spacing: 16) {

				HStack(alignment: .top, spacing: 16) {
					asyncImage(for: game)

					HStack {
						Group {
							if let rating = game.rating, rating > 0 {
								Text(verbatim: rating.formatted(.number.precision(.fractionLength(1))) + " ⭐")
							}
							if let releaseDate = game.released?.prefix(4) {
								Text(verbatim: String(releaseDate))
							}
							if let playtime = game.playtime, playtime > 0 {
								Text(verbatim: String("\(playtime)h"))
							}
						}
						.font(.footnote)
						.fontWeight(.medium)
						.padding(.horizontal, 10)
						.padding(.vertical, 4)
						.background(
							Capsule()
								.fill(Color(.systemGray6))
						)
					}.padding(.vertical, 8)
				}

				if let description = game.description?.strippingHTML() {
					Text(verbatim: description)
						.font(.body)
				}
			}.padding()

			Spacer()
		}
	}

	@ViewBuilder
	private func asyncImage(for game: Game) -> some View {
		if let url = game.backgroundImage.flatMap(URL.init) {
			AsyncImage(url: url) { phase in
				switch phase {
				case .empty:
					ZStack {
						Color.gray.opacity(0.2)
						ProgressView()
					}
					.frame(width: 128, height: 128)
					.cornerRadius(8)
				case let .success(image):
					image
						.resizable()
						.aspectRatio(contentMode: .fill)
						.frame(width: 128, height: 128)
						.clipped()
						.cornerRadius(8)
				case .failure:
					EmptyView()
				@unknown default:
					EmptyView()
				}
			}
		} else {
			EmptyView()
		}
	}
}

#Preview {
	GameDetailsView(gameSearchItem: .init(id: nil, slug: nil, name: "test", released: nil, tba: nil, backgroundImage: nil, rating: nil, ratingTop: nil, ratings: nil, ratingsCount: nil, reviewsTextCount: nil, added: nil, addedByStatus: nil, metacritic: nil, playtime: nil, suggestionsCount: nil, updated: nil, esrbRating: nil, platforms: nil))
}
