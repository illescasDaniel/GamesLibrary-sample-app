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
		.onChange(of: viewModel.searchText, { oldValue, newValue in
			Task { await viewModel.getGames(oldSearchText: oldValue, newSearchText: viewModel.searchText) }
		})
		.task {
			await viewModel.getGames(oldSearchText: nil, newSearchText: viewModel.searchText)
		}
	}

	@ViewBuilder
	private var listContentState: some View {
		ZStack {
			listContent(viewModel.games)
			switch viewModel.gamesState {
			case .success: EmptyView()
			case .error:
				Color(.systemGroupedBackground).overlay(
					ContentUnavailableView {
						Text("An error ocurred. Try again")
					} actions: {
						Button("Retry") {
							Task {
								await viewModel.getGames(oldSearchText: nil, newSearchText: viewModel.searchText)
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
			viewModel.currentPage = 0
			Task { await viewModel.getGames(oldSearchText: nil, newSearchText: viewModel.searchText) }
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

		viewModel.currentPage += 1
		Task { await viewModel.getGames(oldSearchText: nil, newSearchText: viewModel.searchText) }
	}

	@ViewBuilder
	private func gameRowView(for game: GameSearchItem) -> some View {
		HStack {
			asyncImage(for: game)
			Text(verbatim: game.name ?? "-")
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
