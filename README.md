## 1.0 前準備
- 前準備として、これから実装を追加していくプロジェクトファイルを作成します
- まずはXcodeを開いてください
- 下図のようなウィンドウが開くので `Create New project...` から新規にプロジェクトを作成してください

<img width="786" alt="スクリーンショット 2024-04-20 23 42 53" src="https://github.com/mixigroup/ios-swiftui-training/assets/13087887/b6102604-dae5-4f17-82ea-0a2283035544">

- すると以下のようなウィンドウが開くので `iOS` の `App` を選択してください


<img width="1217" alt="スクリーンショット_2022-04-26_21_11_14" src="https://user-images.githubusercontent.com/17004375/165297357-d2bd9918-b532-40d8-a21b-0123d06a8007.png">


- 以下のようにそれぞれ入力した上で `Next` を押して適当なフォルダに保存してください

<img width="1181" alt="スクリーンショット 2025-02-04 1 05 30" src="https://github.com/user-attachments/assets/f03d72bb-3820-47ff-9486-c693109942a8">


- 一応各項目について簡単に説明しておきます

|item|description|
|---|---|
|Product Name | ・プロダクトの名前<br/>・この名前がデフォルトでアプリ名として表示されるが、もちろん変更可能|
|Team | ・アプリを管理するチーム<br/>・実機ビルドやApp Store配信をしないのであれば、未設定でも問題はありません|
|Organization Identifier | ・組織の識別子<br/>・ユニークである必要がある<br/>・基本的には所属している組織が保有しているドメインを逆から並べたものを指定|
|Bundle Identifier | ・アプリを一意に識別する文字列<br/>・Organization IdentifierにProduct Nameをくっつけたものになる|
|Interface | SwiftUI, Storyboardから選択できる|
|Language | SwiftUIを選択しなかった場合にはSwift以外にObjective-Cを選択可能|
|Testing System | プロジェクトに組み込むテストのターゲットやファイルテンプレートを None, XCTest for Unit and UITests, Swift Testing with XCTest UITests から選択できる|
|Storage | データの永続化に使用するframeworkを None, Swift Data, CoreData から選択できる|
|Host in CloudKit | StorageとしてSwift DataかCoreDataを選択したときのみ選択可能 |


- `GitHubClientApp` はアプリを起動したときのエントリーポイントになります
- この場合 `WindowGroup` で囲われている `ContentView()` が一番最初に表示されるViewとなります
```swift:GitHubClientApp.swift
@main
struct GitHubClientApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

また、本研修ではSwift Language Versionが`Swift 6`である前提で解説していきます。
以下を参考に現在の設定を確認し、`Swift 6`となっていることを確認しましょう。
<img width="1132" alt="スクリーンショット 2025-04-22 1 50 00" src="https://github.com/user-attachments/assets/283304bc-2f82-4dd2-a695-b68e76442792" />



## Next
[1.1. 簡単なレイアウトを組む](https://github.com/mixigroup/ios-swiftui-training/tree/session-1.1/README.md)
