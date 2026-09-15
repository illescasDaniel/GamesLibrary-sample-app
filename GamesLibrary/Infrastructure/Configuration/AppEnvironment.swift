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
            guard
                let filePath = Bundle.main.path(forResource: "Info", ofType: "plist"),
                let plist = NSDictionary(contentsOfFile: filePath),
                let value = plist["API_KEY"] as? String
            else {
                fatalError("API Key not found in Info.plist")
            }
            return value
        }
    }
}
