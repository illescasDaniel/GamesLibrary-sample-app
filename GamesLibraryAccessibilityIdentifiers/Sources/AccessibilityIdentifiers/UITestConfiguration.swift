import Foundation

/// Launch-environment keys shared between UI tests and the DEBUG app entry.
public enum UITestEnvironment {
	/// JSON-encoded `UITestConfiguration` for deterministic DEBUG UI-test overrides.
	public static let configKey = "UITEST_CONFIG"
}

/// Scenario payload passed via `UITEST_CONFIG`. Add per-screen nested configs instead of new env keys.
public struct UITestConfiguration: Codable, Equatable, Sendable {
	public var gamesList: GamesList
	public var gameDetails: GameDetails

	public init(
		gamesList: GamesList = .init(),
		gameDetails: GameDetails = .init()
	) {
		self.gamesList = gamesList
		self.gameDetails = gameDetails
	}

	public static let `default` = UITestConfiguration()

	/// Games list screen stub knobs.
	public struct GamesList: Codable, Equatable, Sendable {
		public var emptyResults: Bool

		public init(emptyResults: Bool = false) {
			self.emptyResults = emptyResults
		}

		// If we ever need custom returned lists: add a Codable fixture type here
		// (keep Core/`GameSummary` out of this package), encode it in `UITEST_CONFIG`,
		// and map to the domain model inside DEBUG `UITestSupport` / stub use cases.
	}

	/// Game details screen stub knobs.
	public struct GameDetails: Codable, Equatable, Sendable {
		public var failuresRemaining: Int

		public init(failuresRemaining: Int = 0) {
			self.failuresRemaining = failuresRemaining
		}
	}

	public func encodeToLaunchEnvironmentValue() -> String {
		do {
			let encoder = JSONEncoder()
			encoder.outputFormatting = [.sortedKeys]
			let data = try encoder.encode(self)
			guard let string = String(data: data, encoding: .utf8) else {
				preconditionFailure("UITestConfiguration JSON was not UTF-8")
			}
			return string
		} catch {
			preconditionFailure("Failed to encode UITestConfiguration: \(error)")
		}
	}

	public static func decode(fromLaunchEnvironmentValue value: String) -> UITestConfiguration {
		guard let data = value.data(using: .utf8) else {
			preconditionFailure("UITEST_CONFIG was not UTF-8")
		}
		do {
			return try JSONDecoder().decode(UITestConfiguration.self, from: data)
		} catch {
			preconditionFailure("Failed to decode UITEST_CONFIG: \(error)")
		}
	}
}
