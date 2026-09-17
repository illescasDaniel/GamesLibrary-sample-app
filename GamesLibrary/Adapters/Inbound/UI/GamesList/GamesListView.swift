import SwiftUI
import OptimizedAsyncImage
import GamesLibraryCore
import BetterLogger
import AccessibilityIdentifiers

struct GameListView: View {
	@State private var viewModel: GamesListViewModel
	@Environment(AppCoordinator.self) private var coordinator

	init(viewModel: GamesListViewModel) {
		_viewModel = State(initialValue: viewModel)
	}

	var body: some View {
		ScrollViewReader { proxy in
			listContentState
				.accessibilityIdentifier(gamesListAccessibilityIdentifier)
				.navigationTitle("Games Library")
				.onChange(of: viewModel.searchText) { _, _ in
					if let firstGame = viewModel.games.first {
						withAnimation {
							proxy.scrollTo(firstGame.id, anchor: .top)
						}
					}
					Task { await viewModel.searchGame() }
				}
		}
		.searchable(text: $viewModel.searchText)
		.task {
			await viewModel.searchGame()
		}
	}

	private var gamesListAccessibilityIdentifier: String {
		if case .success(isEmpty: true) = viewModel.gamesState {
			return AccessibilityIdentifier.GamesList.emptyState
		}
		return AccessibilityIdentifier.GamesList.screen
	}

	@ViewBuilder
	private var listContentState: some View {
		ZStack {
			listContent(viewModel.games)
			switch viewModel.gamesState {
			case .success(isEmpty: true):
				Color(.systemGroupedBackground)
					.overlay {
						ContentUnavailableView {
							Text("No results")
						}
					}
					.frame(maxWidth: .infinity, maxHeight: .infinity)
			case .error:
				Color(.systemGroupedBackground).overlay(
					ContentUnavailableView {
						Text("An error ocurred. Try again")
					} actions: {
						Button("Retry") {
							Task { await viewModel.searchGame() }
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
	}

	@ViewBuilder
	private func listContent(_ games: [GameSummary]) -> some View {
		List(games) { game in
			Button {
				coordinator.push(.details(game))
			} label: {
				gameRowView(for: game)
			}
			.buttonStyle(.plain)
			.accessibilityIdentifier(AccessibilityIdentifier.gameRow(id: game.id.rawValue))
		}
		.animation(.default, value: viewModel.games)
		.refreshable {
			await viewModel.searchGame()
		}
		.onScrollGeometryChange(for: Bool.self) { geometry in
			guard geometry.contentSize != .zero else { return false }
			let distanceFromBottom = geometry.contentSize.height - geometry.contentOffset.y - geometry.containerSize.height
			return distanceFromBottom < 100
		} action: { oldValue, isNearBottom in
			if isNearBottom && !oldValue {
				loadNextPage()
			}
		}
	}

	private func loadNextPage() {
		guard case .success(isEmpty: false) = viewModel.gamesState else { return }
		Task { await viewModel.searchGame(loadNextPage: true) }
	}

	@ViewBuilder
	private func gameRowView(for game: GameSummary) -> some View {
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
	private func asyncImage(for game: GameSummary) -> some View {
		if let url = game.backgroundImageURL.flatMap(URL.init) {
			OptimizedAsyncImage(url: url, targetSize: CGSize(width: 48, height: 48)) { phase in
				switch phase {
				case .empty:
					ZStack {
						Color.gray.opacity(0.2)
						ProgressView()
					}
					.frame(width: 48, height: 48)
					.cornerRadius(8)
				case .success(let image):
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

#Preview("Success") {
	let mock = PreviewMockSearchGamesUseCase(result: .success([
		GameSummary(id: GameID(1), name: "Preview Game", rating: 4.5, released: "2024-01-01"),
	]))
	GameListView(
		viewModel: GamesListViewModel(
			searchGames: mock,
			logger: BetterLogger(name: "Preview")
		)
	)
	.environment(AppCoordinator(container: AppContainer(overrides: .init(gamesRepository: PreviewMockGamesRepository()))))
}

private struct PreviewMockSearchGamesUseCase: SearchGamesUseCasePort {
	let result: Result<[GameSummary], any Error>
	func callAsFunction(page: Int, searchText: String) async throws -> [GameSummary] {
		try result.get()
	}
}

private struct PreviewMockGamesRepository: GamesRepositoryPort {
	func searchGames(query: String, page: Int, pageSize: Int, ordering: String?) async throws -> [GameSummary] { [] }
	func gameDetails(id: GameID) async throws -> GameDetails {
		GameDetails(summary: GameSummary(id: id))
	}
}
