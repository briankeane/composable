import Foundation

// https://www.pointfree.co/episodes/ep2-side-effects
precedencegroup ForwardApplication {
  associativity: left
}

precedencegroup ForwardComposition {
  associativity: left
  higherThan: ForwardApplication
}


/* This operator just makes calling a function with a value more readable
     sometimes in functional programming.

    It makes:
       String.init(5)
     equal to
     5 |> String.init

 */
infix operator |>: ForwardApplication
public func |> <A, B>(a: A, f: (A) -> B) -> B {
    return f(a)
}

// overload for inout
public func |> <A>(a: inout A, f: (inout A) -> Void) -> Void {
  f(&a)
}


/*
 The >>> operator just takes the output of one function and pipes it into the
 input of the next function.  So

 10 >> add50 >> String.init   returns  "60"

 */
infix operator >>>: ForwardComposition
public func >>> <A, B, C>(f: @escaping (A) -> B, g: @escaping (B) -> C) -> ((A) -> C) {
    return { a in
        g(f(a))
    }
}


/*
 The <> operator is the same as the >>> operator except that it only allows a
 single type of input and output and the input and output types must match.

 (If a string is going in, a string must go out...)

 */
precedencegroup SingleTypeComposition {
  associativity: left
  higherThan: ForwardApplication
}
infix operator <>: SingleTypeComposition
public func <> <A>(
  f: @escaping (A) -> A,
  g: @escaping (A) -> A)
  -> ((A) -> A) {

  return f >>> g
}

// overload for inout inputs
public func <> <A>(
  f: @escaping (inout A) -> Void,
  g: @escaping (inout A) -> Void)
  -> ((inout A) -> Void) {

  return { a in
    f(&a)
    g(&a)
  }
}
public func toInout<A>(
  _ f: @escaping (A) -> A
  ) -> ((inout A) -> Void) {

  return { a in
    a = f(a)
  }
}
public func fromInout<A>(
  _ f: @escaping (inout A) -> Void
  ) -> ((A) -> A) {

  return { a in
    var copy = a
    f(&copy)
    return copy
  }
}

// https://www.pointfree.co/episodes/ep5-higher-order-functions
/*
 Curry just separates one of the
 */
public func curry<A, B, C>(_ f: @escaping (A, B) -> C) -> (A) -> (B) -> C {
    return { a in { b in f(a, b) } }
}
public func curry<A, B, C, D>(_ f: @escaping (A, B, C) -> D) -> (A) -> (B) -> (C) -> D {
    return { a in { b in { c in f(a, b, c) } } }
}

public func flip<A, B, C> (_ f: @escaping (A) -> (B) -> C) -> (B) -> (A) -> (C) {
    return { b in { a in f(a)(b) } }
}


// overload to make flip work with zero argument functions
public func flip<A, C>(_ f: @escaping (A) -> () -> C) -> () -> (A) -> C {
  return { { a in f(a)() } }
}


/*
 Zurry (zero-argument curry) gets rid of the situation where yu have to use a weird little () after
 a flipped function in order to extract it... i.e.

 flip(String.uppercased)   // () -> (String) -> String
 flip(String.uppercased)() // (String) -> String

 zurry(flip(String.uppercased)) // (String) -> String
 */
public func zurry<A>(_ f: () -> A) -> A {
    return f()
}

/*
 Overload for map and filter functions to help it deal with inner types
 */
public func map<A, B>(_ f: @escaping (A) -> B) -> ([A]) -> [B] {
  return { $0.map(f) }
}
public func filter<A>(_ p: @escaping (A) -> Bool) -> ([A]) -> [A] {
  return { $0.filter(p) }
}


precedencegroup BackwardsComposition {
    associativity: left
}
infix operator <<<: BackwardsComposition

public func <<< <A, B, C>(_ g: @escaping (B) -> C, f: @escaping ((A) -> B)) -> ((A) -> C) {
    return { x in
        g(f(x))
    }
}
