## 3.2. Swift Testing
- 責務の分離を施したことによるメリットとして、各クラスをテストしやすくなったという点があります
- `ReposStore` のテストを書いてみましょう
- テストしたい項目は以下の通りです
    - Viewが表示されたとき(onAppear actionを受け取ったとき)にリポジトリ一覧を取得して表示する
    - 取得時にエラーが発生した場合にはstateには`.failed`がセットされていること
- iOSでテストを書くために、まずはTest Targetを下図のように追加してみましょう

<img src="https://user-images.githubusercontent.com/8536870/115539731-49d0fa00-a2d8-11eb-85a0-87ec3b6548c0.png">

- `GitHubClientTests.swift` というテストファイルがすでに追加されているはずなので、 `ReposStoreTests` にrenameしましょう
- `@Test` を付けたメソッドがテストケースとして認識されて実行されます
- まずは、「リポジトリ一覧が正常に読み込まれること」をテストするメソッドを追加しましょう

```swift
@testable import GitHubClient

struct ReposStoreTests {
    @Test func onAppear_正常系() async {
    }
}
```

- テストターゲットからメインターゲットのメソッドやクラスを参照するために `@testable import GitHubClient` を宣言しています
    - 本来ならばpublicで修飾されていなければ外部ターゲットのフィールドにはアクセスできませんが、 `@testable import` によってinternalなフィールドにもアクセス可能になります
- テストメソッド内で async な関数 `ReposStore`の`send(.onAppear)` を呼び出したいので、あらかじめテストメソッドに `async` を付与します
- まずはテストメソッド内で、テスト対象の `ReposStore` を初期化し、`send(.onAppear)` を呼び出してリポジトリが読み込まれるか確認...
- と、このままだとテストを走らせるたびにAPI通信が走ってしまいます
- 常套手段として、 `ReposStore` が依存している `RepoAPIClient` をモックに差し替えましょう
- そのためには、以下の2つのことをしてあげる必要があります
    - 現在メソッド内で初期化されている `RepoAPIClient` を外から渡す (Dependency Injection)
    - `RepoAPIClient` のインターフェースを抽象化したprotocolを`ReposStore`のイニシャライザ引数とする

```swift
protocol RepositoryHandling: Sendable {
    func getRepos() async throws -> [Repo]
}

struct RepoAPIClient: RepositoryHandling {
    func getRepos() async throws -> [Repo] {
        ...
    }
}
```

