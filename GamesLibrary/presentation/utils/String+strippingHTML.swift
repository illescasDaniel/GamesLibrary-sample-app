//
//  String+.swift
//  GamesLibrary
//
//  Created by Daniel Illescas Romero on 8/5/26.
//

import Foundation

extension String {
	func strippingHTML() -> String {
		// Use Regex to find and remove anything between < and >
		// The pattern "<[^>]+>" means: match '<', then any character that is NOT '>', 1 or more times, then '>'
		let strippedString = self.replacingOccurrences(
			of: "<[^>]+>",
			with: "",
			options: .regularExpression,
			range: nil
		)

		return strippedString
			.replacingOccurrences(of: "&amp;", with: "&")
			.replacingOccurrences(of: "&lt;", with: "<")
			.replacingOccurrences(of: "&gt;", with: ">")
			.replacingOccurrences(of: "&quot;", with: "\"")
			.replacingOccurrences(of: "&#39;", with: "'")
			.replacingOccurrences(of: "&nbsp;", with: " ")
			.trimmingCharacters(in: .whitespacesAndNewlines)
	}
}
