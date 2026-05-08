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
				.navigationTitle("Games Library")
		}
		.searchable(text: $viewModel.searchText)
		.onChange(of: viewModel.searchText, { _, newValue in
			Task { await viewModel.searchGame() }
		})
		.task {
			await viewModel.searchGame()
		}
	}

	@ViewBuilder
	private var listContentState: some View {
		ZStack {
			listContent(viewModel.games)
			switch viewModel.gamesState {
			case let .success(isEmpty):
				if isEmpty {
					ContentUnavailableView {
						Text("No results")
					}
				}
			case .error:
				Color(.systemGroupedBackground).overlay(
					ContentUnavailableView {
						Text("An error ocurred. Try again")
					} actions: {
						Button("Retry") {
							Task {
								await viewModel.searchGame()
							}
						}.buttonStyle(.glassProminent)
					}
				)
			case .loading:
				ProgressView("Loading...")
					.controlSize(.regular)
					.padding(24)
					.background(.ultraThinMaterial)
					.foregroundColor(.primary)
					.clipShape(RoundedRectangle(cornerRadius: 16))
					.overlay(
						RoundedRectangle(cornerRadius: 16)
							.stroke(
								LinearGradient(
									colors: [.white.opacity(0.6), .clear, .white.opacity(0.2)],
									startPoint: .topLeading,
									endPoint: .bottomTrailing
								),
								lineWidth: 1.5
							)
					)
					.shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 4)
			}
		}
	}

	@ViewBuilder
	private func listContent(_ games: [GameSearchItem]) -> some View {
		List(games) { game in
			NavigationLink {
				GameDetailsView(gameSearchItem: game)
			} label: {
				gameRowView(for: game)
			}
		}
		.refreshable {
			await viewModel.searchGame()
		}
		.onScrollGeometryChange(for: Bool.self) { geometry in
			guard geometry.contentSize != .zero else { return false }
			let distanceFromBottom = geometry.contentSize.height - geometry.contentOffset.y - geometry.containerSize.height
			return distanceFromBottom < 100
		} action: { oldValue, isNearBottom in
			if isNearBottom {
				loadNextPage()
			}
		}
	}

	private func loadNextPage() {
		guard case .success = viewModel.gamesState else { return }

		Task {
			await viewModel.searchGame(loadNextPage: true)
		}
	}

	@ViewBuilder
	private func gameRowView(for game: GameSearchItem) -> some View {
		HStack(spacing: 16) {
			asyncImage(for: game)
			VStack(alignment: .leading) {
				Text(game.name ?? "-")
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
				}
			}
		}
	}

	@ViewBuilder
	private func asyncImage(for game: GameSearchItem) -> some View {
		if let url = game.backgroundImage.flatMap(URL.init) {
			AsyncImage(url: url) { phase in
				switch phase {
				case .empty:
					ZStack {
						Color.gray.opacity(0.2)
						ProgressView()
					}
					.frame(width: 48, height: 48)
					.cornerRadius(8)
				case let .success(image):
					image
						.resizable()
						.aspectRatio(contentMode: .fill)
						.frame(width: 48, height: 48)
						.clipped()
						.cornerRadius(8)
				case .failure:
					emptyImage
				@unknown default:
					EmptyView()
				}
			}
		} else {
			emptyImage
		}
	}

	private var emptyImage: some View {
		Image(systemName: "photo")
			.foregroundColor(.gray)
			.frame(width: 48, height: 48)
			.background(Color.gray.opacity(0.1))
			.cornerRadius(8)
	}
}

#Preview {
	GameListView()
}
