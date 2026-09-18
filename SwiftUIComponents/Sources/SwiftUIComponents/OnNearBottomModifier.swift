import SwiftUI

public extension View {
	/// Fires `action` when the scroll view crosses within `threshold` points of the bottom.
	func onNearBottom(
		threshold: CGFloat = 100,
		action: @escaping () -> Void
	) -> some View {
		onScrollGeometryChange(for: Bool.self) { geometry in
			guard geometry.contentSize != .zero else { return false }
			let distanceFromBottom = geometry.contentSize.height
				- geometry.contentOffset.y
				- geometry.containerSize.height
			return distanceFromBottom < threshold
		} action: { wasNearBottom, isNearBottom in
			if isNearBottom && !wasNearBottom {
				action()
			}
		}
	}
}
