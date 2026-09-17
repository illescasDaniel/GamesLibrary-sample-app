import Foundation
import GamesLibraryCore

protocol GameDetailsDisplayable {
	var rating: Double? { get }
	var esrbRating: ESRBRating? { get }
	var released: String? { get }
	var playtime: Int? { get }
	var validDescription: String? { get }
	var backgroundImageURL: String? { get }
	var website: String? { get }
	var platforms: [PlatformInfo]? { get }
}

extension GameSummary: GameDetailsDisplayable {
	var validDescription: String? { nil }
	var website: String? { nil }
	var playtime: Int? { nil }
}

extension GameDetails: GameDetailsDisplayable {
	var validDescription: String? {
		if let raw = descriptionRaw?.trimmingCharacters(in: .whitespacesAndNewlines), !raw.isEmpty {
			return raw
		}
		return descriptionHTML?.trimmingCharacters(in: .whitespacesAndNewlines)
	}
}
