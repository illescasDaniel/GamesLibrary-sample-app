import SwiftUI
import OptimizedAsyncImage
import GamesLibraryCore
import BetterLogger

struct GameDetailsView: View {
    @Bindable var viewModel: GameDetailsViewModel
    let summary: GameSummary

    var body: some View {
        contentState
            .navigationTitle(summary.name ?? "Game Details")
            .navigationBarTitleDisplayMode(.inline)
            .accessibilityIdentifier(AccessibilityIdentifier.GameDetails.screen)
            .task {
                await viewModel.getGameDetails(id: summary.id)
            }
    }

    @ViewBuilder
    private var contentState: some View {
        switch viewModel.gamesState {
        case .success(let game):
            contentView(gameDetails: game, loading: false)
        case .error:
            ContentUnavailableView {
                Text("An error ocurred. Try again")
            } actions: {
                Button("Retry") {
                    Task { await viewModel.getGameDetails(id: summary.id) }
                }
                .buttonStyle(.glassProminent)
            }
        case .loading:
            ZStack {
                contentView(gameDetails: summary, loading: true)
                LoadingView("Loading full details")
            }
        }
    }

    @ViewBuilder
    private func contentView(gameDetails: any GameDetailsDisplayable, loading: Bool) -> some View {
        ScrollView(.vertical) {
            LazyVStack(alignment: .center, spacing: 16) {
                HStack(alignment: .top) {
                    asyncImage(for: gameDetails.backgroundImageURL)
                    Spacer()
                    VStack(alignment: .trailing) {
                        HStack {
                            Group {
                                if let rating = gameDetails.rating, rating > 0 {
                                    Text(verbatim: rating.formatted(.number.precision(.fractionLength(1))) + " ⭐")
                                }
                                if let releaseDate = gameDetails.released?.prefix(4) {
                                    Text(verbatim: String(releaseDate))
                                }
                                if let playtime = gameDetails.playtime, playtime > 0 {
                                    Text(verbatim: String("\(playtime)h"))
                                }
                            }
                            .capsuleChipStyle()
                        }

                        HStack {
                            Group {
                                if let esbrRating = gameDetails.esrbRating?.name {
                                    Label(esbrRating, systemImage: "number.square")
                                }
                            }
                            .capsuleChipStyle()
                        }

                        ScrollView(.horizontal) {
                            LazyHStack {
                                Group {
                                    let platforms = gameDetails.platforms?.compactMap(\.name) ?? []
                                    ForEach(platforms, id: \.self) { platform in
                                        Text(platform)
                                            .environment(\.layoutDirection, .leftToRight)
                                    }
                                }
                                .capsuleChipStyle()
                            }
                        }
                        .environment(\.layoutDirection, .rightToLeft)
                    }
                    .padding(.vertical, 8)
                }
                .frame(maxWidth: .infinity)

                Text("Description")
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 8)

                if let description = gameDetails.validDescription?.strippingHTML() {
                    Text(verbatim: description)
                        .font(.body)
                } else if loading {
                    Text(verbatim: String(repeating: " ", count: 200))
                        .redacted(reason: .placeholder)
                } else {
                    Text(verbatim: "(No available description)")
                        .font(.body)
                }

                if let website = gameDetails.website.flatMap({ URL(string: $0) }) {
                    Link("Visit Website", destination: website)
                        .buttonStyle(.borderedProminent)
                }
            }
            .padding()
            Spacer()
        }
    }

    @ViewBuilder
    private func asyncImage(for image: String?) -> some View {
        if let url = image.flatMap(URL.init) {
            OptimizedAsyncImage(url: url, targetSize: CGSize(width: 128, height: 128)) { phase in
                switch phase {
                case .empty:
                    ZStack {
                        Color.gray.opacity(0.2)
                        ProgressView()
                    }
                    .frame(width: 128, height: 128)
                    .cornerRadius(8)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 128, height: 128)
                        .clipped()
                        .cornerRadius(8)
                case .failure:
                    EmptyView()
                @unknown default:
                    EmptyView()
                }
            }
        } else {
            EmptyView()
        }
    }
}

#Preview {
    let summary = GameSummary(id: GameID(1), name: "Preview Game", rating: 4.2, released: "2020-01-01")
    let mock = PreviewMockGetGameDetailsUseCase(result: .success(
        GameDetails(summary: summary, descriptionRaw: "A great game.")
    ))
    return GameDetailsView(
        viewModel: GameDetailsViewModel(
            getGameDetails: mock,
            logger: BetterLogger(name: "Preview")
        ),
        summary: summary
    )
}

private struct PreviewMockGetGameDetailsUseCase: GetGameDetailsUseCasePort {
    let result: Result<GameDetails, any Error>
    func callAsFunction(id: GameID) async throws -> GameDetails {
        try result.get()
    }
}
