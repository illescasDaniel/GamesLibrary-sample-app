import AccessibilityIdentifiers
import ASTK
import ASTKXCTest

@MainActor
enum AppLauncher {
	private static let settings = UITestSessionSettings(
		deepLinkScheme: GamesLibraryUITestTransport.deepLinkScheme
	)

	private static let launcher = SharedProcessLauncher<UITestConfiguration, GamesListPage>(
		settings: settings,
		makeRootPage: GamesListPage.init,
		prepareForApply: { app in
			NavigationBarPopper.popTowardRoot(
				in: app,
				rootIdentifiers: [
					AccessibilityIdentifier.GamesList.screen,
					AccessibilityIdentifier.GamesList.emptyState,
				]
			)
		}
	)

	/// Launches the app once under shared-process UI testing (`UITESTING=1`).
	static func ensureLaunched() throws {
		_ = try launcher.ensureLaunched()
	}

	/// Applies a scenario without relaunching: pop to root, open DEBUG deep link with URL-encoded config, wait for ready marker.
	@discardableResult
	static func apply(
		configuration: UITestConfiguration = .default
	) async throws -> GamesListPage {
		try await launcher.apply(configuration: configuration)
	}

	/// Applies a scenario, taps the row at `index`, and returns the details page.
	static func applyGameDetails(
		index: Int = 0,
		configuration: UITestConfiguration = .default
	) async throws -> GameDetailsPage {
		let list = try await apply(configuration: configuration)
		return try await list.tapGameRow(at: index)
	}
}
