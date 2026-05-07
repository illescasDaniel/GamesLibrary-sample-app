import Foundation
@testable import GamesLibrary

extension GamesOutput {
	@MainActor
	static func dummy(results: [GameSearchItem]) -> GamesOutput {
		let resultsJson = results.map {
			#"{ "id": \#($0.id ?? 0), "name": "\#($0.name ?? "")", "rating": \#($0.rating ?? 0.0) }"#
		}.joined(separator: ",")
		let data = Data(#"{ "count": \#(results.count), "results": [\#(resultsJson)] }"#.utf8)
		return try! JSONDecoder().decode(GamesOutput.self, from: data)
	}
}
