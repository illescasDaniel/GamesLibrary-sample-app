import SwiftUI
import GamesLibraryCore
import AccessibilityIdentifiers
import SwiftUIComponents

/// List + pagination shell. Owns no ViewModel; receives games and callbacks.
struct GamesListContentView: View {
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
