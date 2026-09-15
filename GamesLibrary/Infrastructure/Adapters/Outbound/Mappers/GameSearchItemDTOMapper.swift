import GamesLibraryCore

enum GameSearchItemDTOMapper {
    nonisolated static func toDomain(_ dto: GameSearchItemDTO) -> GameSummary? {
        guard let id = dto.id else { return nil }
        return GameSummary(
            id: GameID(id),
            name: dto.name,
            rating: dto.rating,
            released: dto.released,
            backgroundImageURL: dto.backgroundImage,
            esrbRating: dto.esrbRating.map(ESRBRatingDTOMapper.toDomain),
            platforms: dto.platforms?.compactMap { $0.platform?.name }.map { PlatformInfo(name: $0) }
        )
    }

    nonisolated static func toDomainList(_ dtos: [GameSearchItemDTO]) -> [GameSummary] {
        dtos.compactMap(toDomain)
    }
}
