## 0. Swiftの基本
- このセッションでは以降のセッションを円滑に進められるように最低限必要なSwift周りの知識について説明します
- 時間のある方は [公式のガイド](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/thebasics/) を一読することをお勧めします

### Playgroundの準備
- XcodeのPlaygroundでは、Swiftを簡単に実行することが可能です
- Swiftを学ぶにあたって、まずはPlaygroundを作成しましょう
- Xcodeを開いて `File > New > Playground` を選択します

<img src="https://user-images.githubusercontent.com/8536870/115705723-d696b900-a3a7-11eb-950f-8ad5fb63a71c.png" width=50%>

- Blankを選択した状態でNextを押下し適当な場所へ保存してください

<img src="https://user-images.githubusercontent.com/8536870/115705834-f8903b80-a3a7-11eb-876e-2301dd05af52.png">

- これで準備完了です、以降Swiftを学ぶ上で試したいコードがあればPlaygroundを開いて実行してみましょう

<img src="https://user-images.githubusercontent.com/8536870/115705899-0e9dfc00-a3a8-11eb-933c-319db443afbf.png">

### 変数と定数
- Swiftでは変数を `var` ,定数を `let` で宣言します

```swift
var mutable = "Apple"
mutable = "Lemon"

let immutable = "Apple"
immutable = "Lemon"
// Error - Cannot assign to value: 'immutable' is a 'let' constant
```

