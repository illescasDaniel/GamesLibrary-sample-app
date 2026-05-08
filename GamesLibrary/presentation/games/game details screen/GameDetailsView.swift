//
//  GameDetailsView.swift
//  GamesLibrary
//
//  Created by Daniel Illescas Romero on 6/5/26.
//

import SwiftUI
import OptimizedAsyncImage

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
			contentView(gameDetails: game, loading: false)
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
				contentView(gameDetails: gameSearchItem, loading: true)
				LoadingView("Loading full details")
			}
		}
	}

	@ViewBuilder
	private func contentView(gameDetails: any GameDetailsProtocol, loading: Bool) -> some View {
		ScrollView(.vertical) {
			LazyVStack(alignment: .center, spacing: 16) {

				HStack(alignment: .top) {
					asyncImage(for: gameDetails.backgroundImage)
					Spacer()
					VStack(alignment: .trailing) {
						HStack {
							Group {
								if let rating = gameDetails.rating, rating > 0 {
									Text(verbatim: rating.formatted(.number.precision(.fractionLength(1))) + " ⭐")
								}
								if let releaseDate = gameDetails.released?.prefix(4) {
									Text(verbatim: String(releaseDate))
								}
								if let playtime = gameDetails.playtime, playtime > 0 {
									Text(verbatim: String("\(playtime)h"))
								}
							}
							.capsuleChipStyle()
						}

						HStack {
							Group {
								if let esbrRating = gameDetails.esrbRating?.name {
									Label(esbrRating, systemImage: "number.square")
								}
							}
							.capsuleChipStyle()
						}

						ScrollView(.horizontal) {
							LazyHStack {
								Group {
									let platforms = gameDetails.platforms?.compactMap({ $0.platform?.name }) ?? []
									ForEach(platforms, id: \.self) { platform in
										Text(platform)
											.environment(\.layoutDirection, .leftToRight)
									}
								}
								.capsuleChipStyle()
							}
						}
						.environment(\.layoutDirection, .rightToLeft)
					}
					.padding(.vertical, 8)
				}.frame(maxWidth: .infinity)

				Text("Description")
					.font(.title)
					.frame(maxWidth: .infinity, alignment: .leading)
					.padding(.top, 8)

				if let description = gameDetails.validDescription?.strippingHTML() {
					Text(verbatim: description)
						.font(.body)
				} else if loading {
					Text(verbatim: String(Array(repeating: " ", count: 200)))
						.redacted(reason: .placeholder)
				} else {
					Text(verbatim: "(No available description)")
						.font(.body)
				}

				if let website = gameDetails.website.flatMap({ URL(string: $0) }) {
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
			OptimizedAsyncImage(url: url, targetSize: CGSize(width: 128, height: 128)) { phase in
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
