import SwiftUI

struct CapsuleChipModifier: ViewModifier {
	func body(content: Content) -> some View {
		content
			.font(.footnote.monospaced())
			.fontWeight(.medium)
			.multilineTextAlignment(.center)
			.frame(alignment: .center)
			.padding(8)
			.background(
				Capsule()
					.fill(Color(.systemGray6))
			)
	}
}

extension View {
	func capsuleChipStyle() -> some View {
		modifier(CapsuleChipModifier())
	}
}
