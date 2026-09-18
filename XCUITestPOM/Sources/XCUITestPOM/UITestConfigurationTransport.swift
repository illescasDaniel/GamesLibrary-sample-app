#if canImport(UIKit)
import UIKit
import AccessibilityIdentifiers

public enum UITestConfigurationTransport {
	public static func write(_ configuration: UITestConfiguration) {
		let json = configuration.encodeToLaunchEnvironmentValue()
		let named = UIPasteboard(
			name: .init(UITestEnvironment.pasteboardName),
			create: true
		)
		named?.string = json
		UIPasteboard.general.string = json
	}
}
#endif
