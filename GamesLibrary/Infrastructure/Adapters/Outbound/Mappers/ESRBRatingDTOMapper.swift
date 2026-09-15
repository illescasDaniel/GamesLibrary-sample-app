import GamesLibraryCore

enum ESRBRatingDTOMapper {
    nonisolated static func toDomain(_ dto: ESRBRatingDTO) -> ESRBRating {
        ESRBRating(id: dto.id, slug: dto.slug, name: dto.name)
    }
}
