public enum ListViewState: Equatable {
	case success(isEmpty: Bool)
	case error
	case loading
}
