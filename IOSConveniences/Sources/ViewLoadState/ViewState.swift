public enum ViewState<T, E: Error> {
	case success(T)
	case error(E)
	case loading
}
