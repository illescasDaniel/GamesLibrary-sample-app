import Foundation

public protocol URLQueryEncodable {
	var queryItems: [URLQueryItem] { get }
}
