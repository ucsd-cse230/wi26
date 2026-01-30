---
title: Ownership
headerImg: sea.jpg
---

# Ownership and Borrowing

Rust's unique approach to memory management

<br>
<br>
<br>
<br>
<br>
<br>

## What _is_ memory management?

(and why is it _hard_?)

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Little vs Big Data

**Little Data**

- _fixed_ size, _known_ at compile time
- `bool`, `char`, `i32`, `f64`, `usize`, ...
- _copies_ quickly

**Big Data**:

- _variable_ size, _unknown_ at compile time
- `String`, `Vec<T>`, `HashMap<K,V>`, ...
- _copies_ slowly

Most PLs manage memory with the **stack** and **heap**.

<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Little Data Lives on the Stack

```rust
fn main() {
    let n = 5;      // L1
    let y = inc(n); // L3
    println!("n: {}, y: {}", n, y);
}

fn inc(x: i32) -> i32 {
    x + 1           // L2
}
```

[Little data on the Stack](https://rust-book.cs.brown.edu/ch04-01-what-is-ownership.html#variables-live-in-the-stack)

![Little data lives on the stack](/static/img/variables-on-stack.png){#fig:types .align-center width=90%}

Variables live in **stack frames** mapping variables to values

- At `L1` frame for `main` holds `n = 5`
- At `L2` frame for `inc` holds `x = 5`
- At `L3` frame for `main` holds `n = 5` and `y = 6`

Frames are organized into a stack of **currently-called-functions**.

- At `L2` frame for `main` above the frame for `inc`

**Entire frame is freed** or deallocated on function return

<br>
<br>
<br>
<br>
<br>

## Little Data Copies Quickly

When an expression **reads** a little-data variable, its **value is copied** from its slot in the stack frame

![Reads Copy Variables](/static/img/copying-on-stack.png){#fig:types .align-center width=90%}

- At `L2` the value of `n` is copied into `y`

- At `L3` the value of `n` is left unchanged, even after changing `y`

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Big Data Copies _Slowly_

Cannot copy big data quickly!

![Big Data Copies Slowly](/static/img/big-data-copy-slow.png){#fig:types .align-center width=90%}

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Big data lives on the Heap

Big data is stored on the **heap**

![References Copy Quickly](/static/img/big-data-on-heap.png){#fig:types .align-center width=90%}

Can _quickly_ copy **references** to data!

... but `a` and `b` **refer to the same** data on the heap

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Sharing is Hard!

Why?

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Sharing with Manual Management (C, C++)

**Programmer** explicitly `alloc` and `free` memory

- _Zero_ runtime overhead

**Problem: Unsafe**

- Free too early (Dangling references!)
- Forget to free (Leaks!)
- Double-free (Vulnerabilities!)

<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Sharing with Garbage Collection (Java, Python, Haskell)

Runtime that looks for and _reclaims_ unused memory

- Memory _safe_ (can only use "valid" memory that has not been freed)

as the program runs; in other languages,

**Problem: Unpredictable**

- GC can kick in and introduce pauses at unpredictable times

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Sharing breaks local reasoning

(But my _personal_ reason...)

Ground can change beneath your feet!

(Makes concurrency _really_ hard)

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Rust's Secret Sauce: Ownership

The key idea in Rust's ownership system is in three rules:

1. Each value in Rust has an **owner**.
2. There can only be a **single** owner at any time.
3. Value is dropped (reclaimed) when owner **goes out of scope**.

Unique value proposition: **memory safety without GC**

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

## Ownership Ingredients

1. Scope
2. Drop
3. Ownership
4. Move/Transfer

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## 1. Scope

**Scope** is the "area" within a program for which a name is valid.

```rust
{                                 // s not valid here; not yet declared
   let s = String::from("hello"); // s is valid from this point on
   // ...
   // do stuff with s
   // ...
}                                 // scope is over; s no longer valid
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## 2. Drop/Free when Owner Goes Out of Scope

**Scope** is the "area" within a program for which a name is valid.

```rust
{                                 // s not valid here; not yet declared
   let s = String::from("hello"); // s is valid from this point on
   // ...
   // do stuff with s
   // ...
}                                 // scope is over; DROP/FREE `s`
```

![Drop when owner out of scope](/static/img/out-of-scope-drop.png){#fig:types .align-center width=90%}

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## 3. (Unique) Ownership

Heap data has a single **unique owner** ... assignment transfers or **moves** ownership.

![Move ownership on assignment](/static/img/big-data-move.png){#fig:types .align-center width=90%}

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

## QUIZ

What will be printed by this code?

```rust
fn main() {
   let a = String::from("hello"); // `a` is the unique owner
   let b = a;                     // ownership of heap data MOVED to `b`
   println!("a is {a}");          // what will be printed?
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

## 4. Move/Transfers Ownership

Assignment **moves ownernship** ... cannot then use a _moved value_

```rust
fn main() {
   let a = String::from("hello"); // `a` is the unique owner
   let b = a;                     // ownership of heap data MOVED to `b`
   println!("a is {a}");          // what will be printed?
}
```

Compiler rejects with error:

```
error[E0382]: borrow of moved value: `a`
  --> src/main.rs:20:20
   |
18 |    let a = String::from("hello");
   |        - move occurs because `a` has type `String`, which does not implement the `Copy` trait
19 |    let b = a;
   |            - value moved here
20 |    println!("a is {a}");
   |                    ^ value borrowed here after move
   |
help: consider cloning the value if the performance cost is acceptable
   |
19 |    let b = a.clone();
   |             ++++++++
```

**Notes**

1. `String` does not implement the `Copy` trait.
2. Consider `.clone()` if you want to copy data instead of moving it.

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## 4. Clone (if you really can't `move` ...)

Assignment **moves ownernship** ... cannot then use a _moved value_

... if you _must_ then you have to explicitly **clone** the data

```rust
fn main() {
   let a = String::from("hello"); // `a` is unique owner
   let b = a.clone();             // `b` is unique owner of a clone
   println!("a is {a}");          // OK
}
```

![Big data can be `cloned()`](/static/img/big-data-clone.png){#fig:types .align-center width=90%}

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Recap: Copy vs Move

Consider these two examples:

**Little Data Is Copied**

```rust
{
  let x = 5;                   // x comes into scope
  let y = x;                   // x is copied into y
  println!("x is {x}");        // x and y are both valid
}
```

**Big Data is Moved**

```rust
let x = String::from("hello"); // x comes into scope
let y = x;                     // x is moved into y
println!("x is {x}");          // ERROR: `x` value is moved!
```

## QUIZ

What happens on assignment?

```rust
fn main() {
    let s = String::from("hello");
    s = String::from("ahoy");
    println!("{s}, world!");
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

## Cannot Assign to Immutable Variable

`let x` creates an **immutable** variable by default -- you cannot re-assign it!

```rust
fn main() {
    let s = String::from("hello");  // s comes into scope
    s = String::from("ahoy");       // ERROR: cannot assign twice to immutable variable
}
```

Produces an error

```
error[E0384]: cannot assign twice to immutable variable `s`
 --> src/main.rs:7:5
  |
6 |     let s = String::from("hello");
  |         - first assignment to `s`
7 |     s = String::from("ahoy");
  |     ^ cannot assign twice to immutable variable
  |
help: consider making this binding mutable
  |
6 |     let mut s = String::from("hello");
  |         +++
```

**Read the error message carefully!**

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Re-assigning Variables

```rust
fn main() {
    let mut s = String::from("hello");  // s comes into scope
    s = String::from("ahoy");           // s is re-assigned
                                        // old value DROPPED
    println!("{s}, world!");            // prints "ahoy, world!"
}
```

<br>
<br>
<br>
<br>
<br>
<br>

## Mutating Data

`String` can be **mutated** (i.e. _changed_)

```rust
fn main() {
    let mut s = String::from("hello");
    s.push_str(", world!");  // push_str() appends a literal to a String
    println!("{s}");         // prints "hello, world!"
}
```

**QUIZ** What happens if we replace `let mut` with just `let s`?

<br>
<br>
<br>
<br>
<br>
<br>

## QUIZ: Function Calls

What happens when we run?

```rust
fn main() {
    let mut s = String::from("hello");
    call_me_string(s);
    println!("{s}, world!");
}

fn call_me_string(x: String) {
    println!("Thanks for calling me with {x}!");
}
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>

## QUIZ: Function Calls

What happens when we run?

```rust
fn main() {
    let mut s = 42;             // s comes into scope
    call_me_i32(s);
    println!("{s}, world!");    // prints "ahoy, world!"
}

fn call_me_i32(x: i32) {
    println!("Thanks for calling me with {x}!");
}
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Fn Parameters: Little Data ==> Copy

What happens when we run?

```rust
fn main() {
    let mut s = 42;
    call_me_i32(s);             // `s` is COPY into `x`
    println!("{s}, world!");    // prints "42, world!"
}

fn call_me_i32(x: i32) {
    println!("Thanks for calling me with {x}!");
}
```

Try it out on [aquascope](https://cel.cs.brown.edu/aquascope/)

- `s` is **copied** into parameter `x`
- `x` gets printed ...
- `s` is **still valid** after the call

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

## Fn Parameters: Big Data ==> Move

What happens when we run?

```rust
fn main() {
    let mut s = String::from("hello");  // s comes into scope
    call_me_string(s);                  // s is MOVED into `x`
    println!("{s}, world!");            // compile-time error!
}

fn call_me_string(x: String) {
    println!("Thanks for calling me with {x}!");
    // x goes out of scope and is DROPPED
}
```

Try it out on [aquascope](https://cel.cs.brown.edu/aquascope/)

- `s` is **moved** into parameter `x`
- `x` gets printed ...
- `s` is **not valid** after the call!

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

What happens when we run the following program?

```rust
fn burp() -> String {
    let s = String::from("burp"); // s comes into scope
    s                             // s is moved out to the caller
}

fn say_length(z: String) {
    let n = z.len();              // get length of z
    println!("length of z = {n}");
}

fn main() {
    let s1 = burp();
    println!("(a) s1 is {s1}");
    say_length(s1);
    println!("(b) s1 is {s1}");
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

## Returns Copy (Little) or Move (Big) Too!

```rust
fn burp() -> String {
    let s = String::from("burp"); // `s` comes into scope
    s                             // `s` is moved out to the caller
}

fn say_length(z: String) {
    let n = z.len();              // get length of `z`
    println!("length of z = {n}");
}                                 // `z` goes out of scope and is DROPPED


fn main() {
    let s1 = burp();             // burp() moves its return into s1
    println!("(a) s1 is {s1}");
    say_length(s1);              // s1 is moved into say_length()
    println!("(b) s1 is {s1}");  // ERROR: s1 value is MOVED!
}
```

**QUIZ** How to _modify_ `say_length` so we can print `s1` **after the call**?

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

## Don't drop, return

![Don't drop, return](/static/img/drake-drop-return.png){#fig:types .align-center width=90%}

```rust
fn say_length(z: String) -> String {
    let n = z.len();              // get length of `z`
    println!("length of z = {n}");
    z                             // `z` MOVED to return value
}


fn main() {
    let s1 = burp();             // burp() moves its return into s1
    println!("(a) s1 is {s1}");  // prints "(a) s1 is burp"
    let s1 = say_length(s1);     // s1 is moved into say_length()
    println!("(b) s1 is {s1}");  // prints "(b) s1 is burp"
}
```

... but seriously, this is rather clunky!

## How to simplify `say_length`?

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Rust's Secret Sauce: Ownership + Borrowing

Unique value proposition: **memory safety without GC**

1. Each value in Rust has an **owner**.
2. There can only be a **single** owner at any time.
3. Value is dropped (reclaimed) when owner **goes out of scope**.

To "access" data, no need to _take ownership_, just **borrow**

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Borrowing with References

`&T` is a **reference** to a value of type `T`

```rust
fn say(z: &String) {    // L2 `z` is a reference to a String
    let n = z.len();    //     get length of `z`
    println!("length of z = {n}");
}                       // `z` exits scope, but NOT DROPPED, `z` NOT-OWNER
```

So `say_length` takes a **reference** to a `String`

```rust
fn main() {
    let s = read_file("moby_dick.txt"); // L1 read_file() moves its return into `s`
    say(&s);                            // `s` BORROWED by say()
                                        // L3 `s` RETURNED by say()
}                                       // `s` exits scope, is DROPPED
```

You can **borrow** from the **owner** but you have to **give it back**

![data can be borrowed](/static/img/string-borrow.png){#fig:types .align-center width=90%}

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Rust's Secret Sauce: Ownership + Borrowing

Unique value proposition: **memory safety without GC**

1. Each value in Rust has an **owner**.
2. There can only be a **single** owner at any time.
3. Value is dropped (reclaimed) when owner **goes out of scope**.

To "access" data, no need to _take ownership_, just **borrow**

- `&T` gives a _reference_ to a `T` i.e. lets you _borrow access_ to `T`

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Mutating through References

Recall that `String` can be **mutated** (i.e. _changed_) e.g.

```rust
fn main() {
    let mut s = String::from("yo!");
    s.push_str(", world!");
    println!("{s}"); // prints out "yo!, world!"
}
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>

## QUIZ

What happens if we try

```rust
fn main() {
    let mut s = String::from("yo!");
    change(s);
    println!("{s}");
}

fn change(z: &String) {
    z.push_str(", world!");
}
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Mutating Requires Mutable References (Borrows)

We can only _mutate_ data through a **mutable reference** `&mut T`

```rust
fn main() {
    let mut s = String::from("yo!");
    change(&mut s);
    println!("{s}");
}

fn change(z: &mut String) {
    z.push_str(", world!");
}
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>

## QUIZ

What about littled data? For example, what happens if we try

```rust
fn main() {
    let x = 42;
    say(&x);
    println!("haha {x}");
}

fn say(z: &i32) {
    println!("hoho {x}");
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

Prints

```
hoho 42
haha 42
```

## QUIZ

What happens if we try

```rust
fn main() {
    let x = 42;
    change(&x);
    println!("haha {x}");
}

fn change(z: &i32) {
    z = z + 1;
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

Compiler error!

1. Can't do `z + 1` as `z` is a reference;
2. Can't re-assign `z` as it is an immutable reference!

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

## (Re)-Assignment Requires Mutable References (Borrows)

We can only _reassign_ data through a **mutable reference** `&mut T`

```rust
fn main() {
    let mut x = 42;
    change(&mut x);
    println!("haha {x}");
}

fn change(z: &mut i32) {
    *z = *z + 1;
}
```

![Updating Data on Stack](/static/img/aqua-stack-update.png){#fig:types .align-center width=90%}

<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Rust's Secret Sauce: Ownership + Borrowing

Unique value proposition: **memory safety without GC**

1. Each value in Rust has an **owner**.
2. There can only be a **single** owner at any time.
3. Value is dropped (reclaimed) when owner **goes out of scope**.

To "access" data, no need to _take ownership_, just **borrow**

- `&T` gives a _reference_ to a `T` i.e. lets you _read access_ to `T`
- `&mut T` gives a _mutable reference_ to a `T` i.e. lets you _borrow access and mutate_ `T`

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## References are Read-Only

## Mutable References

## Material Inspired by

- https://rust-book.cs.brown.edu/ch04-01-what-is-ownership.html
- https://doc.rust-lang.org/book/ch04-01-what-is-ownership.html
