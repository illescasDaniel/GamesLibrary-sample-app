import SwiftUI

struct AppRootView: View {
	@Bindable var coordinator: AppCoordinator

	var body: some View {
		GamesNavigationView()
			.environment(coordinator)
	}
}
