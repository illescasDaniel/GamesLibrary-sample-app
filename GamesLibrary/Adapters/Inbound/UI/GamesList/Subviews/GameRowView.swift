import SwiftUI
import AccessibilityIdentifiers
import SwiftUIComponents

/// List row for a game summary. Takes only the fields it renders so sibling
/// list/search updates do not force unrelated work through this boundary.
struct GameRowView: View {
	let name: String?
	let rating: Double?
	let releasedYear: String?
	let backgroundImageURL: String?

	var body: some View {
		HStack(spacing: 16) {
			GameThumbnailView(
				urlString: backgroundImageURL,
				size: 48,
				emptyAppearance: .photoPlaceholder
			)
			.accessibilityIdentifier(AccessibilityIdentifier.GamesList.GameRow.thumbnail)
			VStack(alignment: .leading) {
				Text(name ?? "-")
					.accessibilityIdentifier(AccessibilityIdentifier.GamesList.GameRow.name)
				HStack {
					Group {
						if let rating, rating > 0 {
							Text("\(rating, format: .number.precision(.fractionLength(1))) ⭐", comment: "Game rating chip; the number is the user score out of 5.")
								.accessibilityIdentifier(AccessibilityIdentifier.GamesList.GameRow.rating)
						}
						if let releasedYear {
							Text(verbatim: releasedYear)
								.accessibilityIdentifier(AccessibilityIdentifier.GamesList.GameRow.year)
						}
					}
					.capsuleChipStyle()
				}
			}
		}
	}
}
