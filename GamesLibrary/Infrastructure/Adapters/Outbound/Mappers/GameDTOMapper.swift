import GamesLibraryCore

enum GameDTOMapper {
	nonisolated static func toDomain(_ dto: GameDTO) -> GameDetails? {
		guard let id = dto.id else { return nil }
		let summary = GameSummary(
			id: GameID(id),
			name: dto.name,
			rating: dto.rating,
			released: dto.released,
			backgroundImageURL: dto.backgroundImage,
			esrbRating: dto.esrbRating.map(ESRBRatingDTOMapper.toDomain),
			platforms: dto.platforms?.compactMap { $0.platform?.name }.map { PlatformInfo(name: $0) }
		)
		return GameDetails(
			summary: summary,
			descriptionHTML: dto.description,
			descriptionRaw: dto.rawDescription,
			website: dto.website,
			playtime: dto.playtime
		)
	}
}
