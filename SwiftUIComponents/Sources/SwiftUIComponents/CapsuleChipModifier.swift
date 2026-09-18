import SwiftUI

public struct CapsuleChipModifier: ViewModifier {
	public init() {}

	public func body(content: Content) -> some View {
		content
			.font(.footnote.monospaced())
			.fontWeight(.medium)
			.multilineTextAlignment(.center)
			.frame(alignment: .center)
			.padding(8)
			.background(
				Capsule()
					.fill(.quaternary)
			)
	}
}

public extension View {
	func capsuleChipStyle() -> some View {
		modifier(CapsuleChipModifier())
	}
}
