import UIKit
import Foundation

2 |> String.init

curry(String.init(data:encoding:))

let stringWithEncoding = flip(curry(String.init(data:encoding:)))
let utf8String = stringWithEncoding(.utf8)

"Hello".uppercased(with: Locale(identifier: "en"))
String.uppercased(with:)("Hello")(Locale.init(identifier: "en"))

let uppercasedWithEn = flip(String.uppercased(with:))(Locale(identifier: "en"))

uppercasedWithEn("Hello")

// https://www.pointfree.co/episodes/ep6-functional-setters
func incr(_ x: Int) -> Int {
    return x + 1
}


func incrFirst<A>(_ pair: (Int, A)) -> (Int, A) {
    return (incr(pair.0), pair.1)
}


let pair = (42, "Swift")
(incr(pair.0), pair.1)
incrFirst(pair)

func first<A, B, C>(_ f: @escaping (A) -> C) -> ((A, B)) -> (C, B) {
    return { pair in
        return (f(pair.0), pair.1)
    }
}

first(incr)(pair)

first(incr)(first(incr)(pair))

pair
    |> first(incr)
    |> first(incr)

pair
    |> first(incr)
    |> first(incr)
    |> first(String.init)


func second<A, B, C>(_ f: @escaping (B) -> C) -> ((A, B)) -> (A, C) {
    return { pair in
        return (pair.0, f(pair.1))
    }
}

pair
    |> second { $0.uppercased() }
    |> second { $0 + "!" }

pair
    |> second(zurry(flip(String.uppercased)))

pair
    |> first(incr >>> String.init)

// pipeline without data
first(incr)
    >>> first(String.init)
    >>> second(zurry(flip(String.uppercased)))

let nested = ((1, true), "Swift")

nested
    |> first { pair in pair |> second { !$0 } }

nested
    |> first { $0 |> second { !$0 } }

nested
    |> (first <<< second) { !$0 }

let transformation = (first <<< second) { !$0 }
  <> (first <<< first) { $0 + 1 }
  <> second { $0 + "!" }

nested |> transformation

let nestedArray = (42, ["Swift", "Objective-C"])


