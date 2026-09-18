import Foundation

enum AppEnvironment {
	case production

	var baseURL: URL {
		switch self {
		case .production: URL(string: "https://api.rawg.io/api")!
		}
	}

	var apiKey: String {
		switch self {
		case .production:
			Secrets.apiKey
		}
	}
}
