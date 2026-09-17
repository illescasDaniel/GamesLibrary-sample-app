protocol AppContaining: AnyObject {
	func makeGamesListViewModel() -> GamesListViewModel
	func makeGameDetailsViewModel() -> GameDetailsViewModel
}
