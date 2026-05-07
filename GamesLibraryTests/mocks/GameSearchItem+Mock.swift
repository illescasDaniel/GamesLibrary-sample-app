import Foundation
@testable import GamesLibrary

extension GameSearchItem {
	@MainActor
	static func dummy(id: Int = 1, name: String = "Test Game") -> GameSearchItem {
		let data = Data(#"{ "id": \#(id), "name": "\#(name)", "rating": 4.5 }"#.utf8)
		return try! JSONDecoder().decode(GameSearchItem.self, from: data)
	}
}
