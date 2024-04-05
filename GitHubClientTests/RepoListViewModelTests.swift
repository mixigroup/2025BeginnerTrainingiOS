import XCTest
@testable import GitHubClient

@MainActor
class RepoListViewModelTests: XCTestCase {
    func test_onAppear_正常系() async {
        let viewModel = RepoListViewModel(
            repoAPIClient: MockRepoAPIClient(
                getRepos: { .mock }
            )
        )

        await viewModel.onAppear()

        switch viewModel.state {
        case let .loaded(repos):
            XCTAssertEqual(repos, .mock)
        default:
            XCTFail()
        }
    }

    func test_onAppear_異常系() async {
        let viewModel = RepoListViewModel(
            repoAPIClient: MockRepoAPIClient(
                getRepos: {
                    throw DummyError()
                }
            )
        )

        await viewModel.onAppear()

        switch viewModel.state {
        case let .failed(error):
            XCTAssert(error is DummyError)
        default:
            XCTFail()
        }
    }
}
