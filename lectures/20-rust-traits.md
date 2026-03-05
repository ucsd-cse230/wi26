---
title: Traits and Iteration
headerImg: sea.jpg
---

# Traits and Iteration

Shared behavior, loops, and parallelism

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Recap

So far we have seen

- Rust's basic types, `struct`, `enum`, generics
- Ownership, borrowing, lifetimes

Next: how to define **shared behavior** across types and use it to **iterate** over data

1. **Traits**: shared behavior (cf. Haskell's typeclasses)
2. **Iterators**: `for` loops, `map`, `filter`, `collect`
3. **Parallel Iteration**: with `rayon`

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Today's Goals

1. **Traits**: shared behavior (cf. Haskell's typeclasses)
2. **Iterators**: `for` loops, `map`, `filter`, `collect`
3. **Parallel Iteration**: with `rayon`

<br>
<br>
<br>
<br>
<br>
<br>
<br>

## What is a Trait?

A **trait** defines a set of methods that a type must implement ...

... aka **typeclass** in Haskell!

### Haskell

```haskell
class Summary a where
  summarize :: a -> String
```

### Rust

```rust
trait Summary {
    fn summarize(&self) -> String;
}
```

(Like typeclasses) traits let us write code that works with
**any type** that implements that interface.

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Implementing a Trait

### Haskell

```haskell
data Article = MkArticle
  { headline :: String
  , author   :: String
  }

instance Summary Article where
  summarize a = headline a ++ ", by " ++ author a
```

### Rust

```rust
struct Article {
    headline: String,
    author: String,
}

impl Summary for Article {
    fn summarize(&self) -> String {
        format!("{}, by {}", self.headline, self.author)
    }
}
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Multiple Types, One Trait

Different types can implement the **same** trait with **different** behavior

```rust
struct Post {
    username: String,
    content: String,
}

impl Summary for Post {
    fn summarize(&self) -> String {
        format!("{}: {}", self.username, self.content)
    }
}
```

Now we can call `summarize()` on **both** `Article` and `Post`

```rust
fn main() {
    let a = Article { headline: String::from("Penguins Win!"),
                      author: String::from("Iceburgh") };
    let p = Post { username: String::from("horse_ebooks"),
                   content: String::from("of course as you know") };
    println!("{}", a.summarize()); // "Penguins Win!, by Iceburgh"
    println!("{}", p.summarize()); // "horse_ebooks: of course as you know"
}
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

<!-- ## Default Implementations

A trait can provide a **default** method body

```rust
trait Summary {
    fn summarize(&self) -> String {
        String::from("(Read more...)")
    }
}
```

Types can **override** the default or **use** it as-is

```rust
impl Summary for Article {}  // uses default: "(Read more...)"

impl Summary for Post {
    fn summarize(&self) -> String {
        format!("{}: {}", self.username, self.content)
    }
}
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br> -->

## Traits as Parameters

We can write functions that accept **any type** implementing a trait

### Haskell: "Constraint"

```haskell
notify :: (Summary a) => a -> String
notify item = "Breaking news! " ++ summarize item
```

- Haskell calls `Summary a` a **constraint** on the type variable `a`

### Rust: "Trait Bound"

```rust
fn notify<T: Summary>(item: &T) {
    println!("Breaking news! {}", item.summarize());
}
```

- Rust calls `T: Summary` a **trait bound** on the type variable `T`

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Multiple Trait Bounds

A parameter can require **multiple** traits with `+`

```rust
fn notify<T: Summary + std::fmt::Display>(item: &T) {
    println!("Breaking news! {}", item.summarize());
}
```

When bounds get long, use a `where` clause:

```rust
fn some_function<T, U>(t: &T, u: &U) -> i32
where
    T: Summary + Clone,
    U: Clone + std::fmt::Debug,
{
    todo!()
}
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## QUIZ

```rust
trait Area {
    fn area(&self) -> f64;
}

struct Circle { radius: f64 }

struct Rect { width: f64, height: f64 }

impl Area for Circle {
    fn area(&self) -> f64 {
        std::f64::consts::PI * self.radius * self.radius
    }
}

fn print_area<T: Area>(shape: &T) {
    println!("Area: {}", shape.area());
}

fn main() {
    let c = Circle { radius: 10.0 };
    let r = Rect { width: 3.0, height: 4.0 };
    print_area(&c);
    print_area(&r);
}
```

What happens?

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Compiler Error: Trait Not Implemented

```
error[E0277]: the trait bound `Rect: Area` is not satisfied
  --> src/main.rs:20:17
   |
20 |     print_area(&r);
   |     ---------- ^^ the trait `Area` is not implemented for `Rect`
   |     |
   |     required by a bound introduced by this call
```

**Fix**: implement `Area` for `Rect`!

```rust
impl Area for Rect {
    fn area(&self) -> f64 {
        self.width * self.height
    }
}
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

<!-- ## Returning Types That Implement Traits

You can return `impl Trait` from a function

```rust
fn make_shape() -> impl Area {
    Circle { radius: 5.0 }
}
```

**Limitation**: you can only return a **single** concrete type

```rust
fn make_shape(round: bool) -> impl Area {
    if round {
        Circle { radius: 5.0 }   // ERROR: two different
    } else {
        Rect { width: 3.0, height: 4.0 }  // return types!
    }
}
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br> -->

## Familiar Traits: `Debug`, `Clone`, `Copy`

We've already used traits via `#[derive(...)]`!

```rust
#[derive(Debug, Clone, Copy)]
struct Circle {
    x: f64,
    y: f64,
    radius: f64,
}
```

- `Debug` lets you print with `{:?}`
- `Clone` gives you `.clone()`
- `Copy` makes assignment _copy_ instead of _move_

These are all **traits** defined in the standard library.

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Goal Today

1. ~~**Traits**: shared behavior (cf. Haskell's typeclasses)~~
2. **Iterators**: `for` loops, `map`, `filter`, `collect`
3. **Parallel Iteration**: with `rayon`

<br>
<br>
<br>
<br>
<br>
<br>
<br>

## The `Iterator` Trait

Iteration in Rust is built on a simple trait

```rust
trait Iterator {
    type Item;
    fn next(&mut self) -> Option<Self::Item>;
}
```

- `type Item` is the type of elements produced (an **associated type**)
- `next()` returns `Some(value)` or `None` when done
- Calling `next()` **consumes** one element (hence `&mut self`)

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Calling `next` Directly

```rust
fn main() {
    let v = vec![10, 20, 30];
    let mut iter = v.iter();

    println!("{:?}", iter.next()); // Some(10)
    println!("{:?}", iter.next()); // Some(20)
    println!("{:?}", iter.next()); // Some(30)
    println!("{:?}", iter.next()); // None
}
```

Note: `iter` must be `mut` because `next()` advances internal state.

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## `for` Loops Use Iterators

A `for` loop is syntactic sugar for calling `next()` repeatedly

```rust
fn main() {
    let v = vec![10, 20, 30];
    for val in v.iter() {
        println!("Got: {val}");
    }
}
```

Prints:

```
Got: 10
Got: 20
Got: 30
```

The `for` loop calls `next()` behind the scenes until it gets `None`.

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Three Ways to Iterate

| Method         | Produces | Ownership       |
| :------------- | :------- | :-------------- |
| `.iter()`      | `&T`     | shared borrow   |
| `.iter_mut()`  | `&mut T` | mutable borrow  |
| `.into_iter()` | `T`      | takes ownership |

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## QUIZ

```rust
fn main() {
    let v = vec![String::from("a"), String::from("b")];

    for s in v.iter() {
        println!("{s}");
    }
    println!("{:?}", v);
}
```

```rust
fn main() {
    let mut v = vec![String::from("a"), String::from("b")];

    for s in v.iter_mut() {
        s.push_str("_foo");
    }
    println!("{:?}", v);
}
```

```rust
fn main() {
    let v = vec![String::from("a"), String::from("b")];

    for s in v.into_iter() {
        println!("{s}");
    }

    println!("{:?}", v);
}
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Iterator Adaptors: `map`

**Iterator adaptors** transform one iterator into another.

### Haskell

```haskell
map (+1) [1, 2, 3]   -- [2, 3, 4]
```

### Rust

```rust
fn main() {
    let v = vec![1, 2, 3];
    let v2: Vec<i32> = v.iter().map(|x| x + 1).collect();
    println!("{:?}", v2); // [2, 3, 4]
}
```

- `|x| x + 1` is a **closure** (like Haskell's `\x -> x + 1`)
- `.collect()` consumes the iterator and builds a `Vec`

**Important**: iterators are **lazy** -- nothing happens until you consume them!

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Iterator Adaptors: `filter`

### Haskell

```haskell
filter even [1, 2, 3, 4, 5]   -- [2, 4]
```

### Rust

```rust
fn main() {
    let v = vec![1, 2, 3, 4, 5];
    let evens: Vec<&i32> = v.iter().filter(|x| *x % 2 == 0).collect();
    println!("{:?}", evens); // [2, 4]
}
```

`filter` keeps elements where the closure returns `true`.

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Chaining Adaptors

You can chain `map`, `filter`, and other adaptors together

### Haskell

```haskell
sum (map (*2) (filter even [1..10]))   -- 60
```

### Rust

```rust
fn main() {
    let v: Vec<i32> = (1..=10).collect();
    let result: i32 = v.iter()
        .filter(|x| *x % 2 == 0)
        .map(|x| x * 2)
        .sum();
    println!("{result}"); // 60
}
```

Read it as a **pipeline**: start with `1..=10`, keep evens, double them, sum.

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## QUIZ

What does this print?

```rust
fn main() {
    let words = vec!["hello", "world", "hi"];
    let result: Vec<_> = words.iter()
        .filter(|w| w.len() > 2)
        .collect();
    println!("{:?}", result);
}
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Answer

```
["hello", "world"]
```

- `filter` keeps words with length > 2: `"hello"`, `"world"`
- `copied` converts `&&str` to `&str`
- `collect` builds a `Vec<&str>`

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

<!--
## Consuming Adaptors

Some methods **consume** the iterator, producing a single value

| Method      | Description                        |
| ----------- | ---------------------------------- |
| `sum()`     | adds up all elements               |
| `count()`   | counts the number of elements      |
| `collect()` | gathers elements into a collection |
| `any()`     | true if any element matches        |
| `all()`     | true if all elements match         |
| `find()`    | returns first match as `Option`    |

```rust
fn main() {
    let v = vec![1, 2, 3, 4, 5];
    let has_even = v.iter().any(|x| x % 2 == 0);
    println!("{has_even}"); // true
}
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br> -->

## Goal Today

1. ~~**Traits**: shared behavior (cf. Haskell's typeclasses)~~
2. ~~**Iterators**: `for` loops, `map`, `filter`, `collect`~~
3. **Parallel Iteration**: with `rayon`

<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Parallel Iteration with Rayon

What if you want to speed up iteration by using **multiple cores**?

In most languages, parallelism is hard and error-prone (data races, deadlocks, ...).

`Rust`'s ownership it **safe**; `Rayon` makes it **easy**.

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Sequential vs Parallel: One Line Change

### Sequential

```rust
let total: i32 = data.iter()
    .filter(|x| is_interesting(x))
    .map(|x| heavy_computation(x))
    .sum();
```

### Parallel (with Rayon)

```rust
use rayon::prelude::*;

let total: i32 = data.par_iter()
    .filter(|x| is_interesting(x))
    .map(|x| heavy_computation(x))
    .sum();
```

Just change `.iter()` to `.par_iter()` ... that's it!

Rayon automatically splits the work across threads.

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Rayon's Parallel Iterators

Three parallel equivalents of the sequential methods:

| Sequential     | Parallel           | Ownership       |
| -------------- | ------------------ | --------------- |
| `.iter()`      | `.par_iter()`      | shared borrow   |
| `.iter_mut()`  | `.par_iter_mut()`  | mutable borrow  |
| `.into_iter()` | `.into_par_iter()` | takes ownership |

All the familiar adaptors work: `map`, `filter`, `sum`, `collect`, ...

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Example: Parallel Sum of Squares

```rust
use rayon::prelude::*;

fn sum_of_squares(v: &[i64]) -> i64 {
    v.par_iter()
        .map(|x| x * x)
        .sum()
}

fn main() {
    let data: Vec<i64> = (1..=1_000_000).collect();
    let result = sum_of_squares(&data);
    println!("Sum of squares: {result}");
}
```

Rayon handles thread creation, work splitting, and joining -- all behind the scenes.

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Why is Rayon Safe?

Why can't we have data races?

### Sequential: This compiles

```rust
let mut total = 0;
data.iter()
    .filter(|x| is_interesting(x))
    .for_each(|x| total += heavy_computation(x));
```

### Parallel: This does NOT compile!

```rust
let mut total = 0;
data.par_iter()
    .filter(|x| is_interesting(x))
    .for_each(|x| total += heavy_computation(x));  // ERROR!
```

```
error: cannot assign to `total`, as it is a captured variable
       in a `Fn` closure
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Rust's Type System Prevents Data Races

Rayon requires closures to be `Fn` (not `FnMut`)

- `Fn`: can only **read** captured variables (shared access)
- `FnMut`: can **modify** captured variables (exclusive access)

Multiple threads running `total += ...` would be a **data race**!

The compiler **rejects** this at compile time.

**Fix**: use Rayon's built-in `sum()`, which safely combines partial results

```rust
let total: i32 = data.par_iter()
    .filter(|x| is_interesting(x))
    .map(|x| heavy_computation(x))
    .sum();                          // safe parallel reduction
```

This is Rust's **fearless concurrency**: the compiler catches threading bugs _before_ your code runs.

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## QUIZ

Which of these can be safely parallelized with `par_iter`?

```rust
// (A) sum the lengths of strings
let total: usize = words.iter()
    .map(|w| w.len())
    .sum();
```

```rust
// (B) collect uppercase versions
let upper: Vec<String> = words.iter()
    .map(|w| w.to_uppercase())
    .collect();
```

```rust
// (C) push into a shared vec
let mut results = Vec::new();
words.iter()
    .for_each(|w| results.push(w.to_uppercase()));
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Answer

- **(A)** Yes! `map` + `sum` is safe to parallelize; no shared mutable state.
- **(B)** Yes! `map` + `collect` is safe; each closure produces an independent value.
- **(C)** No! `results.push(...)` mutates a shared `Vec` -- the compiler would reject the parallel version.

The pattern: if your pipeline uses **pure** functions (no side effects), it parallelizes safely.

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Using Rayon: Setup

Add `rayon` to your `Cargo.toml`:

```toml
[dependencies]
rayon = "1.10"
```

Then import the prelude:

```rust
use rayon::prelude::*;
```

That's it! Now `.par_iter()`, `.par_iter_mut()`, and `.into_par_iter()` are available on standard collections.

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Goal Today

1. ~~Traits: shared behavior via `trait`, `impl Trait for Type`, trait bounds~~
2. ~~Iterators: `Iterator` trait, `for` loops, `map`, `filter`, `collect`~~
3. ~~Parallel Iteration: Rayon's `par_iter`, fearless concurrency~~

<br>
<br>
<br>
<br>
<br>
<br>

## Summary

**Traits** define shared behavior across types

- Like Haskell's typeclasses
- Use `impl Trait` or `T: Trait` for generic functions

**Iterators** provide a uniform way to process sequences

- `for` loops, `map`, `filter`, `collect`, `sum`, ...
- Lazy: nothing happens until consumed

**Rayon** makes parallelism a one-line change

- Replace `.iter()` with `.par_iter()`
- Rust's type system **prevents data races** at compile time
- "Fearless concurrency"

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Material Inspired by

- https://doc.rust-lang.org/book/ch10-02-traits.html
- https://doc.rust-lang.org/book/ch13-02-iterators.html
- https://developers.redhat.com/blog/2021/04/30/how-rust-makes-rayons-data-parallelism-magical
