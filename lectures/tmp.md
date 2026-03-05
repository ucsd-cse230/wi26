---
title: Constructing Types
headerImg: sea.jpg
---

# Constructing Types

So far

- Rust's primitive types like `i32`, `bool`, and `char`
- `let` bindings, `fn` definitions, and control flow with `if` and `;`
- References/Borrows `&T` and `&mut T`
- Sharing _xor_ Mutation

Next, how to write and use our own types in Rust (cf. Haskell's `data`)

1. **product types** `struct`
2. **sum types** `enum`
3. **recursive types**
4. **generics** `Vec<T>`, `Option<T>`, `Result<T, E>`

and then Rust specific features like

5. **slices** `&[T]` and `&str`
6. **lifetimes**

<br>
<br>
<br>
<br>
<br>
<br>

## Product Types: `struct`

``Product'' is a fancy word for **struct** or **record**

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

## Product Types: `struct`

``Product'' is a fancy word for **struct** or **record**

To **define** a `Circle` _type_ with three fields

### Haskell

```haskell
data Circle = MkCircle
  { x      :: Double
  , y      :: Double
  , radius :: Double
  }
  deriving (Show)
```

### Rust

```rust
#[derive(Debug)]
struct Circle {
    x: f64,
    y: f64,
    radius: f64,
}
```

## Product Types: Construction

To **construct** a `Circle` _value_

### Haskell

```haskell
c :: Circle
c = MkCircle { x = 0.0, y = 0.0, radius = 5.0 }
```

### Rust

```rust
let c = Circle { x: 0.0, y: 0.0, radius: 5.0 };
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Product Types: Use

To **use** a `Circle` _value_

### Haskell

```haskell
circleArea :: Circle -> Double
circleArea c =
  let r = radius c
  in pi * r * r
```

### Rust

```rust
fn circle_area(c: Circle) -> f64 {
    let r = c.radius;
    std::f64::consts::PI * r * r
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
<br>

## QUIZ

Let's construct and use a `Circle`

```rust
fn circle_area(c: Circle) -> f64 {
    let r = c.radius;
    std::f64::consts::PI * r * r
}

fn main() {
    let c = Circle { x: 0.0, y: 0.0, radius: 10.0 };
    let a = circle_area(c);
    println!("Circle {c:?} has area = {a:?}");
}
```

What is printed?

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
<br>

## Unique Owners / Move transfers ownership!

A _very helpful_ error message...

`c` is **moved into** `circle_area` because it is considered "big data" (no `Copy`)

```rust
error[E0382]: borrow of moved value: `c`
  --> src/main.rs:16:23
   |
14 |     let c = Circle { x: 0.0, y: 0.0, radius: 10.0 };
   |         - move occurs because `c` has type `Circle`, which does not implement the `Copy` trait
15 |     let a = circle_area(c);
   |                         - value moved here
16 |     println!("Circle {c:?} has area = {a:?}");
   |                       ^ value borrowed here after move
   |
```

Three ways to avoid transfer: **Clone** or **Copy** or **Borrow**

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

## Clone To Avoid Transfer

```rust
note: if `Circle` implemented `Clone`, you could clone the value
  --> src/main.rs:2:1
   |
 2 | struct Circle {
   | ^^^^^^^^^^^^^ consider implementing `Clone` for this type
...
15 |     let a = circle_area(c);
   |                         - you could clone this value
```

Tell `rustc` that `Circle` to generate a `.clone()` method for `Circle`

```rust
#[derive(Clone, Debug)]
struct Circle {...}
```

... and then we can write

```rust
fn main() {
    let c = Circle { x: 0.0, y: 0.0, r: 10.0 };
    let a = circle_area(c.clone());  // transfers clone to `circle_area`
    println!("Circle {c:?} has area = {a:?}");
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
<br>
<br>

## Copy to Avoid Transfer

Additionally, we could `derive(Copy)` which would tell rust that `Circle` is "little data"

```rust
#[derive(Clone, Copy, Debug)]
struct Circle {...}
```

... then rust will **automatically create a copy** instead of **moving** the data into `circle_area`

```rust
fn main() {
    let c = Circle { x: 0.0, y: 0.0, r: 10.0 };
    let a = circle_area(c)  // copies `c` instead of moving
    println!("Circle {c:?} has area = {a:?}");
}
```

(Ok if the `struct` is small, but still we're doing some work!)

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

## _Borrow_ to Avoid Transfer

Best option is to _borrow_ -- no need to make any copies!

```rust
note: consider changing this parameter type in function `circle_area` to borrow instead if owning the value isn't necessary
  --> src/main.rs:8:19
   |
 8 | fn circle_area(c: Circle) -> f64 {
   |    -----------    ^^^^^^ this parameter takes ownership of the value
   |    |
   |    in this function
```

So instead we require `c: &Circle` as the input type...

```rust
fn circle_area(c: &Circle) -> f64 {     // change input type to &Circle
    let r = c.radius;
    std::f64::consts::PI * r * r
}

fn main() {
    let c = Circle { x: 0.0, y: 0.0, r: 10.0 };
    let a = circle_area(&c);            // pass in a shared borrow as arg
    println!("Circle {c:?} has area = {a:?}");
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
<br>

## Constructing Types

So far

- Rust's primitive types like `i32`, `bool`, and `char`
- References/Borrows `&T` and `&mut T`
- `let` bindings, `fn` definitions, and control flow with `if` and `;`

Next, how to write and use our own types in Rust (cf. Haskell's `data`)

1. ~~**product types** `struct`~~
2. **sum types** `enum`
3. **recursive types**
4. **generics** `Vec<T>`, `Option<T>`, `Result<T, E>`

and then Rust specific features like

5. **slices** `&[T]` and `&str`
6. **lifetimes**

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

## Sum Types: `enum`

Haskell's "sum" types are called **enums** in Rust...

### Haskell

```haskell
data Shape
  = Rect Double Double
  | Poly [(Double, Double)]
  deriving(Show)
```

### Rust

```rust
enum Shape {
  Rect(f64, f64),
  Poly(Vec<(f64, f64)>),
}
```

<br>
<br>
<br>
<br>
<br>

## Constructing `enum`s

Use **constructors** to build a `Shape` value

### Haskell

```haskell
sh0 :: Shape
sh0 = Rect 10.0 20.0

sh1 :: Shape
sh1 = Poly [(0.0,0.0), (1.0,0.0), (1.0,1.0)]
```

### Rust

```rust
let sh0 = Shape::Rect(10.0, 20.0);
let sh1 = Shape::Poly(vec![(0.0,0.0), (1.0,0.0), (1.0,1.0)]);
```

**Note**:

- `Vec<...>` is Rust's growable array type (like Haskell's list `[...]`)
- Constructor name has a prefix `Shape::` to indicate which `enum` it belongs to

<br>
<br>
<br>
<br>
<br>

## Using `enum`s

Via **pattern matching**

### Haskell

```haskell
shapeArea :: Shape -> Double
shapeArea (Rect w h) = w * h
shapeArea (Poly pts) = polyArea pts
```

### Rust

```rust
fn shape_area(sh: &Shape) -> f64 {
    match sh {
        Shape::Rect(w, h) => w * h,
        Shape::Poly(pts) => poly_area(pts),
    }
}
```

**QUIZ** Why does `shape_area` take `&Shape` instead of `Shape`?

<br>
<br>
<br>
<br>
<br>
<br>

## Constructing Types

So far

- Rust's primitive types like `i32`, `bool`, and `char`
- References/Borrows `&T` and `&mut T`
- `let` bindings, `fn` definitions, and control flow with `if` and `;`

Next, how to write and use our own types in Rust (cf. Haskell's `data`)

1. ~~**product types** `struct`~~
2. ~~**sum types** `enum`~~
3. **recursive types**
4. **generics** `Vec<T>`, `Option<T>`, `Result<T, E>`

and then Rust specific features like

5. **slices** `&[T]` and `&str`
6. **lifetimes**

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

## Recursive Types

Recall the `Expr` type we defined in Haskell for arithmetic expressions

### Haskell

```haskell
data Op
  = Add | Sub | Mul | Div

data Expr
  = Num Int
  | Bin Op Expr Expr
```

### Rust

Let's define the same `Expr` type as a Rust `enum`

```rust
enum Op { Add, Sub, Mul, Div }

enum Expr {
    Num(i32),
    Bin(Op, Expr, Expr),
}
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Recursive Types ... must have known size!

But the compiler is not happy!

```
error[E0072]: recursive type `Expr` has infinite size
 --> src/lib.rs:6:1
  |
6 | enum Expr {
  | ^^^^^^^^^
7 |     Num(i32),
8 |     Bin(Op, Expr, Expr),
  |             ---- recursive without indirection
  |
help: insert some indirection (e.g., a `Box`, `Rc`, or `&`) to break the cycle
  |
8 |     Bin(Op, Box<Expr>, Expr),
  |             ++++    +
```

`rustc` computes **size** of each type at compile time (Why?)

Thinks that `Expr` is **infinitely large** as each `Bin`
... can contain two more `Expr`s,
... each of which contains two more `Expr`s,
... and so on...

<br>
<br>
<br>
<br>
<br>
<br>
<br>

**Solution**: write `Box<T>` to tell the compiler to introduce indirection

- i.e. **inner** `Expr` are stored on the heap

(Why didn't we have this problem in Haskell?)

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Building Values of Recursive Type

```rust
// expression: (3 + 4) * 5
let expr = Expr::Bin(
    Op::Mul,
    Expr::Bin(
        Op::Add,
        Expr::Num(3),
        Expr::Num(4),
    ),
    Expr::Num(5),
);
```

Boo! More errors!

```rust
error[E0308]: arguments to this enum variant are incorrect
  --> src/main.rs:15:5
   |
15 |     Expr::Bin(
   |     ^^^^^^^^^
   |
note: expected `Box<Expr>`, found `Expr`
  --> src/main.rs:17:9
   |
17 |         Expr::Num(3),
   |         ^^^^^^^^^^^^
   = note: expected struct `Box<Expr>`
                found enum `Expr`
   = note: for more on the distinction between the stack and the heap, read https://doc.rust-lang.org/book/ch15-01-box.html, https://doc.rust-lang.org/rust-by-example/std/box.html, and https://doc.rust-lang.org/std/boxed/index.html
note: expected `Box<Expr>`, found `Expr`
  --> src/main.rs:18:9
   |
18 |         Expr::Num(4),
   |         ^^^^^^^^^^^^
   = note: expected struct `Box<Expr>`
                found enum `Expr`
   = note: for more on the distinction between the stack and the heap, read https://doc.rust-lang.org/book/ch15-01-box.html, https://doc.rust-lang.org/rust-by-example/std/box.html, and https://doc.rust-lang.org/std/boxed/index.html
```

## Boxing Recursive Values

**Read the error message carefully!**

Need to store the inner `Expr` in a `Box`

```rust
help: store this in the heap by calling `Box::new`
   |
17 |         Box::new(Expr::Num(3)),
   |         +++++++++            +
help: store this in the heap by calling `Box::new`
   |
18 |         Box::new(Expr::Num(4)),
   |         +++++++++            +
```

Storing inner `Expr` in a `Box`

```rust
  let expr = Expr::Bin(
    Op::Mul,
    Box::new(Expr::Bin(
        Op::Add,
        Box::new(Expr::Num(3)),
        Box::new(Expr::Num(4)),
    )),
    Box::new(Expr::Num(5)),
  );
```

<br>
<br>
<br>
<br>
<br>

## Tucking the `Box` into a "smart" constructor

We can write a helper function to reduce the boilerplate of boxing

```rust
fn bin(op: Op, left: Expr, right: Expr) -> Expr {
    Expr::Bin(op, Box::new(left), Box::new(right))
}
```

Then we can write

```rust
let expr = bin(
    Op::Mul,
    bin(
        Op::Add,
        Expr::Num(3),
        Expr::Num(4),
    ),
    Expr::Num(5),
);
```

**QUIZ**:

1. Why don't we write a similar helper for `Num`?

2. Why does `bin` take `Expr` and not `&Expr`?

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Using Recursive Values

Finally, we can use pattern-matching to write a function to evaluate an `Expr`

```rust
fn eval_op(op: &Op, lval: i32, rval: i32) -> i32 {
    match op {
        Op::Add => lval + rval,
        Op::Sub => lval - rval,
        Op::Mul => lval * rval,
        Op::Div => lval / rval, // yikes, DBZ!
    }
}

fn eval(e: &Expr) -> i32 {
  match e {
    Expr::Num(n) => *n,
    Expr::Bin(op, left, right) => {
      eval_op(op, eval(e1), eval(e2))
    }
  }
}
```

**QUIZ** Why does `eval` take `&Expr` and not just `Expr` ?

**QUIZ** What is up with the `*n`?

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

## Constructing Types

So far

- Rust's primitive types like `i32`, `bool`, and `char`
- References/Borrows `&T` and `&mut T`
- `let` bindings, `fn` definitions, and control flow with `if` and `;`

Next, how to write and use our own types in Rust (cf. Haskell's `data`)

1. ~~**product types** `struct`~~
2. ~~**sum types** `enum`~~
3. ~~**recursive types**~~
4. **generics** `Box<T>`, `Vec<T>`, `Option<T>`, `Result<T, E>`

and then Rust specific features like

5. **slices** `&[T]` and `&str`
6. **lifetimes**

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

## Generics

Like Haskell, and Java, C++, ... Rust has generic types e.g.

````rust
fn choose<T>(b: bool, x: T, y:T) -> T {
  if b { x } else { y }
}

fn main() {
  // use as `i32`
  let v_i32 = choose(true, 20, 20);
  println!("choose says: {v_i32}");

  // use as `String`
  let v_string = choose(false, String::from("cat"), String::from("dog"));
  println!("choose says: {v_string}");
}

The `<T>` syntax indicates that `choose` is generic in type `T`

- can be _instantiated_ at different types, e.g. `i32` and `String`

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Generic Types

(In addition to functions like `choose`) we can have generic **types**

- e.g. `Vec<T>` and `Box<T>`

```rust
let v1: Vec<i32> = vec![1, 2, 3];
let v2: Vec<String> = vec![String::from("a"), String::from("b")];

let b1: Box<i32> = Box::new(42);
let b2: Box<String> = Box::new(String::from("hello"));
````

<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Defining Generic Types

We can use generics inside `struct` and `enum` types

### Option

Like Haskell's `Maybe t`

```rust
#[derive(Debug)]
enum Option<T> {
    None,
    Some(T),
}
```

### Result

Like Haskell's `Either e t`

```haskell
data Either e t
  = Right t
  | Left e
  deriving (Show)
```

we have a widely used `Result<T, E>` type in Rust

```rust
#[derive(Debug)]
enum Result<T, E> {
    Ok(T),
    Err(E),
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

## Using `Result` for Safe Division

Lets rewrite our `eval_op` function to return a `Result<i32, String>`

```rust
fn eval_op(op: &Op, v1: i32, v2: i32, e2: &Expr) -> Result<i32, String> {
  match op {
    Op::Add => _____________________________,
    Op::Sub => _____________________________,
    Op::Mul => _____________________________,
    Op::Div => if v2 == 0 {
      let msg = String::from(format!("Division by zero: {e2:?}"));
      Err(_________________________)
    } else {
      Ok(_____________________)
    },
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

```rust
fn eval_op(op: &Op, v1: i32, v2: i32, e2: &Expr) -> Result<i32, String> {
  match op {
    Op::Add => Ok(v1 + v2),
    Op::Sub => Ok(v1 - v2),
    Op::Mul => Ok(v1 * v2),
    Op::Div => if v2 == 0 {
      let msg = format!("Division by zero: {e2:?}");
      Err(String::from(msg))
    } else {
      Ok(v1 / v2)
    },
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

## QUIZ: A Safe Evaluator

Lets rewrite our `eval` function to return a `Result<i32, String>`

```rust
fn eval(e: &Expr) -> Result<i32, String> {
  match e {
    Expr::Num(n) => _____________________,
    Expr::Bin(op, e1, e2) => {
      ____________________________________
      ____________________________________
      ____________________________________
      ____________________________________
      ____________________________________
      ____________________________________
    }
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
<br>
<br>
<br>

## Pattern-Matching on `Result`

We have to do pattern-matching on `Result` to extract the value for the sub-expressions

```rust
fn eval(e: &Expr) -> Result<i32, String> {
  match e {
    Expr::Num(n) => Ok(*n),
    Expr::Bin(op, e1, e2) => {
      match eval(e1) {
        Err(msg) => Err(msg),
        Ok(v1) => match eval(e2) {
          Err(msg) => Err(msg),
          Ok(v2) => eval_op(op, v1, v2, e2),
        },
      }
    }
  }
}
```

**Yuck!**

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Factoring Out the Pattern Match: Step 1

Rust has some syntactic sugar to make this less painful.

**Step 1** Factor out the names `v1` and `v2` out using using plain `let` ...

```rust
fn eval(e: &Expr) -> Result<i32, String> {
  match e {
    Expr::Num(n) => Ok(*n),
    Expr::Bin(op, e1, e2) => {
      let v1 = match eval(e1) {
        Err(msg) => return Err(msg), // early return
        Ok(v1) => v1,
      };
      let v2 = match eval(e2) {
        Err(msg) => return Err(msg),  // early return
        Ok(v2) => v2,
      };
      eval_op(op, v1, v2, e2)
    }
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

## Factoring Out the Pattern Match: Step 2

Rust has some syntactic sugar to make this less painful.

**Step 2** Factor out the `match ...` using `?`

**Write** `expr?` instead of any expression of the form

```rust
match expr {
  Err(e) => return Err(e), // early return
  Ok(v) => v,
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
<br>

## Error Handling with `Result`

So we get

```rust
fn eval(e: &Expr) -> Result<i32, String> {
  match e {
    Expr::Num(n) => Ok(*n),
    Expr::Bin(op, e1, e2) => {
      let v1 = eval(e1)?;
      let v2 = eval(e2)?;
      eval_op(op, v1, v2, e2)
    }
  }
}
```

(Instead of Haskell's monads/do) Rust has a special `?`

Does the same thing for `Result`, `Option`, ...

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Constructing Types

So far

- Rust's primitive types like `i32`, `bool`, and `char`
- References/Borrows `&T` and `&mut T`
- `let` bindings, `fn` definitions, and control flow with `if` and `;`

Next, how to write and use our own types in Rust (cf. Haskell's `data`)

1. ~~**product types** `struct`~~
2. ~~**sum types** `enum`~~
3. ~~**recursive types**~~
4. ~~**generics** `Vec<T>`, `Option<T>`~~
5. ~~**error handling** `Result<T, E>`~~

and then Rust specific features like

6. **slices** `&[T]` and `&str`
7. **lifetimes**

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

## Slices

Rust aims to be both safe and **fast**

```rust
fn test() {
  let str : Vec<char> = vec!['b', 'a', 't', ' ', 'm', 'a', 'n'];

  let first = first_word(&str);
  print_word(&str, first);

  let last = last_word(&str);
  print_word(&str, last);
  println!();
}
```

## QUIZ

How to write `first_word`, `last_word`, and `print_word`
**without copying** the `str` vector?

```rust
fn first_word(chars: &Vec<char>) -> ??? {
    todo!()
}

fn last_word(chars: &Vec<char>) -> ??? {
    todo!()
}

fn print_word(chars: &Vec<char>, ???) {
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

## Solution? `Range` within `Vec<char>`

Define a `Range` type to represent a range of indices

```rust
type Range = (usize, usize); // (lo, hi)
```

e.g. inside `vec!['b', 'a', 't', ' ', 'm', 'a', 'n']`

```rust
let first = (0, 3); // 'b', 'a', 't'
let last  = (4, 7); // 'm', 'a', 'n
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Print Word by Iterating over Range

```rust
fn print_word(chars: &Vec<char>, rng: Range) {
  let (lo, hi) = rng;
  for i in lo..hi {
      print!("{}", chars[i])
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
<br>
<br>
<br>

## Find Word by Iterating over Range

Iterate over `chars` to find the first/last word

```rust
fn first_word(chars: &Vec<char>) -> Range {
  let n = chars.len();
  for i in 0..n {
    if chars[i] == ' ' {
      return (0, i);
    }
  }
  return (0, n);
}

fn last_word(chars: &Vec<char>) -> Range {
  let n = chars.len();
  for i in (0..n).rev() {
    if chars[i] == ' ' {
      return (i+1, n);
    }
  }
  return (0, n);
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
<br>
<br>

## QUIZ

What is the result of running this code?

```rust
fn quiz() {
  let mut str = vec!['b', 'a', 't', ' ', 'm', 'a', 'n'];
  let last = last_word(&str);
  str.pop();
  print_word(&str, last);
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
<br>
<br>
<br>

## Problem: Range Can Become Invalid!

The `pop()` **shrinks** the vector by one character, making `last` invalid!

```rust
fn quiz() {
  let mut str = vec!['b', 'a', 't', ' ', 'm', 'a', 'n'];
  let last = last_word(&str);
  str.pop();                  // REMOVES last `char`; `last` IS NOW INVALID
  print_word(&str, last);     // RUNTIME ERROR!
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
<br>
<br>
<br>

## Solution: Slices `&[T]`

The **slice** type `&[T]` represents a **view** into a vector/array

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

## Constructing Slices

`&chars[lo..hi]` is a **slice** of `chars` from index `lo` (inclusive) to `hi` (exclusive)

```rust
fn first_word_slice(chars: &Vec<char>) -> &[char] {
  let n = chars.len();
  for i in 0..n {
    if chars[i] == ' ' {
      return &chars[0..i]; // return a slice from 0 to i
    }
  }
  return &chars[0..n];
}
```

Instead of returning a of `(0, i)` we return the **slice** `&[char]`

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

```rust
fn last_word_slice(chars: &Vec<char>) -> &[char] {
  let n = chars.len();
  for i in (0..n).rev() {
    if chars[i] == ' ' {
      return &chars[i+1..n];
    }
  }
  return &chars[0..n];
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
<br>
<br>
<br>
<br>

## Using Slices

You can **use** the slice like an array/vector e.g.

```rust
fn print_word_slice(chars: &[char]) {
  for i in 0..chars.len() {
      print!("{}", chars[i])
  }
  // or for c in chars { print!("{}", c); }
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
<br>
<br>

## QUIZ

What is the result of running this code?

```rust
fn quiz() {
  let mut str = vec!['b', 'a', 't', ' ', 'm', 'a', 'n'];
  let last = last_word_slice(&str);
  str.pop();
  print_word_slice(&str, last);
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
<br>

## Solution: Slices Prevent Invalid Ranges

The compiler prevents us from compiling this code!

```
error[E0502]: cannot borrow `str` as mutable because it is also borrowed as immutable
  --> src/main.rs:93:3
   |
92 |   let last = last_word_slice(&str);
   |                              ---- immutable borrow occurs here
93 |   str.pop();
   |   ^^^^^^^^^ mutable borrow occurs here
94 |   print!("last word: {last:?}");
   |                       ---- immutable borrow later used here
```

That is, the **compiler complains** that we have simultaneously borrowed

- `str` as **mutable** `Vec<char>` AND
- `last` as **immutable** `&[char]`

both referring to the same data!

````rust
fn quiz() {
  let mut str = vec!['b', 'a', 't', ' ', 'm', 'a', 'n'];
  let last = last_word_slice(&str);
  str.pop();  // ERROR: simultaneous mutable and immutable borrow!
  print_word_slice(&str, last);
}

<br>
<br>
<br>
<br>
<br>
<br>
<br>


## Stringly Slices

Rust has a built-in type `str` to represent "stringly" slices.

```rust
fn first_word_str(s: &String) -> &str {
  let n = s.len();
  let chars = s.as_bytes();
  for i in 0..n {
    if chars[i] == b' ' {
      return &s[0..i];
    }
  }
  return &s[0..n];
}

fn last_word_str(s: &String) -> &str {
  let n = s.len();
  let chars = s.as_bytes();
  for i in (0..n).rev() {
    if chars[i] == b' ' {
      return &s[i+1..n];
    }
  }
  return &s[0..n];
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
<br>
<br>


## Stringly Slices

Rust has a built-in type `str` to represent "stringly" slices.

```rust
fn test() {
  let text = String::from("bat man begins");

  let first = first_word_str(&text);
  println!("first word: {first:?}"); // prints "bat"

  let last = last_word_str(&text);
  println!("last word: {last:?}");  // prints "begins"
}
```

(As before, compiler prevents mutating `text` while we have active `&str` slices into it)

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



## Constructing Types

So far

- Rust's primitive types like `i32`, `bool`, and `char`
- References/Borrows `&T` and `&mut T`
- `let` bindings, `fn` definitions, and control flow with `if` and `;`

Next, how to write and use our own types in Rust (cf. Haskell's `data`)

1. ~~**product types** `struct`~~
2. ~~**sum types** `enum`~~
3. ~~**recursive types**~~
4. ~~**generics** `Vec<T>`, `Option<T>`, `Result<T, E>`~~
5. ~~**error handling** `Result<T, E>`~~

and then Rust specific features like

6. ~~**slices** `&[T]` and `&str`~~
7. [**lifetimes**](https://doc.rust-lang.org/book/ch10-03-lifetime-syntax.html)

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

What happens when we run the following code?

```rust
fn longer(s1: &str, s2: &str) -> &str {
  if s1.len() >= s2.len() { s1 } else { s2 }
}

fn test() {
  let text = String::from("bat man begins");
  let first = first_word_str(&text);
  let last = last_word_str(&text);
  let longer_word = longer(first, last);
  println!("longer word: {longer_word:?}");
}
```

<br>
<br>
<br>
<br>
<br>

## Lifetimes

What happens when we run the following code?

```rust
fn longer(s1: &str, s2: &str) -> &str {
  if s1.len() >= s2.len() { s1 } else { s2 }
}

fn test() {
  let text = String::from("bat man begins");
  let first = first_word_str(&text);
  let last = last_word_str(&text);
  let longer_word = longer(first, last);
  println!("longer word: {longer_word:?}");
}
```

TODO:LIFETIMES









## Constructing Types

So far

- Rust's primitive types like `i32`, `bool`, and `char`
- References/Borrows `&T` and `&mut T`
- `let` bindings, `fn` definitions, and control flow with `if` and `;`

Next, how to write and use our own types in Rust (cf. Haskell's `data`)

1. ~~**product types** `struct`~~
2. ~~**sum types** `enum`~~
3. ~~**recursive types**~~
4. ~~**generics** `Vec<T>`, `Option<T>`, `Result<T, E>`~~

and then Rust specific features like

5. ~~**slices** `&[T]` and `&str`~~
6. ~~**lifetimes**~~

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
````
