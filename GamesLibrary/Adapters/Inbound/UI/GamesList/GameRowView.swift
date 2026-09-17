import SwiftUI

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
			VStack(alignment: .leading) {
				Text(name ?? "-")
				HStack {
					Group {
						if let rating, rating > 0 {
							Text(verbatim: rating.formatted(.number.precision(.fractionLength(1))) + " ⭐")
						}
						if let releasedYear {
							Text(verbatim: releasedYear)
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
}
