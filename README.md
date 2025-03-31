## 3.3. Xcode Previewsの再活用
- しばらくXcode Previewsでデバッグしてきましたが、エラー表示などを確認するためにコメントアウトしたりコードを書き換えたりしていました
- もっとPreviewをうまく活用してこのような非効率的な確認方法を取らずに済むようにしていきましょう
- まずは、テストファイルに定義したモックをPreviewでも再利用するために `Preview Content/Mocks` 以下に移動させましょう

```swift
// Preview Content/Mocks/DummyError.swift
import Foundation

struct DummyError: Error {}
```

```swift
// Preview Content/Mocks/MockRepoAPIClient.swift
import Foundation

struct MockRepoAPIClient: RepositoryHandling {
    var getRepos: @Sendable () async throws -> [Repo]

    func getRepos() async throws -> [Repo] {
        try await getRepos()
    }
}
```
- 次に、`ReposStore`のイニシャライザ引数のデフォルト値として `RepoAPIClient()` をセットしていましたが、これを機にReposStoreのインスタンスを作る度に明示的に`RepositoryHandling`に準拠したインスタンスを渡す形に変更しましょう
```diff 
     private let apiClient: any RepositoryHandling
 
-    init(apiClient: any RepositoryHandling = RepoAPIClient()) {
+    init(apiClient: any RepositoryHandling) {
         self.repoAPIClient = repoAPIClient
     }
```
- また、`RepoListView`に`ReposStore`をDependency Injectionするため、初期値を削除しておきます

```diff
struct RepoListView: View {
-    @State var store = ReposStore()
+    @State var store: ReposStore
```

- アプリ起動時にRepoListViewを生成する際は、本物のAPIClientを渡してあげます
```swift
struct GitHubClientApp: App {
    var body: some Scene {
        WindowGroup {
            RepoListView(
                store: ReposStore(
                    apiClient: RepoAPIClient()
                )
            )
        }
    }
}
```

- Previewでは、初期化時にモックされたAPIClientを渡してあげましょう
- これにより、Previewを表示する度にAPI通信が行う必要がなくなりました。
```swift
#Preview {
    RepoListView(
        store: ReposStore(
            apiClient: MockRepoAPIClient(
                getRepos: {
                    [.mock1, .mock2, .mock3, .mock4, .mock5]
                }
            )
        )
    )
}
```

- Live Previewで期待通り表示されるか確認してみましょう
    
### チャレンジ
- エラー状態、読み込み状態のRepoListViewのPreviewをそれぞれ実装してください
- 各Previewは、 `#Preview("Default") {...}` などと、[init(_:traits:body:)](https://developer.apple.com/documentation/developertoolssupport/preview/init(_:traits:body:)-8pemr) の第一引数に名前をつけて表示することが可能です
- 読み込み状態のPreviewは、例えば以下のように値を何も返さない[AsyncStream](https://developer.apple.com/documentation/swift/asyncstream)を使用してasyncなfunctionを定義することで実現可能です。
  ```swift
  // Utilities/に`Task+never.swift`として以下を定義する
  extension Task {
      static func never() async throws -> Success where Failure == Never {
          let stream = AsyncStream<Success> { _ in }
          for await element in stream {
              return element
          }
          throw _Concurrency.CancellationError()
      }
  }

  // 使い方
  try await Task.never()
  ```

<details>
    <summary>解説</summary>


#### エラー状態のPreview
RepoListViewを追加して、MockRepoAPIClientのerrorに`DummyError()`を渡すことで実現可能です。

```swift
#Preview("Error") {
    RepoListView(
        store: ReposStore(
            apiClient: MockRepoAPIClient(
                getRepos: {
                    throw DummyError()
                }
            )
        )
    )
}
```

Previewの上部にErrorというタブが表示されました、これをクリックすればエラー状態のPreviewを確認することができます

<img src="https://user-images.githubusercontent.com/17004375/234429326-f8a275c4-3f92-409a-9562-61998df9fb95.png" width="300" />

#### 読み込み状態のPreview
上述のTask.never()を使うことで実現可能です。
```swift
#Preview("Loading") {
    RepoListView(
        store: ReposStore(
            apiClient: MockRepoAPIClient(
                getRepos: {
                    try await Task.never()
                }
            )
        )
    )
}
```

</details>

### 前セッションとのDiff
[session-3.2..session-3.3](https://github.com/mixigroup/ios-swiftui-training/compare/session-3.2..session-3.3)

## Next
To be continued...
