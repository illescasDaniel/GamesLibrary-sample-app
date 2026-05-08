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
			contentView(
				rating: game.rating,
				esbrRating: game.esrbRating?.name,
				released: game.released,
				playtime: game.playtime,
				description: game.description ?? "(No Description)",
				image: game.backgroundImage,
				website: game.website
			)
		case .error:
			ContentUnavailableView {
				Text("An error ocurred. Try again")
			} actions: {
				Button("Retry") {
					Task {
						guard let id = gameSearchItem.id else { return }
						await viewModel.getGameDetails(id: id)
					}
				}.buttonStyle(.glassProminent)
			}
		case .loading:
			ZStack {
				contentView(
					rating: gameSearchItem.rating,
					esbrRating: gameSearchItem.esrbRating?.name,
					released: gameSearchItem.released,
					playtime: gameSearchItem.playtime,
					description: nil,
					image: gameSearchItem.backgroundImage,
					website: nil
				)
				LoadingView("Loading full details")
			}
		}
	}

	@ViewBuilder
	private func contentView(
		rating: Double?,
		esbrRating: String?,
		released: String?,
		playtime: Int?,
		description: String?,
		image: String?,
		website: String?
	) -> some View {
		ScrollView {
			LazyVStack(alignment: .center, spacing: 16) {

				HStack(alignment: .top) {
					asyncImage(for: image)
					Spacer()
					VStack(alignment: .trailing) {
						HStack {
							Group {
								if let rating, rating > 0 {
									Text(verbatim: rating.formatted(.number.precision(.fractionLength(1))) + " ⭐")
								}
								if let releaseDate = released?.prefix(4) {
									Text(verbatim: String(releaseDate))
								}
								if let playtime, playtime > 0 {
									Text(verbatim: String("\(playtime)h"))
								}
							}
							.capsuleChipStyle()
						}

						HStack {
							Group {
								if let esbrRating {
									Label(esbrRating, image: "number.square")
								}
							}
							.capsuleChipStyle()
						}
					}
					.padding(.vertical, 8)
				}.frame(maxWidth: .infinity)

				if let description = description?.strippingHTML() {
					Text(verbatim: description)
						.font(.body)
				} else {
					Text(verbatim: String(Array(repeating: " ", count: 200)))
						.redacted(reason: .placeholder)
				}

				if let website = website.flatMap({ URL(string: $0) }) {
					Link("Visit Website", destination: website)
						.buttonStyle(.borderedProminent)
				}
			}.padding()

			Spacer()
		}
	}

	@ViewBuilder
	private func asyncImage(for image: String?) -> some View {
		if let url = image.flatMap(URL.init) {
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
