import Foundation

struct MockRepoAPIClient: RepositoryHandling {
    var getRepos: @Sendable () async throws -> [Repo]

    func getRepos() async throws -> [Repo] {
        try await getRepos()
    }
}
