import Foundation

extension UITestConfiguration {
	/// Query item carrying base64url-encoded JSON on `gameslibrary-uitest://apply`.
	public static let urlQueryConfigKey = "config"

	public func encodeToURLQueryValue() -> String {
		let json = encodeToLaunchEnvironmentValue()
		return Data(json.utf8)
			.base64EncodedString()
			.replacingOccurrences(of: "+", with: "-")
			.replacingOccurrences(of: "/", with: "_")
			.replacingOccurrences(of: "=", with: "")
	}

	public static func decodeFromURLQueryValue(_ value: String) -> UITestConfiguration? {
		var base64 = value
			.replacingOccurrences(of: "-", with: "+")
			.replacingOccurrences(of: "_", with: "/")
		let padding = (4 - base64.count % 4) % 4
		base64.append(String(repeating: "=", count: padding))
		guard
			let data = Data(base64Encoded: base64),
			let json = String(data: data, encoding: .utf8)
		else {
			return nil
		}
		return decodeIfPresent(fromLaunchEnvironmentValue: json)
	}

	public func makeApplyDeepLinkURL() -> URL {
		var components = URLComponents()
		components.scheme = UITestEnvironment.deepLinkScheme
		components.host = UITestEnvironment.applyHost
		components.queryItems = [
			URLQueryItem(name: Self.urlQueryConfigKey, value: encodeToURLQueryValue()),
		]
		guard let url = components.url else {
			preconditionFailure("Failed to build UI test apply deep link")
		}
		return url
	}
}
