import Observation

@Observable
@MainActor
final class ReposStore {
    enum Action {
        case onAppear
        case onRetryButtonTapped
    }

    private(set) var state: Stateful<[Repo]> = .loading

    private let apiClient: any RepositoryHandling

    init(apiClient: any RepositoryHandling) {
        self.apiClient = apiClient
    }

    func send(_ action: Action) async {
        switch action {
        case .onAppear, .onRetryButtonTapped:
            state = .loading

            do {
                let repos = try await apiClient.getRepos()
                state = .loaded(repos)
            } catch {
                state = .failed(error)
            }
        }
    }
}
