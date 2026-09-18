import Foundation
import AccessibilityIdentifiers

@MainActor
public enum UITestApplyHandler {
	public static func configuration(from url: URL) -> UITestConfiguration? {
		guard url.scheme == UITestEnvironment.deepLinkScheme else { return nil }
		guard url.host == UITestEnvironment.applyHost else { return nil }
		guard
			let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
			let encoded = components.queryItems?
				.first(where: { $0.name == UITestConfiguration.urlQueryConfigKey })?
				.value
		else {
			return nil
		}
		return UITestConfiguration.decodeFromURLQueryValue(encoded)
	}
}
