//
//  String+.swift
//  GamesLibrary
//
//  Created by Daniel Illescas Romero on 8/5/26.
//

import Foundation
import UIKit

extension String {
	func strippingHTML() -> String {
		guard let data = self.data(using: .utf8) else { return self }

		let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
			.documentType: NSAttributedString.DocumentType.html,
			.characterEncoding: String.Encoding.utf8.rawValue
		]

		// Convert HTML data to an attributed string, then extract the plain text
		if let attributedString = try? unsafe NSAttributedString(data: data, options: options, documentAttributes: nil) {
			return attributedString.string.trimmingCharacters(in: .whitespacesAndNewlines)
		}

		return self
	}
}
