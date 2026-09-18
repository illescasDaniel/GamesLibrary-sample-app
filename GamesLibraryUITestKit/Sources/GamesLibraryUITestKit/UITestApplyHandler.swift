import UIKit
import AccessibilityIdentifiers

@MainActor
public enum UITestApplyHandler {
	public static func configuration(from url: URL) -> UITestConfiguration? {
		guard url.scheme == UITestEnvironment.deepLinkScheme else { return nil }
		guard url.host == UITestEnvironment.applyHost else { return nil }
		if
			let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
			let encoded = components.queryItems?
				.first(where: { $0.name == UITestConfiguration.urlQueryConfigKey })?
				.value,
			let configuration = UITestConfiguration.decodeFromURLQueryValue(encoded)
		{
			return configuration
		}
		return configurationFromPasteboard()
	}

	public static func configurationFromPasteboard() -> UITestConfiguration? {
		if
			let named = UIPasteboard(name: .init(UITestEnvironment.pasteboardName), create: false)?.string,
			let configuration = UITestConfiguration.decodeIfPresent(fromLaunchEnvironmentValue: named)
		{
			return configuration
		}
		if
			let general = UIPasteboard.general.string,
			let configuration = UITestConfiguration.decodeIfPresent(fromLaunchEnvironmentValue: general)
		{
			return configuration
		}
		return nil
	}
}
