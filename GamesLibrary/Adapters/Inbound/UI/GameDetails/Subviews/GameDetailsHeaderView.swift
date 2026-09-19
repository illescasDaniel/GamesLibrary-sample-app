import SwiftUI
import AccessibilityIdentifiers
import SwiftUIComponents

/// Cover + meta chips for game details. Narrow inputs keep this section from
/// re-evaluating when only description/loading copy changes.
struct GameDetailsHeaderView: View {
	let backgroundImageURL: String?
	let rating: Double?
	let releasedYear: String?
	let playtimeHours: Int?
	let esrbName: String?
	let platformNames: [String]

	var body: some View {
		HStack(alignment: .top) {
			GameThumbnailView(
				urlString: backgroundImageURL,
				size: 128,
				emptyAppearance: .hidden
			)
			Spacer()
			VStack(alignment: .trailing) {
				HStack {
					Group {
						if let rating, rating > 0 {
							Text("\(rating, format: .number.precision(.fractionLength(1))) ⭐", comment: "Game rating chip; the number is the user score out of 5.")
								.accessibilityIdentifier(AccessibilityIdentifier.GameDetails.rating)
						}
						if let releasedYear {
							Text(verbatim: releasedYear)
								.accessibilityIdentifier(AccessibilityIdentifier.GameDetails.year)
						}
						if let playtimeHours, playtimeHours > 0 {
							Text("\(playtimeHours)h", comment: "Estimated playtime chip; the number is hours of gameplay.")
								.accessibilityIdentifier(AccessibilityIdentifier.GameDetails.playtime)
						}
					}
					.capsuleChipStyle()
				}

				HStack {
					Group {
						if let esrbName {
							Label(esrbName, systemImage: "number.square")
								.accessibilityIdentifier(AccessibilityIdentifier.GameDetails.esrb)
						}
					}
					.capsuleChipStyle()
				}

				ScrollView(.horizontal) {
					LazyHStack {
						Group {
							ForEach(platformNames, id: \.self) { platform in
								Text(platform)
									.environment(\.layoutDirection, .leftToRight)
							}
						}
						.capsuleChipStyle()
					}
				}
				.environment(\.layoutDirection, .rightToLeft)
				.accessibilityIdentifier(AccessibilityIdentifier.GameDetails.platforms)
			}
			.padding(.vertical, 8)
		}
		.frame(maxWidth: .infinity)
	}
}
