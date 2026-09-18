import Foundation

extension String {
	/// Visible plain text from HTML: tags and comments removed, entities decoded.
	/// Foundation-only — does not use `NSAttributedString` / UIKit.
	public nonisolated func strippingHTML() -> String {
		HTMLTextStripper.strip(self)
	}
}

enum HTMLTextStripper {
	private static let blockTags: Set<String> = [
		"br", "p", "div", "li", "tr", "blockquote",
		"h1", "h2", "h3", "h4", "h5", "h6",
	]

	private static let namedEntities: [String: String] = [
		"amp": "&",
		"lt": "<",
		"gt": ">",
		"quot": "\"",
		"apos": "'",
		"nbsp": " ",
		"ndash": "–",
		"mdash": "—",
		"hellip": "…",
		"copy": "©",
		"reg": "®",
		"trade": "™",
		"lsquo": "‘",
		"rsquo": "’",
		"ldquo": "“",
		"rdquo": "”",
	]

	static func strip(_ html: String) -> String {
		var result = ""
		result.reserveCapacity(html.count)
		var index = html.startIndex
		var skippingUntil: String?

		while index < html.endIndex {
			if html[index] == "<" {
				if html[index...].hasPrefix("<!--") {
					if let end = html[index...].range(of: "-->") {
						index = end.upperBound
					} else {
						break
					}
					continue
				}

				guard let tagEnd = html[index...].firstIndex(of: ">") else {
					break
				}
				let tagContent = html[html.index(after: index)..<tagEnd]
				let (name, isClosing) = parseTag(tagContent)
				index = html.index(after: tagEnd)

				if let skip = skippingUntil {
					if isClosing && name == skip {
						skippingUntil = nil
					}
					continue
				}

				if name == "script" || name == "style" {
					if !isClosing {
						skippingUntil = name
					}
					continue
				}

				if blockTags.contains(name), !result.isEmpty, !result.hasSuffix("\n") {
					result.append("\n")
				}
				continue
			}

			if skippingUntil != nil {
				html.formIndex(after: &index)
				continue
			}

			if html[index] == "&" {
				let (decoded, next) = decodeEntity(in: html, from: index)
				result.append(decoded)
				index = next
				continue
			}

			result.append(html[index])
			html.formIndex(after: &index)
		}

		return normalizeWhitespace(result)
	}

	private static func parseTag(_ content: Substring) -> (name: String, isClosing: Bool) {
		var remainder = content.drop(while: \.isWhitespace)
		var isClosing = false
		if remainder.first == "/" {
			isClosing = true
			remainder = remainder.dropFirst().drop(while: \.isWhitespace)
		}
		if remainder.first == "!" || remainder.first == "?" {
			return ("", false)
		}
		let name = remainder.prefix(while: { $0.isLetter || $0.isNumber }).lowercased()
		return (name, isClosing)
	}

	private static func decodeEntity(in html: String, from start: String.Index) -> (String, String.Index) {
		let afterAmp = html.index(after: start)
		guard afterAmp < html.endIndex else {
			return ("&", afterAmp)
		}

		guard let semicolon = html[afterAmp...].firstIndex(of: ";") else {
			return ("&", afterAmp)
		}

		let body = html[afterAmp..<semicolon]
		if body.isEmpty || body.contains(where: { $0.isWhitespace || $0 == "&" || $0 == "<" }) {
			return ("&", afterAmp)
		}

		let next = html.index(after: semicolon)
		if let decoded = entityValue(body) {
			return (decoded, next)
		}
		return (String(html[start...semicolon]), next)
	}

	private static func entityValue(_ body: Substring) -> String? {
		if body.first == "#" {
			let numeric = body.dropFirst()
			let value: UInt32?
			if numeric.first == "x" || numeric.first == "X" {
				value = UInt32(numeric.dropFirst(), radix: 16)
			} else {
				value = UInt32(numeric, radix: 10)
			}
			guard let value, let scalar = UnicodeScalar(value), scalar != "\0" else {
				return nil
			}
			return String(Character(scalar))
		}
		return namedEntities[String(body).lowercased()]
	}

	private static func normalizeWhitespace(_ text: String) -> String {
		let lines = text.split(omittingEmptySubsequences: false, whereSeparator: \.isNewline)
			.map { line in
				line.split(whereSeparator: \.isWhitespace).joined(separator: " ")
			}
		let trimmed = lines
			.drop(while: \.isEmpty)
			.reversed()
			.drop(while: \.isEmpty)
			.reversed()
		return trimmed.joined(separator: "\n")
	}
}
