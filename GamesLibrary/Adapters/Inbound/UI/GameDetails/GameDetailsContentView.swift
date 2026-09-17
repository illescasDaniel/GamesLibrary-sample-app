import SwiftUI
import AccessibilityIdentifiers
import GamesLibraryCore

/// Scrollable details body composed of section views with narrow inputs.
struct GameDetailsContentView: View {
	let backgroundImageURL: String?
	let rating: Double?
	let releasedYear: String?
	let playtimeHours: Int?
	let esrbName: String?
	let platformNames: [String]
	let descriptionText: String?
	let websiteURL: URL?
	let loading: Bool

	init(gameDetails: any GameDetailsDisplayable, loading: Bool) {
		self.backgroundImageURL = gameDetails.backgroundImageURL
		self.rating = gameDetails.rating
		self.releasedYear = gameDetails.released.map { String($0.prefix(4)) }
		self.playtimeHours = gameDetails.playtime
		self.esrbName = gameDetails.esrbRating?.name
		self.platformNames = gameDetails.platforms?.compactMap(\.name) ?? []
		self.descriptionText = gameDetails.validDescription?.strippingHTML()
		self.websiteURL = gameDetails.website.flatMap(URL.init(string:))
		self.loading = loading
	}

	var body: some View {
		ScrollView(.vertical) {
			LazyVStack(alignment: .center, spacing: 16) {
				GameDetailsHeaderView(
					backgroundImageURL: backgroundImageURL,
					rating: rating,
					releasedYear: releasedYear,
					playtimeHours: playtimeHours,
					esrbName: esrbName,
					platformNames: platformNames
				)

				GameDetailsDescriptionView(
					descriptionText: descriptionText,
					loading: loading
				)

				if let websiteURL {
					Link("Visit Website", destination: websiteURL)
						.buttonStyle(.borderedProminent)
						.accessibilityIdentifier(AccessibilityIdentifier.GameDetails.websiteLink)
				}
			}
			.padding()
			Spacer()
		}
	}
}
