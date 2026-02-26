#import "@preview/sheetstorm:0.4.0": *

#let quiz(name: none, ..args, body) = task(task-prefix: "Quiz", name: name, ..args, body)

#show: assignment.with(
  course: smallcaps[CSE 230 Winter 2026],
  title: "Worksheet 7B",
  authors: (
    (name: "NAME: _________________________ ", id: "SID: _________________________________"),
  ),
  info-box-enabled: false,
  score-box-enabled: false,
  date: datetime(year: 2026, month: 2, day: 19),
)


#quiz(name: "Immutability")[

  Consider the following Rust code:

  ```rust
  fn fib(n: usize) -> usize {
      if n <= 1 {
          n
      } else {
          let res = fib(n - 1);
          res = res + fib(n - 2);
          res
      }
  }
  ```

  What happens when you try to compile and run `fib(5)`?

]

#quiz(name: "Fixing Immutability")[

  Fix the definition of `fn fib` so `fib(5)` returns the correct result?

]

#quiz(name: "Statements vs. Expressions")[

  What is the value of `result` after the following Rust code?

  ```rust
  let result = {
      let x = 3;
      x * x + 1
  };
  ```

]

Lets write a function `my_max` that returns the maximum of two `i32` values.

#quiz(name: "my_max")[

  What is a suitable *type signature* and *implementation* for `my_max`?

  ```rust
  fn my_max( _________ : _________ , _________ : _________ ) -> _________ {
      ___________________________________

      ___________________________________

      ___________________________________
  }
  ```
]

#quiz(name: "For Loops")[

  Consider the following function:

  ```rust
  fn fib_for(n: usize) -> usize {
      let mut a = 0;
      let mut b = 1;
      for _i in 0..n {
          let temp = a;
          a = b;
          b = temp + b;
      }
      a
  }
  ```

  What does `fib_for(4)` return?

]

#quiz(name: "Moving Ownership")[
  What will be printed by this code?

  ```rust
  fn main() {
     let a = String::from("hello"); // `a` is the unique owner
     let b = a;                     // ownership of heap data MOVED to `b`
     println!("a is {a}");          // what will be printed?
  }
  ```
]

#quiz(name: "Moving Ownership")[
  What will be printed by this code?

  ```rust
  fn main() {
    let s = String::from("hello");
    s.push_str(", world!");  // push_str() appends a literal to a String
    println!("{s}");         // prints "hello, world!"
  }
  ```
]

#quiz(name: "Function Calls")[

  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    [
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
    ],
    [
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
    ]
  )
]

#quiz(name: "Your turn!")[

  What is something you found confusing in today's lecture (or earlier)?

  #rect(width: 100%, height: 3cm, stroke: 0.5pt)
]