- Sendableは、Swift Concurrencyにおいてタスク間で値を安全にやり取りできることを保証するための仕組みです。
- 本セッションではテストの内容がメインなので、ここでのSendableの解説は簡単な説明に留めています。Sendableについてさらに詳しく知りたい方は、[補足資料](https://github.com/mixigroup/ios-swiftui-training/edit/session-3.2/README.md#%E8%A3%9C%E8%B6%B3%E8%B3%87%E6%96%99)をご参照ください。 

```swift
@Observable
@MainActor
final class ReposStore {
    enum Action {
        case onAppear
        case onRetryButtonTapped
    }

    private(set) var state: Stateful<[Repo]> = .loading

    private let apiClient: any RepositoryHandling

    init(apiClient: any RepositoryHandling = RepoAPIClient()) {
        self.apiClient = apiClient
    }
    ...
    func send(_ action: Action) async {
        ...
        do {
            let repos = try await repoAPIClient.getRepos()
        ...
    }
}
```

- `any` キーワードについてもテストの主題から逸れるため、詳細な解説は省略します。詳しく知りたい方は[補足資料](https://github.com/mixigroup/ios-swiftui-training/edit/session-3.2/README.md#%E8%A3%9C%E8%B6%B3%E8%B3%87%E6%96%99)をご参照ください。

- これで `RepoAPIClient` をモックに差し替える準備が整いました、早速モックを作ってみましょう

```swift
struct ReposStoreTests {
    ...
    
    struct MockRepoAPIClient: RepositoryHandling {
        var getRepos: @Sendable () async throws -> [Repo]

        func getRepos() async throws -> [Repo] {
            try await getRepos()
        }
    }
}
```

- このモックのポイントは以下になります。
    - イニシャライザの引数で、`getRepos()`を呼び出したときのふるまいを定義する
    - `getRepos()` ではイニシャライザ引数で受け取った値をそのまま返す

- では、モックを使って実際にテストを書いていきましょう
- Viewに反映されるデータは `ReposStore.state` です、テストメソッドでもこの値を監視して想定通りに更新されていることを確認します

```swift
struct ReposStoreTests {
    @Test func onAppear_正常系() async {
        let store = ReposStore(
            apiClient: MockRepoAPIClient(
                getRepos: { [.mock1, .mock2] }
            )
        )

        await store.send(.onAppear)

        switch store.state {
        case let .loaded(repos):
            #expect(repos == [.mock1, .mock2])
        default:
            Issue.record("state should be `.loaded`")
        }
    }
    
    ...
}
```

- 順番に見ていきましょう
- `await store.send(.onAppear)` を呼び出し、Viewの`onAppear(_:)` が呼ばれたことをシミュレートし、リポジトリ情報の取得を開始しその結果を待ちます
- `sned(.onAppear)` が完了すると await より下に書かれたコードが実行され、 `store.state` に対する検証が行われます
- `⌘ + U` でテストが通ることを確認しましょう

### チャレンジ
- 異常系のテストを書いてみましょう
- 適当なエラーは以下のように定義することが可能です

```swift
struct DummyError: Error {}
let dummyError = DummyError()
```

<details>
    <summary>解説</summary>

正常系のテストと同じ要領でテストを書いていきます

```swift
@Test func onAppear_異常系() async {
    let store = ReposStore(
        aPIClient: MockRepoAPIClient(
            getRepos: { throw DummyError() }
        )
    )

    await store.send(.onAppear)

    switch store.state {
    case let .failed(error):
        #expect(error is DummyError)
    default:
        Issue.record("state should be `.failed`")
    }
}
```

テストが通ることが確認できれば完了です

</details>

### 補足資料
<details>
    <summary>Sendableについて</summary>

**Sendable** は、Swift Concurrencyで「複数の並行タスク間を安全に受け渡せる値」であることを示すためのプロトコルです。
Swiftでは、並行処理によるデータ競合やメモリ破壊を防ぐために「並行安全」であることをコンパイラに保証させる仕組みとして、型が `Sendable` に準拠しているかどうかを静的チェックする機能が導入されています。

- `Sendable` に準拠すると「この型は並行処理の境界を越えても安全に扱える」というコンパイラのお墨付きが得られ、並行処理上で安心してやり取りできるようになります。
- もし、内部に並行安全ではないプロパティを含んでいる場合は、コンパイラから警告やエラーが出るため、誤った使用を防止できます。

今回の例では、`ReposStore` が並行処理(タスク/actorの境界など)をまたいで `RepoAPIClient` を扱う可能性があるため、そのプロトコルを `Sendable` にしておくことでコンパイラに安全性を保証させています。

Sendableについてさらに詳しく理解したい方は、[Swift Concurrency - Sendable Types](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency/#Sendable-Types) を読んでみるとより理解が深められると思います。

</details>

<details>
    <summary>`any` キーワードについて</summary>

- Swift 5.6以降、protocolを型として利用する際に、その型が存在型であることを明示するため、`any` キーワードが導入されました。
- 存在型とは、あるプロトコルに準拠する任意の型の値を保持できる型のことです。  `any` を使用することで、変数や定数が具体的な型ではなく、プロトコルに準拠する任意の型を表すことを明確に示すことができます。
- 例えば、以下のコードは `RepositoryHandling` プロトコルに準拠する任意の型（存在型）を保持できることを示しています。

```swift
private let repoAPIClient: any RepositoryHandling = RepoAPIClient()
```
- この記述により、repoAPIClientがRepositoryHandlingに準拠する存在型であることが明確になり、コードの意図がより分かりやすくなります。
- 従来は `any` を省略しても動作していましたが、将来的には明示的に `any` を記述することが必須となる可能性があるため、早めにこの構文に慣れておきましょう。
</details>

### 前セッションとのDiff
[session-3.1..session-3.2](https://github.com/mixigroup/ios-swiftui-training/compare/session-3.1..session-3.2)

## Next
[3.3. Xcode Previewsの再活用](https://github.com/mixigroup/ios-swiftui-training/tree/session-3.3/README.md)
