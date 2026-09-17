import SwiftUI
import GamesLibraryCore
import AccessibilityIdentifiers

struct GameDetailsView: View {
	@State private var viewModel: GameDetailsViewModel
	let summary: GameSummary

	init(viewModel: GameDetailsViewModel, summary: GameSummary) {
		_viewModel = State(initialValue: viewModel)
		self.summary = summary
	}

	var body: some View {
		Group {
			switch viewModel.gamesState {
			case .success(let game):
				GameDetailsContentView(gameDetails: game, loading: false)
			case .error:
				ContentUnavailableView {
					Text("An error ocurred. Try again")
				} actions: {
					Button("Retry") {
						Task { await viewModel.getGameDetails(id: summary.id) }
					}
					.buttonStyle(.glassProminent)
				}
			case .loading:
				ZStack {
					GameDetailsContentView(gameDetails: summary, loading: true)
					LoadingView("Loading full details")
						.accessibilityIdentifier(AccessibilityIdentifier.GameDetails.loading)
				}
			}
		}
		.navigationTitle(summary.name ?? "Game Details")
		.navigationBarTitleDisplayMode(.inline)
		.accessibilityIdentifier(detailsAccessibilityIdentifier)
		.task(id: summary.id) {
			await viewModel.getGameDetails(id: summary.id)
		}
	}

	/// `ContentUnavailableView` inherits the parent identifier and drops child IDs,
	/// so error uses a root-level id swap (same pattern as the list empty state).
	private var detailsAccessibilityIdentifier: String {
		if case .error = viewModel.gamesState {
			return AccessibilityIdentifier.GameDetails.error
		}
		return AccessibilityIdentifier.GameDetails.screen
	}
}

#if DEBUG
#Preview {
	let summary = GameSummary(id: GameID(1), name: "Preview Game", rating: 4.2, released: "2020-01-01")
	let details = GameDetails(summary: summary, descriptionRaw: "A great game.")
	let container = DebugAppContainer(overrides: .init(
		getGameDetailsUseCase: StubGetGameDetailsUseCase.constant(details)
	))
	GameDetailsView(
		viewModel: container.makeGameDetailsViewModel().previewSucceeding(details),
		summary: summary
	)
}
#endif
