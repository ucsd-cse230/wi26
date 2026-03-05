---
title: Lifetimes
headerImg: sea.jpg
---

# Lifetimes

Ensuring references are valid

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Recap: Ownership + Borrowing

1. Each value in Rust has an **owner**.
2. There can only be a **single** owner at any time.
3. Value is dropped (reclaimed) when owner **goes out of scope**.

To "access" data, no need to _take ownership_, just **borrow**

- `&T` gives a _shared reference_ (read access)
- `&mut T` gives a _mutable reference_ (write access)
- **Sharing XOR Mutability**: many `&T` or single `&mut T`

Today: how does Rust know when a borrow is **valid**?

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Goal Today: Lifetimes

- [ ] Dangling References
- [ ] The Borrow Checker
- [ ] Lifetime Annotations
- [ ] Lifetimes in Functions
- [ ] Lifetimes in Structs
- [ ] Lifetime Elision

<br>
<br>
<br>
<br>
<br>
<br>
<br>

## QUIZ

What happens when we run this code?

```rust
fn main() {
    let r;
    {
        let x = 5;
        r = &x;
    }
    println!("r: {r}");
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

## Dangling References

`x` goes out of scope _before_ `r` is used!

```
error[E0597]: `x` does not live long enough
 --> src/main.rs:6:13
  |
5 |         let x = 5;
  |             - binding `x` declared here
6 |         r = &x;
  |             ^^ borrowed value does not live long enough
7 |     }
  |     - `x` dropped here while still borrowed
8 |
9 |     println!("r: {r}");
  |                   - borrow later used here
```

If Rust allowed this, `r` would point to **freed** memory!

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Goal Today: Lifetimes

- [+] Dangling References: references must not outlive the data they point to
- [ ] The Borrow Checker
- [ ] Lifetime Annotations
- [ ] Lifetimes in Functions
- [ ] Lifetimes in Structs
- [ ] Lifetime Elision

<br>
<br>
<br>
<br>
<br>
<br>

## The Borrow Checker

How does Rust know the reference is invalid?

The **borrow checker** compares the _lifetimes_ (i.e. scopes) of references and the data they refer to.

```rust
fn main() {
    let r;                // ---------+-- 'a
                          //          |
    {                     //          |
        let x = 5;        // -+-- 'b  |
        r = &x;           //  |       |
    }                     // -+       |
                          //          |
    println!("r: {r}");   //          |
}                         // ---------+
```

- `r` has lifetime `'a` (outer scope)
- `x` has lifetime `'b` (inner scope)
- `'b` is **shorter** than `'a` ... so `r` could be a **dangling reference**!

The borrow checker **rejects** the program.

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Valid Reference: Data Outlives the Reference

```rust
fn main() {
    let x = 5;            // ----------+-- 'b
                           //           |
    let r = &x;           // --+-- 'a  |
                           //   |       |
    println!("r: {r}");   //   |       |
                           // --+       |
}                          // ----------+
```

Here `x` has lifetime `'b` which is **longer** than `r`'s lifetime `'a`.

The borrow checker **accepts** the program.

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Goal Today: Lifetimes

- [+] Dangling References: references must not outlive the data they point to
- [+] The Borrow Checker: compares scopes to ensure borrows are valid
- [ ] Lifetime Annotations
- [ ] Lifetimes in Functions
- [ ] Lifetimes in Structs
- [ ] Lifetime Elision

<br>
<br>
<br>
<br>
<br>
<br>

## QUIZ

Recall from last lecture: what happens when we compile this?

```rust
fn longer(s1: &str, s2: &str) -> &str {
    if s1.len() >= s2.len() { s1 } else { s2 }
}

