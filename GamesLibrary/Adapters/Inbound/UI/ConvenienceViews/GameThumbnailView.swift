import SwiftUI
import OptimizedAsyncImage

/// Shared cover thumbnail with an independent invalidation boundary.
struct GameThumbnailView: View {
	enum EmptyAppearance {
		case hidden
		case photoPlaceholder
	}

	let urlString: String?
	let size: CGFloat
	let emptyAppearance: EmptyAppearance

	var body: some View {
		if let url = urlString.flatMap(URL.init) {
			OptimizedAsyncImage(url: url, targetSize: CGSize(width: size, height: size)) { phase in
				switch phase {
				case .empty:
					ZStack {
						Color.gray.opacity(0.2)
						ProgressView()
					}
					.frame(width: size, height: size)
					.cornerRadius(8)
				case .success(let image):
					image
						.resizable()
						.aspectRatio(contentMode: .fill)
						.frame(width: size, height: size)
						.clipped()
						.cornerRadius(8)
				case .failure:
					emptyView
				@unknown default:
					EmptyView()
				}
			}
		} else {
			emptyView
		}
	}

	@ViewBuilder
	private var emptyView: some View {
		switch emptyAppearance {
		case .hidden:
			EmptyView()
		case .photoPlaceholder:
			Image(systemName: "photo")
				.foregroundColor(.gray)
				.frame(width: size, height: size)
				.background(Color.gray.opacity(0.1))
				.cornerRadius(8)
		}
	}
}
