import SwiftUI
import AccessibilityIdentifiers

struct GameDetailsDescriptionView: View {
	let descriptionText: String?
	let loading: Bool

	var body: some View {
		VStack(alignment: .leading, spacing: 16) {
			Text("Description", comment: "Section heading for the game description on the details screen.")
				.font(.title)
				.frame(maxWidth: .infinity, alignment: .leading)
				.padding(.top, 8)

			if let descriptionText {
				Text(verbatim: descriptionText)
					.font(.body)
					.accessibilityIdentifier(AccessibilityIdentifier.GameDetails.description)
			} else if loading {
				Text(verbatim: String(repeating: " ", count: 200))
					.redacted(reason: .placeholder)
			} else {
				Text("(No available description)", comment: "Placeholder when a game has no description text.")
					.font(.body)
					.accessibilityIdentifier(AccessibilityIdentifier.GameDetails.description)
			}
		}
	}
}