fn main() {
    let text = String::from("bat man begins");
    let first = &text[0..3];
    let last = &text[8..14];
    let result = longer(first, last);
    println!("longer word: {result}");
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

## Problem: Which Reference Does the Return Come From?

The compiler doesn't know if the return value comes from `s1` or `s2`!

```
error[E0106]: missing lifetime specifier
 --> src/main.rs:1:35
  |
1 | fn longer(s1: &str, s2: &str) -> &str {
  |               ----      ----     ^ expected named lifetime parameter
  |
  = help: this function's return type contains a borrowed value,
          but the signature does not say whether it is borrowed
          from `s1` or `s2`
help: consider introducing a named lifetime parameter
  |
1 | fn longer<'a>(s1: &'a str, s2: &'a str) -> &'a str {
  |          ++++      ++           ++           ++
```

**Read the error message!** It tells us to add a **lifetime parameter** `'a`.

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Why is the Borrow Checker Confused?

Consider two possible callers:

```rust
fn test_ok() {
    let s1 = String::from("hello");
    let s2 = String::from("hi");
    let result = longer(&s1, &s2);  // both live long enough
    println!("{result}");           // OK!
}
```

```rust
fn test_bad() {
    let s1 = String::from("hello");
    let result;
    {
        let s2 = String::from("hi");
        result = longer(&s1, &s2);   // s2 about to die!
    }
    println!("{result}");             // YIKES: result might point to dead s2!
}
```

The borrow checker can't tell _from the function signature alone_ how long the return value lives.

We have to **tell it** using lifetime annotations!

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Lifetime Annotation Syntax

Lifetime annotations describe **relationships** between lifetimes of references.

- Start with an apostrophe `'`
- Usually short, lowercase: `'a`, `'b`, etc.
- Placed after the `&` in a reference type

```rust
&i32            // a reference (implicit lifetime)
&'a i32         // a reference with explicit lifetime 'a
&'a mut i32     // a mutable reference with explicit lifetime 'a
```

**Note**: Annotations don't _change_ how long a reference lives.
They just **describe** the relationships between lifetimes.

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Goal Today: Lifetimes

- [+] Dangling References: references must not outlive the data they point to
- [+] The Borrow Checker: compares scopes to ensure borrows are valid
- [+] Lifetime Annotations: `&'a T` to describe relationships between lifetimes
- [ ] Lifetimes in Functions
- [ ] Lifetimes in Structs
- [ ] Lifetime Elision

<br>
<br>
<br>
<br>
<br>
<br>

## Lifetime Annotations in Functions

Add a **generic lifetime parameter** `'a` to the function signature

```rust
fn longer<'a>(s1: &'a str, s2: &'a str) -> &'a str {
    if s1.len() >= s2.len() { s1 } else { s2 }
}
```

This signature says:

- For some lifetime `'a`,
- both `s1` and `s2` must live **at least** as long as `'a`,
- and the returned reference also lives **at least** as long as `'a`.

In practice: `'a` is the **shorter** of the two input lifetimes.

### Haskell Comparison

There's no equivalent in Haskell because Haskell has GC!

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## QUIZ

Does this code compile and run?

```rust
fn longer<'a>(s1: &'a str, s2: &'a str) -> &'a str {
    if s1.len() >= s2.len() { s1 } else { s2 }
}

fn main() {
    let s1 = String::from("long string is long");
    {
        let s2 = String::from("xyz");
        let result = longer(s1.as_str(), s2.as_str());
        println!("The longer string is: {result}");
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

## Yes! Both References Are Valid When Used

```rust
fn main() {
    let s1 = String::from("long string is long"); // ---+-- 'a
    {                                             //    |
        let s2 = String::from("xyz");             // -+-|-- 'b
        let result = longer(                      //  | |
            s1.as_str(),                          //  | |
            s2.as_str()                           //  | |
        );                                        //  | |
        println!("longer: {result}");             //  | |  OK!
    }                                             // -+ |
}                                                 // ---+
```

`result` is used _inside_ the inner scope where **both** `s1` and `s2` are alive.

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## QUIZ

What about this code?

```rust
fn longer<'a>(s1: &'a str, s2: &'a str) -> &'a str {
    if s1.len() >= s2.len() { s1 } else { s2 }
}

fn main() {
    let s1 = String::from("long string is long");
    let result;
    {
        let s2 = String::from("xyz");
        result = longer(s1.as_str(), s2.as_str());
    }
    println!("The longer string is: {result}");
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

## No! `result` Might Point to Dead Data

```
error[E0597]: `s2` does not live long enough
 --> src/main.rs:6:44
  |
5 |         let s2 = String::from("xyz");
  |             -- binding `s2` declared here
6 |         result = longer(s1.as_str(), s2.as_str());
  |                                      ^^ borrowed value does not live long enough
7 |     }
  |     - `s2` dropped here while still borrowed
8 |     println!("The longer string is: {result}");
  |                                       ------ borrow later used here
```

Even though `longer` would return `s1` (which is longer), the compiler
doesn't know that! The signature says `result` lives as long as the **shorter** lifetime.

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Thinking in Terms of Lifetimes

The lifetime parameters depend on what the function **does**.

If `longer` _always_ returned the first argument, we'd only need:

```rust
fn longer<'a>(s1: &'a str, s2: &str) -> &'a str {
    s1
}
```

No need to relate the lifetime of `s2` to the return value!

**Key idea**: annotate the _relationships_ between the inputs and outputs that actually exist.

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## QUIZ

What happens when we compile this?

```rust
fn longer<'a>(s1: &str, s2: &str) -> &'a str {
    let result = String::from("really long string");
    result.as_str()
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

## Cannot Return a Reference to a Local Variable!

```
error[E0515]: cannot return value referencing local variable `result`
  --> src/main.rs:3:5
   |
3  |     result.as_str()
   |     ------^^^^^^^^^
   |     |
   |     returns a value referencing data owned by the current function
```

`result` is **dropped** when `longer` returns, so we'd get a dangling reference.

**Fix**: return an _owned_ value instead of a reference

```rust
fn longer(s1: &str, s2: &str) -> String {
    let result = String::from("really long string");
    result    // ownership transferred to caller
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

## Goal Today: Lifetimes

- [+] Dangling References: references must not outlive the data they point to
- [+] The Borrow Checker: compares scopes to ensure borrows are valid
- [+] Lifetime Annotations: `&'a T` to describe relationships between lifetimes
- [+] Lifetimes in Functions: `fn foo<'a>(x: &'a T, ...) -> &'a T`
- [ ] Lifetimes in Structs
- [ ] Lifetime Elision

<br>
<br>
<br>
<br>
<br>
<br>

## Lifetimes in Structs

What if a `struct` holds a **reference**?

```rust
#[derive(Debug)]
struct Excerpt {
    part: &str,
}
```

Compiler error!

```
error[E0106]: missing lifetime specifier
 --> src/main.rs:3:11
  |
3 |     part: &str,
  |           ^ expected named lifetime parameter
  |
help: consider introducing a named lifetime parameter
  |
2 ~ struct Excerpt<'a> {
3 ~     part: &'a str,
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Lifetimes in Structs: the Fix

The struct must **declare** the lifetime of its reference fields

```rust
#[derive(Debug)]
struct Excerpt<'a> {
    part: &'a str,
}
```

This says: an `Excerpt` cannot **outlive** the reference it holds in `part`.

```rust
fn main() {
    let novel = String::from("Call me Ishmael. Some years ago...");
    let first_sentence = novel.split('.').next().unwrap();
    let exc = Excerpt { part: first_sentence };
    println!("{:?}", exc);
}
```

Here `novel` outlives `exc`, so the reference is valid.

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## QUIZ

What happens when we compile this?

```rust
#[derive(Debug)]
struct Excerpt<'a> {
    part: &'a str,
}

fn main() {
    let exc;
    {
        let novel = String::from("Call me Ishmael.");
        exc = Excerpt { part: &novel };
    }
    println!("{:?}", exc);
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

## Struct Cannot Outlive its Reference!

```
error[E0597]: `novel` does not live long enough
  --> src/main.rs:9:33
   |
8  |         let novel = String::from("Call me Ishmael.");
   |             ----- binding `novel` declared here
9  |         exc = Excerpt { part: &novel };
   |                                ^^^^^ borrowed value does not live long enough
10 |     }
   |     - `novel` dropped here while still borrowed
11 |     println!("{:?}", exc);
   |                      --- borrow later used here
```

`novel` is dropped at end of inner scope, but `exc` lives longer, so the reference is **invalid**.

Same idea as with function lifetimes: the borrow checker ensures the data **outlives** the struct.

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Goal Today: Lifetimes

- [+] Dangling References: references must not outlive the data they point to
- [+] The Borrow Checker: compares scopes to ensure borrows are valid
- [+] Lifetime Annotations: `&'a T` to describe relationships between lifetimes
- [+] Lifetimes in Functions: `fn foo<'a>(x: &'a T, ...) -> &'a T`
- [+] Lifetimes in Structs: `struct Foo<'a> { field: &'a T }`
- [ ] Lifetime Elision

<br>
<br>
<br>
<br>
<br>
<br>

## Lifetime Elision

Hang on ... we wrote functions with `&` references _before_ and never needed lifetimes!

```rust
fn first_word_str(s: &String) -> &str {
    ...
}
```

Why didn't the compiler complain?

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Lifetime Elision Rules

The compiler applies **elision rules** to infer lifetimes automatically.

**Rule 1**: Each reference parameter gets its own lifetime parameter.

```rust
fn foo(x: &i32)              // ==> fn foo<'a>(x: &'a i32)
fn foo(x: &i32, y: &i32)     // ==> fn foo<'a, 'b>(x: &'a i32, y: &'b i32)
```

**Rule 2**: If there's _exactly one_ input lifetime, it's assigned to all outputs.

```rust
fn foo(x: &i32) -> &i32      // ==> fn foo<'a>(x: &'a i32) -> &'a i32
```

**Rule 3**: If one of the inputs is `&self` or `&mut self`, the lifetime of `self` is assigned to all outputs.

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Elision Example 1: Single Reference Parameter

```rust
fn first_word_str(s: &String) -> &str { ... }
```

Applying the rules:

1. **Rule 1**: `s` gets lifetime `'a` ==> `fn first_word_str<'a>(s: &'a String) -> &str`
2. **Rule 2**: one input lifetime, assign to output ==> `fn first_word_str<'a>(s: &'a String) -> &'a str`

All output lifetimes resolved! No explicit annotations needed.

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Elision Example 2: Two Reference Parameters

```rust
fn longer(s1: &str, s2: &str) -> &str { ... }
```

Applying the rules:

1. **Rule 1**: each gets a lifetime ==> `fn longer<'a, 'b>(s1: &'a str, s2: &'b str) -> &str`
2. **Rule 2**: does NOT apply (two input lifetimes, not one)
3. **Rule 3**: does NOT apply (not a method)

Output lifetime is **unresolved** ... compiler **requires** annotation!

```rust
fn longer<'a>(s1: &'a str, s2: &'a str) -> &'a str { ... }
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

Does this need explicit lifetime annotations?

```rust
fn say(z: &String) {
    let n = z.len();
    println!("length of z = {n}");
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

## No! No Output References

`say` returns nothing (no output references), so no lifetime annotations are needed.

Rule 1 assigns `'a` to `z`, but there's no output to annotate.

**Lifetimes are only needed when the function _returns_ a reference** (or when a struct _holds_ a reference).

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## The `'static` Lifetime

One special lifetime: `'static` means the reference lives for the **entire program**.

```rust
let s: &'static str = "I have a static lifetime.";
```

All string _literals_ have the `'static` lifetime because they are baked into the binary.

**Warning**: Don't use `'static` as a band-aid to fix lifetime errors!

If the compiler suggests `'static`, it usually means there's a real bug -- fix the underlying problem instead.

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Goal Today: Lifetimes

- [+] Dangling References: references must not outlive the data they point to
- [+] The Borrow Checker: compares scopes to ensure borrows are valid
- [+] Lifetime Annotations: `&'a T` to describe relationships between lifetimes
- [+] Lifetimes in Functions: `fn foo<'a>(x: &'a T, ...) -> &'a T`
- [+] Lifetimes in Structs: `struct Foo<'a> { field: &'a T }`
- [+] Lifetime Elision: compiler infers lifetimes in common cases

<br>
<br>
<br>
<br>
<br>
<br>

## QUIZ

```rust
fn quiz1<'a>(x: &'a str) -> &'a str {
    x
}
```

```rust
fn quiz2<'a>(x: &'a str) -> &'a str {
    let s = String::from("hello");
    s.as_str()
}
```

```rust
fn quiz3<'a>(x: &'a str, y: &'a str) -> &'a str {
    if x.len() > 0 { x } else { y }
}
```

```rust
fn quiz4<'a, 'b>(x: &'a str, y: &'b str) -> &'a str {
    x
}
```

Which of these compile?

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Answers

- `quiz1`: **compiles** -- returns `x` which has lifetime `'a`
- `quiz2`: **error** -- returns reference to local `s` which is dropped!
- `quiz3`: **compiles** -- both `x` and `y` have lifetime `'a`, return has lifetime `'a`
- `quiz4`: **compiles** -- always returns `x` with lifetime `'a`, `y`'s lifetime `'b` is unrelated

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Summary: Lifetimes

Lifetimes are Rust's way of ensuring **memory safety at compile time**

- **Dangling references** are prevented by the **borrow checker**
- The borrow checker compares **scopes** to validate borrows
- **Lifetime annotations** (`'a`) describe relationships between reference lifetimes
- The compiler uses **elision rules** to infer lifetimes in common cases
- `'static` is a special lifetime for data that lives the entire program

All of this happens at **compile time** -- zero runtime overhead!

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Material Inspired by

- https://doc.rust-lang.org/book/ch10-03-lifetime-syntax.html
- https://rust-book.cs.brown.edu/ch04-01-what-is-ownership.html
