import SwiftUI
import GamesLibraryCore
import AccessibilityIdentifiers
import SwiftUIComponents
import ViewLoadState

struct GameListView: View {
	@State private var viewModel: GamesListViewModel
	@Environment(AppCoordinator.self) private var coordinator

	init(viewModel: GamesListViewModel) {
		_viewModel = State(initialValue: viewModel)
	}

	var body: some View {
		ScrollViewReader { proxy in
			ZStack {
				GamesListContentView(
					games: viewModel.games,
					onSelect: { game in
						coordinator.push(.details(game))
					},
					onRefresh: {
						await viewModel.searchGame()
					},
					onLoadNextPage: loadNextPage
				)
				switch viewModel.gamesState {
				case .success(isEmpty: true):
					Color(.systemGroupedBackground)
						.overlay {
							ContentUnavailableView {
								Text("No results", comment: "Empty state when a search returns no games.")
							}
						}
						.frame(maxWidth: .infinity, maxHeight: .infinity)
				case .error:
					Color(.systemGroupedBackground).overlay(
						ContentUnavailableView {
							Text("An error occurred. Try again", comment: "Error message when loading the games list fails.")
						} actions: {
							Button {
								Task { await viewModel.searchGame() }
							} label: {
								Text("Retry", comment: "Button that retries loading the games list after an error.")
							}
							.buttonStyle(.glassProminent)
						}
					)
				case .loading:
					LoadingView()
						.accessibilityIdentifier(AccessibilityIdentifier.GamesList.loading)
				case .success(isEmpty: false):
					EmptyView()
				}
			}
			.accessibilityIdentifier(gameListAccessibilityIdentifier)
			.navigationTitle(Text("Games Library", comment: "Navigation title for the games list screen."))
			.onChange(of: viewModel.searchText) { _, _ in
				if let firstGame = viewModel.games.first {
					withAnimation {
						proxy.scrollTo(firstGame.id, anchor: .top)
					}
				}
				Task { await viewModel.searchGame() }
			}
		}
		.searchable(
			text: $viewModel.searchText,
			prompt: Text("Search games", comment: "Placeholder for the games search field.")
		)
		.task {
			await viewModel.searchGame()
		}
	}

	private var gameListAccessibilityIdentifier: String {
		if case .success(isEmpty: true) = viewModel.gamesState {
			return AccessibilityIdentifier.GamesList.emptyState
		}
		return AccessibilityIdentifier.GamesList.screen
	}

	private func loadNextPage() {
		guard case .success(isEmpty: false) = viewModel.gamesState else { return }
		Task { await viewModel.searchGame(loadNextPage: true) }
	}
}

/// List + pagination shell. Owns no ViewModel; receives games and callbacks.
private struct GamesListContentView: View {
	let games: [GameSummary]
	let onSelect: (GameSummary) -> Void
	let onRefresh: () async -> Void
	let onLoadNextPage: () -> Void

	var body: some View {
		List(games) { game in
			Button {
				onSelect(game)
			} label: {
				GameRowView(
					name: game.name,
					rating: game.rating,
					releasedYear: game.released.map { String($0.prefix(4)) },
					backgroundImageURL: game.backgroundImageURL
				)
			}
			.buttonStyle(.plain)
			.accessibilityIdentifier(AccessibilityIdentifier.gameRow(id: game.id.rawValue))
		}
		.animation(.default, value: games)
		.refreshable {
			await onRefresh()
		}
		.onNearBottom {
			onLoadNextPage()
		}
	}
}

#if DEBUG
#Preview("Success") {
	let container = DebugAppContainer(overrides: .init(
		searchGamesUseCase: StubSearchGamesUseCase.constant([
			GameSummary(id: GameID(1), name: "Preview Game", rating: 4.5, released: "2024-01-01"),
		])
	))
	GameListView(viewModel: container.makeGamesListViewModel())
		.environment(AppCoordinator(container: container))
		.environment(\.locale, Locale(identifier: "es"))
}
#endif
