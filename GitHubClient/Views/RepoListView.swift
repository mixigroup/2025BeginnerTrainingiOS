import SwiftUI
import Observation

@MainActor
@Observable
class ReposStore {
    private(set) var state: Stateful<[Repo]> = .loading

    func loadRepos() async {
        state = .loading

        let url = URL(string: "https://api.github.com/orgs/mixigroup/repos")!

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.allHTTPHeaderFields = [
            "Accept": "application/vnd.github+json"
        ]
        // GitHub API のリクエスト数制限(60回/h)回避のためのキャッシュ設定
        urlRequest.cachePolicy = .returnCacheDataElseLoad

        do {
            let (data, response) = try await send(urlRequest: urlRequest)

            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let value = try decoder.decode([Repo].self, from: data)

            state = .loaded(value)
        } catch {
            state = .failed(error)
        }
    }

    private nonisolated func send(urlRequest: URLRequest) async throws -> (Data, URLResponse) {
        try await URLSession.shared.data(for: urlRequest)
    }
}

struct RepoListView: View {
    @State var reposStore: ReposStore

    var body: some View {
        NavigationView {
            Group {
                switch reposStore.state {
                case .loading:
                    ProgressView("loading...")
                case let .loaded(repos):
                    List(repos) { repo in
                        NavigationLink(destination: RepoDetailView(repo: repo)) {
                            RepoRow(repo: repo)
                        }
                    }
                case .failed:
                    VStack {
                        Text("Failed to load repositories")
                        Button(
                            action: {
                                Task {
                                    await reposStore.loadRepos()
                                }
                            },
                            label: {
                                Text("Retry")
                            }
                        )
                        .padding()
                    }
                }
            }
            .navigationTitle("Repositories")
        }
        .task {
            await reposStore.loadRepos()
        }
    }
}

#Preview {
    RepoListView(reposStore: ReposStore())
}
