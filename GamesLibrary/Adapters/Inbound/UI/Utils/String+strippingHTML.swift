import Foundation
import UIKit

extension String {
	nonisolated func strippingHTML() -> String {
		guard let data = data(using: .utf8) else { return self }
		let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
			.documentType: NSAttributedString.DocumentType.html,
			.characterEncoding: String.Encoding.utf8.rawValue,
		]
		guard
			let attributed = try? unsafe NSAttributedString(data: data, options: options, documentAttributes: nil)
		else {
			return self
		}
		return attributed.string
	}
}
