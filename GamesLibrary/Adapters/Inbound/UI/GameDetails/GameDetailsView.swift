import SwiftUI
import GamesLibraryCore
import AccessibilityIdentifiers
import SwiftUIComponents
import ViewLoadState

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
					Text("An error occurred. Try again", comment: "Error message when loading game details fails.")
				} actions: {
					Button {
						Task { await viewModel.getGameDetails(id: summary.id) }
					} label: {
						Text("Retry", comment: "Button that retries loading game details after an error.")
					}
					.buttonStyle(.glassProminent)
				}
			case .loading:
				ZStack {
					GameDetailsContentView(gameDetails: summary, loading: true)
					LoadingView(LocalizedStringResource(
						"Loading full details",
						comment: "Loading overlay shown while full game details are fetching."
					))
						.accessibilityIdentifier(AccessibilityIdentifier.GameDetails.loading)
				}
			}
		}
		.navigationTitle(detailsNavigationTitle)
		.navigationBarTitleDisplayMode(.inline)
		.accessibilityIdentifier(detailsAccessibilityIdentifier)
		.task(id: summary.id) {
			await viewModel.getGameDetails(id: summary.id)
		}
	}

	/// `ContentUnavailableView` inherits the parent identifier and drops child IDs,
	/// so error uses a root-level id swap (same pattern as the list empty state).
	private var detailsNavigationTitle: Text {
		if let name = summary.name {
			Text(verbatim: name)
		} else {
			Text("Game Details", comment: "Navigation title when the game name is unavailable.")
		}
	}

	private var detailsAccessibilityIdentifier: String {
		if case .error = viewModel.gamesState {
			return AccessibilityIdentifier.GameDetails.error
		}
		return AccessibilityIdentifier.GameDetails.screen
	}
}

#if DEBUG
import GamesLibraryUITestKit

#Preview {
	let summary = GameSummary(id: GameID(1), name: "Preview Game", rating: 4.2, released: "2020-01-01")
	let details = GameDetails(summary: summary, descriptionRaw: "A great game.")
	let container = DebugAppContainer(overrides: .init(
		getGameDetailsUseCase: StubGetGameDetailsUseCase.constant(details)
	))
	GameDetailsView(
		viewModel: container.makeGameDetailsViewModel(),
		summary: summary
	)
	.environment(\.locale, Locale(identifier: "es"))
}
#endif
