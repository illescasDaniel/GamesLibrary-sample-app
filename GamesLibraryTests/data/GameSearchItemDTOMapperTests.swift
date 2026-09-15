import Testing
import Foundation
import GamesLibraryCore
@testable import GamesLibrary

@Suite
@MainActor
struct GameSearchItemDTOMapperTests {

    @Test
    func givenDTOWhenMappedThenDomainEntityIsCorrect() {
        let dto = GameSearchItemDTO.dummy(id: 7, name: "Mapped Game")
        let domain = GameSearchItemDTOMapper.toDomain(dto)

        #expect(domain?.id == GameID(7))
        #expect(domain?.name == "Mapped Game")
        #expect(domain?.rating == 4.5)
    }

    @Test
    func givenDTOWithoutIdWhenMappedThenReturnsNil() throws {
        let data = Data(#"{ "name": "No ID" }"#.utf8)
        let dto = try JSONDecoder().decode(GameSearchItemDTO.self, from: data)
        #expect(GameSearchItemDTOMapper.toDomain(dto) == nil)
    }
}
