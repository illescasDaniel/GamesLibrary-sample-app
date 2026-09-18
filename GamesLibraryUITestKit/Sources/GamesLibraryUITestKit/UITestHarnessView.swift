import SwiftUI
import AccessibilityIdentifiers

/// DEBUG overlay: ready marker + manual apply trigger (pasteboard fallback).
public struct UITestHarnessView: View {
	public let sessionGeneration: Int

	public init(sessionGeneration: Int) {
		self.sessionGeneration = sessionGeneration
	}

	public var body: some View {
		VStack(alignment: .leading, spacing: 0) {
			Text(verbatim: "ready")
				.font(.system(size: 1))
				.opacity(0.01)
				.frame(width: 1, height: 1)
				.accessibilityElement()
				.accessibilityIdentifier(
					AccessibilityIdentifier.UITest.ready(sessionGeneration: sessionGeneration)
				)
			Button {
				UITestRuntime.applyPendingConfiguration()
			} label: {
				Text(verbatim: "apply")
			}
			.font(.system(size: 1))
			.opacity(0.01)
			.frame(width: 44, height: 44)
			.accessibilityIdentifier(AccessibilityIdentifier.UITest.applyTrigger)
		}
		.allowsHitTesting(true)
	}
}
