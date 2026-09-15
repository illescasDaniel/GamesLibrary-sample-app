import Testing
import Foundation
import GamesLibraryCore
@testable import GamesLibrary

@Suite
@MainActor
struct GameDTOMapperTests {

	@Test
	func givenDTOWhenMappedThenDomainEntityIsCorrect() throws {
		let json = """
		{
			"id": 42,
			"name": "Full Game",
			"rating": 4.8,
			"description": "<p>HTML desc</p>",
			"description_raw": "Raw desc",
			"website": "https://example.com",
			"playtime": 10,
			"platforms": [{ "platform": { "name": "PC" } }]
		}
		"""
		let dto = try JSONDecoder().decode(GameDTO.self, from: Data(json.utf8))
		let domain = GameDTOMapper.toDomain(dto)

		#expect(domain?.id == GameID(42))
		#expect(domain?.name == "Full Game")
		#expect(domain?.descriptionRaw == "Raw desc")
		#expect(domain?.descriptionHTML == "<p>HTML desc</p>")
		#expect(domain?.website == "https://example.com")
		#expect(domain?.playtime == 10)
		#expect(domain?.platforms?.first?.name == "PC")
	}

	@Test
	func givenDTOWithoutIdWhenMappedThenReturnsNil() throws {
		let json = #"{"name": "No ID"}"#
		let dto = try JSONDecoder().decode(GameDTO.self, from: Data(json.utf8))

		#expect(GameDTOMapper.toDomain(dto) == nil)
	}
}
