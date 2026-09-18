import SwiftUI

struct LoadingView: View {
	let title: LocalizedStringResource

	init(_ title: LocalizedStringResource) {
		self.title = title
	}

	init() {
		self.title = LocalizedStringResource(
			"Loading...",
			comment: "Loading overlay shown while content is fetching."
		)
	}

	var body: some View {
		ProgressView {
			Text(title)
		}
			.controlSize(.regular)
			.padding(24)
			.background(.ultraThinMaterial)
			.foregroundColor(.primary)
			.clipShape(RoundedRectangle(cornerRadius: 16))
			.overlay(
				RoundedRectangle(cornerRadius: 16)
					.stroke(
						LinearGradient(
							colors: [.white.opacity(0.6), .clear, .white.opacity(0.2)],
							startPoint: .topLeading,
							endPoint: .bottomTrailing
						),
						lineWidth: 1.5
					)
			)
			.shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 4)
	}
}
