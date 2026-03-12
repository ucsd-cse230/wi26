---
title: Concurrency
headerImg: sea.jpg
---

# Fearless Concurrency

Safe concurrent programming with Rust

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Why Concurrency?

Modern hardware has many cores -- we want to use them all!

But concurrent programming is **notoriously hard**:

- **Data races**: two threads access shared data at the same time
- **Deadlocks**: two threads wait for each other forever
- **Hard to reproduce**: bugs depend on scheduling, appear randomly

In most languages, these bugs show up **at runtime** (if you're lucky).

In Rust, the compiler catches them **at compile time**.

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Goal Today

- [ ] Threads
- [ ] Message Passing (Channels)
- [ ] Shared State (Mutex)
- [?] Send and Sync

<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Creating Threads

Use `thread::spawn` with a closure

```rust
fn test_spawn() {
    thread::spawn(|| {
        for i in 1..10 {
            println!("spawned: {i}");
            thread::sleep(Duration::from_millis(1));
        }
    });

    for i in 1..3 {
        println!("main: {i}");
        thread::sleep(Duration::from_millis(1));
    }
}
```

Output (varies each run!):

```
main: 1
spawned: 1
main: 2
spawned: 2
spawned: 3
```

**Boo!**: when `main` ends, spawned threads are **killed** -- even if **not finished**!

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Waiting for Threads with `join`

`thread::spawn` returns a `JoinHandle`; calling `.join()` **waits** for the thread to finish

```rust
use std::thread;
use std::time::Duration;

fn test_spawn_join() {
    let handle = thread::spawn(|| {
        for i in 1..10 {
            println!("spawned: {i}");
            thread::sleep(Duration::from_millis(1));
        }
    });

    for i in 1..3 {
        println!("main: {i}");
        thread::sleep(Duration::from_millis(1));
    }

    handle.join().unwrap();  // wait for spawned thread to finish
}
```

`handle.join()` forces the main thread to wait for the spawned thread to finish.

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
fn test_spawn_with_vec() {
    let v = vec![1, 2, 3];

    let handle = thread::spawn(|| {
        println!("Here's a vector: {v:?}");
    });

    handle.join().unwrap();
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

## Threads and Ownership: The Problem

The closure **borrows** `v`, but the spawned thread might outlive `main`!

```
error[E0373]: closure may outlive the current function,
              but it borrows `v`, which is owned by the current function
 --> src/main.rs:6:32
  |
6 |     let handle = thread::spawn(|| {
  |                                ^^ may outlive borrowed value `v`
7 |         println!("Here's a vector: {v:?}");
  |                                     - `v` is borrowed here
  |
help: to force the closure to take ownership of `v`,
      use the `move` keyword
  |
6 |     let handle = thread::spawn(move || {
  |                                ++++
```

What if `main` dropped `v` before the thread used it? **Dangling reference**!

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Fix: `move` Closures

Use `move` to **transfer ownership** of `v` into the thread

```rust
use std::thread;

fn main() {
    let v = vec![1, 2, 3];

    let handle = thread::spawn(move || {
        println!("Here's a vector: {v:?}");
    });

    handle.join().unwrap();
}
```

Now the thread **owns** `v`. Main can no longer use it.

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## QUIZ

What happens here?

```rust
use std::thread;

fn main() {
    let v = vec![1, 2, 3];

    let handle = thread::spawn(move || {
        println!("Here's a vector: {v:?}");
    });

    println!("v is: {v:?}");
    handle.join().unwrap();
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

## Cannot Use `v` After Move!

```
error[E0382]: borrow of moved value: `v`
  --> src/main.rs:10:22
   |
4  |     let v = vec![1, 2, 3];
   |         - move occurs because `v` has type `Vec<i32>`,
              which does not implement the `Copy` trait
6  |     let handle = thread::spawn(move || {
   |                                ------- value moved into closure here
7  |         println!("Here's a vector: {v:?}");
   |                                     - variable moved due to use in closure
...
10 |     println!("v is: {v:?}");
   |                      ^ value borrowed here after move
```

The ownership rules we already know prevent sharing data unsafely between threads!

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Goal Today

- [+] Threads: `thread::spawn`, `move` closures, `join()`
- [ ] Message Passing (Channels)
- [ ] Shared State (Mutex)
- [?] Send and Sync

<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Message Passing with Channels

"Do not communicate by sharing memory; instead, share memory by communicating." -- Go proverb

A **channel** has two ends:

- **Transmitter** (`tx`): sends data
- **Receiver** (`rx`): receives data

The channel is **closed** when either end is dropped.

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Creating a Channel

```rust
use std::sync::mpsc;
use std::thread;

fn test_channel() {
    let (tx, rx) = mpsc::channel();

    thread::spawn(move || {
        let msg = String::from("hello");
        tx.send(msg).unwrap();
    });

    let received = rx.recv().unwrap();
    println!("Got: {received}");
}
```

When you run this

```
Got: hello
```

- `mpsc` = **multiple producer, single consumer**
- `tx.send(msg)` sends a value (transfers ownership!)
- `rx.recv()` **blocks** until a value arrives

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## QUIZ

What happens here?

```rust
use std::sync::mpsc;
use std::thread;

fn main() {
    let (tx, rx) = mpsc::channel();

    thread::spawn(move || {
        let msg = String::from("hello");
        tx.send(msg).unwrap();
        println!("sent: {msg}");
    });

    let received = rx.recv().unwrap();
    println!("Got: {received}");
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

## `send` Transfers Ownership!

```
error[E0382]: borrow of moved value: `msg`
  --> src/main.rs:10:27
   |
 8 |         let msg = String::from("hello");
   |             --- move occurs because `msg` has type `String`,
                  which does not implement the `Copy` trait
 9 |         tx.send(msg).unwrap();
   |                 --- value moved here
10 |         println!("sent: {msg}");
   |                          ^^^ value borrowed here after move
```

`send` takes **ownership** of `msg` -- you can't use it afterwards.

... **but why???**

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

This _prevents the sender from modifying data_ while the receiver reads it!

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Sending Multiple Values

```rust
use std::sync::mpsc;
use std::thread;
use std::time::Duration;

fn test_multiple_messages() {
    let (tx, rx) = mpsc::channel();

    thread::spawn(move || {
        let msgs = vec!["hello", "from", "the", "other", "side"];
        for msg in msgs {
            tx.send(String::from(msg)).unwrap();
            thread::sleep(Duration::from_millis(500));
        }
    });

    for received in rx {         // rx works as an iterator!
        println!("Got: {received}");
    }
}
```

When we run it, we get

```
Got: hello
Got: from
Got: the
Got: other
Got: side
```

The `for` loop over `rx` is an _iterator_ that:

1. **blocks** waiting for values and
2. **finishes** when the channel closes.

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Multiple Producers

Clone `tx` to send from **multiple** threads to the **same** receiver

```rust
use std::sync::mpsc;
use std::thread;

fn test_multiple_producers() {
    let (tx1, rx) = mpsc::channel();

    let tx2 = tx1.clone();
    thread::spawn(move || {
        let msgs = vec!["hello", "from", "the", "other", "side"];
        for msg in msgs {
            tx1.send(String::from(msg)).unwrap();
        }
    });

    thread::spawn(move || {
        let msgs = vec!["i", "must've", "called", "a", "thousand", "times"];
        for msg in msgs {
            tx2.send(String::from(msg)).unwrap();
        }
    });

    for received in rx {
        println!("Got: {received}");
    }
}
```

Output order is **nondeterministic** -- depends on scheduling!

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Goal Today

- [+] Threads: `thread::spawn`, `move` closures, `join()`
- [+] Message Passing: `mpsc::channel()`, `send`, `recv`, multiple producers
- [ ] Shared State (Mutex)
- [?] Send and Sync

<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Shared State: Mutex

Sometimes threads need to **share** data (not just pass messages).

**Examples?**

- ???
- ???

<br>
<br>
<br>
<br>
<br>
<br>

A **Mutex** (mutual exclusion) guards shared data:

1. **Lock** the mutex before accessing data
2. Use the data
3. **Unlock** when done (happens automatically!)

Like a microphone at a panel discussion -- only one speaker at a time.

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Using `Mutex<T>`

```rust
use std::sync::Mutex;

fn main() {
    let m = Mutex::new(5);

    {
        let mut num = m.lock().unwrap(); // acquire lock
        *num = 6;                        // mutate the data
    }                                    // lock released automatically!

    println!("m = {:?}", m); // m = Mutex { data: 6 }
}
```

- `Mutex::new(5)` wraps the value `5` in a mutex
- `.lock()` blocks until the lock is acquired; returns a `MutexGuard`
- `MutexGuard` auto-unlocks when it goes **out of scope** (like `Drop`)

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## QUIZ

What happens here?

```rust
fn test_mutex_many() {
    let counter = Mutex::new(0);
    let mut handles = vec![];

    for _ in 0..10 {
        let handle = thread::spawn(move || {
            let mut num = counter.lock().unwrap();
            *num += 1;
        });
        handles.push(handle);
    }

    for handle in handles {
        handle.join().unwrap();
    }

    println!("Result: {}", *counter.lock().unwrap());
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

## Cannot Move `counter` Into Multiple Threads!

```
error[E0382]: borrow of moved value: `counter`
  --> src/main.rs:15:29
   |
5  |     let counter = Mutex::new(0);
   |         ------- move occurs because `counter` has type `Mutex<i32>`,
                     which does not implement the `Copy` trait
...
9  |         let handle = thread::spawn(move || {
   |                                    ------- value moved into closure here
10 |             let mut num = counter.lock().unwrap();
   |                           ------- use occurs due to use in closure
...
```

`counter` gets moved into the **first** thread's closure.
The second iteration tries to move it again -- but it's already gone!

We need **multiple ownership** across threads.

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

<!--

## Attempt: `Rc<Mutex<T>>`?

Maybe `Rc` (reference counting) can give us multiple owners?

```rust
use std::rc::Rc;
use std::sync::Mutex;
use std::thread;

fn main() {
    let counter = Rc::new(Mutex::new(0));
    let mut handles = vec![];

    for _ in 0..10 {
        let counter = Rc::clone(&counter);
        let handle = thread::spawn(move || {
            let mut num = counter.lock().unwrap();
            *num += 1;
        });
        handles.push(handle);
    }
    // ...
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

-->

<!--

## `Rc` is NOT Thread-Safe!

```
error[E0277]: `Rc<Mutex<i32>>` cannot be sent between threads safely

11 | let handle = thread::spawn(move || {
| ------------- ^------
| | |
| | `Rc<Mutex<i32>>` cannot be sent
| | between threads safely
| required by a bound introduced by this call
|
= help: the trait `Send` is not implemented for `Rc<Mutex<i32>>`

```

`Rc` updates its reference count **without** thread-safe synchronization.
Two threads incrementing the count at the same time could corrupt it!

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

--->

## Solution: `Arc<T>` (Atomic Reference Counting)

`Arc<T>` uses **atomic** operations to allow multiple sharers across threads!

- "RC" is for **Reference Counting**; data tracks how many owners there are
- "A" is for **Atomic**; reference count updates are thread-safe
- Data is "dropped" when number of owners goes to `0`

```rust
fn test_mutex_many() {
    let counter = Arc::new(Mutex::new(0));
    let mut handles = vec![];

    for _ in 0..10 {
        let counter = Arc::clone(&counter);
        let handle = thread::spawn(move || {
            let mut num = counter.lock().unwrap();
            *num += 1;
        });
        handles.push(handle);
    }

    for handle in handles {
        handle.join().unwrap();
    }

    println!("Result: {}", *counter.lock().unwrap());
}
```

```
Result: 10
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## `Arc` + `Mutex`: The Pattern

<!-- | Single-threaded  | Multi-threaded  |
| ---------------- | --------------- |
| `Rc<T>`          | `Arc<T>`        |
| `RefCell<T>`     | `Mutex<T>`      |
| `Rc<RefCell<T>>` | `Arc<Mutex<T>>` | -->

- `Arc` gives multiple ownership across threads
- `Mutex` gives interior mutability (only one writer at a time)
- Together: **shared mutable state** that is safe

**Note**: `Arc` has a performance cost (atomic operations).

(Sometimes, when you need multiple owners in _single-threaded_ code, use `Rc` instead.)

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Goal Today

- [+] Threads: `thread::spawn`, `move` closures, `join()`
- [+] Message Passing: `mpsc::channel()`, `send`, `recv`, multiple producers
- [+] Shared State: `Mutex<T>`, `Arc<T>`, `Arc<Mutex<T>>`
- [?] Send and Sync

<br>
<br>
<br>
<br>
<br>
<br>
<br>

<!--
## `Send` and `Sync` Traits

How does Rust **know** what's safe to use across threads?

Two **marker traits** (no methods, just labels):

- **`Send`**: ownership of a value can be **transferred** to another thread
- **`Sync`**: a value can be **referenced** from multiple threads (`&T` is `Send`)

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## `Send`: Safe to Transfer Between Threads

Almost all types are `Send`. Notable exceptions:

- `Rc<T>` is **not** `Send` (reference count is not atomic)
- Raw pointers are **not** `Send`

`Arc<T>` **is** `Send` -- that's why it works with `thread::spawn`.

`thread::spawn` **requires** its closure to be `Send`:

```rust
// simplified signature
pub fn spawn<F>(f: F) -> JoinHandle<T>
where
    F: FnOnce() -> T + Send + 'static,
```

If you try to send a non-`Send` type to another thread, the **compiler rejects it**.

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## `Sync`: Safe to Share Between Threads

A type `T` is `Sync` if `&T` is `Send` (i.e., safe to share a reference across threads).

Notable types that are **not** `Sync`:

- `Rc<T>` -- not safe to share
- `RefCell<T>` -- runtime borrow checking is not thread-safe
- `Cell<T>` -- interior mutation without synchronization

`Mutex<T>` **is** `Sync` -- that's the whole point!

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## `Send` and `Sync` are Automatic

You (almost) never implement these traits manually.

A type is `Send` if **all** its fields are `Send`.

A type is `Sync` if **all** its fields are `Sync`.

```rust
struct MyData {
    name: String,       // String is Send + Sync
    count: i32,         // i32 is Send + Sync
}
// MyData is automatically Send + Sync!
```

```rust
struct NotThreadSafe {
    data: Rc<i32>,      // Rc is NOT Send, NOT Sync
}
// NotThreadSafe is NOT Send, NOT Sync!
```

The compiler figures this out automatically -- no annotations needed.

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## QUIZ

Which of these compile?

```rust
// (A)
use std::thread;
fn quiz_a() {
    let x = 42;
    thread::spawn(move || println!("{x}"));
}
```

```rust
// (B)
use std::thread;
use std::rc::Rc;
fn quiz_b() {
    let x = Rc::new(42);
    thread::spawn(move || println!("{x}"));
}
```

```rust
// (C)
use std::thread;
use std::sync::Arc;
fn quiz_c() {
    let x = Arc::new(42);
    let y = Arc::clone(&x);
    thread::spawn(move || println!("{y}"));
    println!("{x}");
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

## Answers

- **(A) Compiles**: `i32` is `Send`; `move` transfers ownership to the thread.
- **(B) Error**: `Rc<i32>` is **not** `Send`; the compiler rejects it.
- **(C) Compiles**: `Arc<i32>` is `Send`; `y` is moved to the thread, `x` stays in `main`.

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
--->

## Goal Today

- [+] Threads: `thread::spawn`, `move` closures, `join()`
- [+] Message Passing: `mpsc::channel()`, `send`, `recv`, multiple producers
- [+] Shared State: `Mutex<T>`, `Arc<T>`, `Arc<Mutex<T>>`
- [?] Send and Sync: compiler-checked thread safety

<br>
<br>
<br>
<br>
<br>
<br>

## Summary: Fearless Concurrency

Rust prevents concurrency bugs **at compile time** using the same tools we already know:

- **Ownership** prevents data races (only one owner)
- **Borrowing** prevents dangling references across threads
- **`Send`/`Sync` traits** prevent non-thread-safe types from crossing thread boundaries

| Tool            | What it does                                   |
| --------------- | ---------------------------------------------- |
| `thread::spawn` | create a new thread                            |
| `move` closures | transfer ownership into a thread               |
| `mpsc::channel` | send data between threads (ownership transfer) |
| `Mutex<T>`      | shared mutable access with locking             |
| `Arc<T>`        | thread-safe reference counting                 |
| `Send` / `Sync` | compile-time thread safety checks              |

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Material Inspired by

- https://doc.rust-lang.org/book/ch16-01-threads.html
- https://doc.rust-lang.org/book/ch16-02-message-passing.html
- https://doc.rust-lang.org/book/ch16-03-shared-state.html
- https://doc.rust-lang.org/book/ch16-04-extensible-concurrency-sync-and-send.html