### Optional
- `nil` (null)を安全に扱うための型として [Optional](https://developer.apple.com/documentation/swift/optional) が提供されています
- この型は「値があるかもしれないしnilかもしれない」という状態を表現してくれます
- 非Optional型のインスタンスにはnilをセットするコードはコンパイルすることができません

```swift
var age: Int? = 42
age = nil

var userId: Int = 1234
userId = nil
// Error -  'nil' cannot be assigned to type 'Int'
```

- 「もし `nil` ではなければ...」という分岐を書く機会は多いでしょう、Swiftでは `Optional Binding` と呼ばれる書き方でスマートに処理を書くことができます

```swift
var optionalValue: Int? = 1
if let value = optionalValue {
    print("Value: '\(value)'")
} else {
    print("Couldn't bind an optional value")
}

// 変数名を変えない場合、このように書くこともできます
if let optionalValue {
    print("Value: '\(optionalValue)'")
} else {
    print("Couldn't bind an optional value")
}
// 以下のコードと同義:
// if let optionalValue = optionalValue {
//     print("Value: '\(optionalValue)'")
// } else {
//     print("Couldn't bind an optional value")
// }

```

- 「わざわざ値をOptionalから取り出さずに値を参照したい...」という機会も多いでしょう、その場合は `Optional Chaining` を使います

```swift
let optionalImagePath: String? = "logo.png"
if optionalImagePath?.hasSuffix(".png") == true {
  print("The image is in PNG format")
}
```

- また、Optional型の変数がnilならデフォルト値を返したい場合、 `??` を使うことで簡潔に書けます
```swift
// Optional Bindingを使った書き方
var result: Int
if let value = optionalValue {
  result = value
} else {
  result = 0
}

// ??を使った書き方
result = optionalValue ?? 0
```

- 必ずOptionalの中に値が入っているとわかる場合、 `!` を使って強制アンラップをすることが可能です

```swift
optionalValue = 1
let value = optionalValue!
```

- しかし、万が一nilに対して強制アンラップをしてしまうとexceptionを吐いてしまいます。
- Playground上ではわかりづらいですが、アプリではクラッシュが発生し、突然ホーム画面が表示されることになり、ユーザ体験を損ねる一因となります。

```swift
optionalValue = nil
let forceUnwrappedvalue = optionalValue!
// Fatal error: Unexpectedly found nil while unwrapping an Optional value
// Playground execution failed:
//
// error: Execution was interrupted, reason: EXC_BREAKPOINT (code=1, subcode=0x195713658).
```

### 関数
- 関数は以下のように定義します

```swift
func greet(person: String) -> String {
    let greeting = "Hello, " + person + "!"
    return greeting
}
```

- 一行のみの場合はreturnを省略することもできます

```swift
func greet(person: String) -> String {
    "Hello, " + person + "!"
}
// 以下のコードと同義:
// func greet(person: String) -> String {
//     return "Hello, " + person + "!"
// }
```

- 関数の引数には「引数ラベル」という呼び出し用の名前をつけることができます。効果的に使用することで可読性を高めることができます。

```swift
func move(from home: String, to office: String) {
    print("\(home)から\(office)に移動")
}
move(from: "中目黒", to: "渋谷")
```

### クロージャ
- クロージャとは、関数として定義せずに呼び出すことができる一連のコードブロックのことです
- 他言語のラムダ式、匿名関数などと同じ概念に相当します
- 以下のように使用します

```swift
var decorate: (Int) -> String = { number in
    "[[\(number)]]"
}
decorate(100) // "[[100]]"
```

- Swiftではクロージャを受け取る関数が数多く用意されています、その一つの例が [sorted(by:)](https://developer.apple.com/documentation/swift/array/2296815-sorted) です
- 例えば、名前の配列をアルファベット順に並び替える処理は以下のようになります

```swift
let names = ["Chris", "Alex", "Ewa", "Barry", "Daniella"]

// 1. 丁寧に書き下したパターン
names.sorted(by: { (s1: String, s2: String) -> Bool in
    return s1 < s2
})
// 結果: ["Alex", "Barry", "Chris", "Daniella", "Ewa"]

// 2. 型推論を使うパターン
names.sorted(by: { s1, s2 in s1 < s2 })

// 3. $による引数参照を使うパターン
names.sorted(by: { $0 < $1 } )

// 4. 引数の最後がクロージャであることを用いて、丸括弧を省略するパターン
names.sorted { $0 < $1 }

// 5. 小なりオペレータが2つのStringを受け取ってBoolを返すことを利用するパターン
names.sorted(by: <)
```

### enum
- Swiftのenumは以下のような定義になります

```swift
enum CompassPoint {
    case north
    case south
    case east
    case west
}

var point = CompassPoint.north
// 型名を省略して各caseを参照することができる
point = .south
```

- Switch文と組み合わせることで効果を発揮します

```swift
let directionToHead: CompassPoint = .south
switch directionToHead {
case .north:
    print("Lots of planets have a north")
case .south:
    print("Watch out for penguins")
case .east:
    print("Where the sun rises")
case .west:
    print("Where the skies are blue")
}
// Prints "Watch out for penguins"

// defaultを指定可能
switch directionToHead {
case .north:
    print("Lots of planets have a north")
default: break
}
```

- SwiftのSwitch文にenumが渡された場合、すべてのcaseが網羅されていなければコンパイル時にエラーが出ます
- この性質はかなり優秀です。例えばenumに新しいcaseが追加された場合、そのenumを使用しているすべてのswitch文にcaseが1つ足りないことを伝えるエラーが発生します。つまり、コードを実行する前に修正箇所を洗い出すことができます。
- default caseを用意してしまうとこの恩恵は失われてしまうので、慣れるまではすべてのcaseに応じた分岐を丁寧に書くことをおすすめします。

#### Associated Values
- 例えば、成功か失敗の状態を表すStateというenumを考え、失敗は発生したエラーをもつデータ構造を考えます。
- 実装例はこちらになります。

```swift
enum State {
  case success
  case failure(Error)
}
```

- Switch文を用いてパターンマッチでエラーの値を取得します

```swift
let state: State = .failure(CancellationError())
switch state {
case .success: print("Success")
case let .failure(error): print("Failure: \(error)")
}
```

### 式と文
- 式は、評価されると1つの値になるプログラムの要素のことです。
  - `1 + 1`, `if`, `switch` など
- 文は、式とは違って評価されても値にはなりません。
  - `let x = 2`, `for-in`, `while`, `if`, `switch` など
- ifとswitchは場合によって、式と文のそれぞれに解釈されることがあります。

```swift
// 式
let number: Double = if Bool.random() { 2.718 } else { 3.14 }
let word: String = switch state {
    case .success: "guitar"
    case .failure: "piano"
}

// 文
let number: Double
if Bool.random() {
    number = 2.718
} else {
    number = 3.14
}
let word: String
switch state {
case .success:
    word = "guitar"
case .failure:
    word = "piano"
}
```

### struct と class
- structとclassはSwiftでプログラミングする際に必要不可欠な概念です。
- どちらもpropertyを定義して値を保持したり、メソッドを定義して処理を実行したりできます

```swift
struct SomeStructure {
    // structure definition goes here
}
class SomeClass {
    // class definition goes here
}
```

- Swiftでは基本的にはstructを使用することが推奨されています
- classは、保持するデータの同一性を担保する必要がある場合、あるいはObjective-Cとの互換性が必要な場合に使用しましょう
  - 参考: https://developer.apple.com/documentation/swift/choosing_between_structures_and_classes

- かといって、闇雲にstructを使えばよいという訳ではありません。仮に上記のStateをstructを使って表現する場合、例えば以下のような実装が考えられます。
```swift
struct AnotherState {
  var state: State
  var error: Error?

  enum State {
    case success
    case failure
  }
}
```
- この実装ではstateが`.success`かつ errorが非nilという、本来表現できるはずのない状態を含んでしまいます。
```swift
AnotherState(state: .success, error: CancellationError())
```

- 上述のAssociated Valuesを使用することで、状態を必要十分に表現することが可能になります。

### 値型と参照型
- structで定義した型は、**値型** です
- 値型のインスタンスを別の変数に格納すると、それぞれの変数がメモリ上で指し示す箇所は別々となります
- つまり、一方の変数への変更がもう一方の変数には影響しません

```swift
struct S {
  var value: Int
}

var a = S(value: 1)
var b = a

b.value = 2

print("a: \(a.value)")
// a: 1
print("b: \(b.value)")
// b: 2
```

- classで定義した型は、 **参照型** です
- 参照型のインスタンスを別の変数に格納すると、それぞれの変数はメモリ上で同じ箇所を指し示します
- つまり、一方の変数への変更がもう一方の変数にも影響します

```swift
class C {
    var value: Int

    init(value: Int) {
        self.value = value
    }
}

var x = C(value: 1)
var y = x

y.value = 2

print("x: \(x.value)")
// x: 2
print("y: \(y.value)")
// y: 2
```

- Swiftは値型中心の言語です。現に、Int, String, Arrayなど、Swiftにおいて頻繁に使用する型にもstructが使用されています。
- どこからともなく変更される可能性のある参照型の利用箇所を限定的にすることで、自信をもってコードを改修することができるようになります
- ちなみに、Swiftでは関数の引数はデフォルトで定数として扱われます。
- 関数の中で引数の値を変更することはできません。この挙動を一般的に値渡しといいます。
```swift
func change(s: S) {
    s = S(value: 0) // Cannot assign to value: 's' is a 'let' constant
}

func change(c: C) {
    c = C(value: 0) // Cannot assign to value: 'c' is a 'let' constant
}
```

- 参照渡し、つまり引数として渡したインスタンスのメモリのアドレスを渡すこともSwiftでは可能です。
- 参照渡しを実現するには[inoutパラメータ](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/declarations#In-Out-Parameters)を使用します。
- ただし、inoutは慎重に使用するようにしましょう。関数内で行った変更が関数の外の変数にも影響を及ぼすなど、意図せぬ副作用の原因になることがあります。

#### ARC（本研修ではこれをあまり意識せずにできるので、スキップでもOK）
- Swiftのメモリは `ARC(Automatic Reference Counting)` によって管理されています
- 新しいインスタンスを初期化する際に、ARCはそのインスタンスの型や保有するプロパティに応じたメモリを確保します
- ARCはそれぞれのインスタンスがいくつのプロパティや変数, 定数から参照されているかをカウントし、その参照カウントがゼロにならない限りメモリは解放しないようになっています
- 例えば以下のコードをみてください

```swift
class Person {
    let name: String

    init(name: String) {
        self.name = name
    }

    deinit {
        print("Person \(name) is being deinitialized")
    }
}

class Apartment {
    let person: Person

    init(person: Person) {
        self.person = person
    }

    deinit {
        print("Apartment is being deinitialized")
    }
}

var person: Person? = Person(name: "Tom")
// Personの参照カウント: 1
var apartment: Apartment? = Apartment(person: person!)
// Apartmentの参照カウント: 1
// Personの参照カウント: 2

person = nil
// Personの参照カウント: 1
apartment = nil
// Apartmentの参照カウント: 0
// Prints "Apartment is being deinitialized"
// Personの参照カウント: 0
// Prints "Person Tom is being deinitialized"
```

- `deinit` 時にprintすることでメモリが解放されるタイミングがわかるようになっています、コメントに書いた通りに参照カウントが推移し、0になるタイミングでそれぞれメモリが解放されてprintされていることが確認できます
- では、以下のように `Person` のpropertyに `Apartment` を持たせてみるとどうなるでしょうか

```swift
class Person {
    let name: String
    var apartment: Apartment?

    init(name: String) {
        self.name = name
    }

    deinit {
        print("Person \(name) is being deinitialized")
    }
}

class Apartment {
    let person: Person

    init(person: Person) {
        self.person = person
        person.apartment = self
    }

    deinit {
        print("Apartment is being deinitialized")
    }
}

var person: Person? = Person(name: "Tom")
// Personの参照カウント: 1
var apartment: Apartment? = Apartment(person: person!)
// Apartmentの参照カウント: 2
// Personの参照カウント: 2

person = nil
// Personの参照カウント: 1
apartment = nil
// Apartmentの参照カウント: 1
```

- `Person` と `Apartment` がお互いに参照して循環参照が完成してしまいました、これでは永遠にメモリが解放されることはありません
- これを解決するには **弱参照 (weak参照)** を用います

```diff
class Person {
    let name: String
+   weak var apartment: Apartment?

    init(name: String) {
        self.name = name
    }

    deinit {
        print("Person \(name) is being deinitialized")
    }
}
```

- 弱参照は参照カウントに加算されません、よって循環参照を防ぎメモリリークを解消してくれます

### Protocols
- protocolは、特定の機能に適したメソッドやproperty等のインターフェースを定義します。protocolはclassやstruct, enumに適用することができます。

```swift
protocol Drink {
    // 定価
    var price: Double { get }
    func serve()
}

extension Drink {
    func serve() {
        print("Serving a drink: $\(price)")
    }
}

struct Soda: Drink {
    let price: Double
}

let soda = Soda(price: 1.23)
soda.serve()
// Serving a drink: $1.23

protocol Discountable {
    var discountPrice: Double { get }
}

struct Coffee {
    let price: Double
}

// Coffee に Discountable を適用し、割引対応を追加
extension Coffee: Discountable {
    // 例: $1引き
    var discountPrice: Double { 1.0 }
}

// デフォルト実装を上書きすることも可能
extension Coffee: Drink {
    func serve() {
        print("Serving a HOT coffee: $\(price - discountPrice)")
    }
}

let coffee = Coffee(price: 4.50)
coffee.serve()
// Serving a HOT drink: $3.5
```

- 例えば、同じような機能を複数箇所に持たせたい場合、classの継承を使って実現する代わりに、まずprotocolを使って実現できないか検討してみましょう

### Generics
- Genericsを扱うことで、任意の型を扱うI/Fを定義できます
- 例えば、データの読み込み状態を表現するデータ構造を作りたいとします
- 状態にはすべてで4つあり、それぞれが以下のようなステータスとなります
  - idle: まだデータを取得しにいっていない
  - loading: 読み込み中
  - loaded: 読み込み完了、読み込まれたデータを保持
  - failed: 読み込み失敗、遭遇したエラーを保持

- これをGenericsで実装するならば以下のようになります

```swift
enum ViewState<Value> {
    case idle
    case loading
    case failed(Error)
    case loaded(Value)
}

var data: ViewState<[String]> = .idle
// データ取得中
data = .loading
// データ取得失敗
data = .failed(CancellationError())
// データ取得完了
data = .loaded(["data1", "data2", "data3"])

// 他の型でも利用可能
var anotherData: ViewState<[Int]> = .loaded([1, 2, 3])
```

## Next
[1. SwiftUIの基本 -前準備-](https://github.com/mixigroup/ios-swiftui-training/tree/session-1.0)
