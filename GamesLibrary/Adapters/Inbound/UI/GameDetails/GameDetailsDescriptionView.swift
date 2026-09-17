import SwiftUI
import AccessibilityIdentifiers

struct GameDetailsDescriptionView: View {
	let descriptionText: String?
	let loading: Bool

	var body: some View {
		VStack(alignment: .leading, spacing: 16) {
			Text("Description")
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
				Text(verbatim: "(No available description)")
					.font(.body)
					.accessibilityIdentifier(AccessibilityIdentifier.GameDetails.description)
			}
		}
	}
}
