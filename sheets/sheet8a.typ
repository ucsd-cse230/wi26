#import "@preview/sheetstorm:0.4.0": *

#let quiz(name: none, ..args, body) = task(task-prefix: "Quiz", name: name, ..args, body)

#show: assignment.with(
  course: smallcaps[CSE 230 Winter 2026],
  title: "Worksheet 8A",
  authors: (
    (name: "NAME: _________________________ ", id: "SID: _________________________________"),
  ),
  info-box-enabled: false,
  score-box-enabled: false,
  date: datetime(year: 2026, month: 2, day: 24),
)

#quiz(name: "Function Calls 1")[

  What happens when we run the following programs?

  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    [
      ```rust
      // (A)
      fn main() {
          let mut s = String::from("hello");
          call_me_string(s);
          println!("{s}, world!");
      }

      fn call_me_string(x: String) {
          println!("hello! {x}!");
      }
      ```
    ],
    [
      ```rust
      // (B)
      fn main() {
          let mut s = 42;
          call_me_i32(s);
          println!("{s}, world!");
      }

      fn call_me_i32(x: i32) {
          println!("hello! {x}!");
      }
      ```
    ],
  )
]


#quiz(name: "Function Calls 2")[

  How to *modify* this program so it compiles and runs?

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
]


#quiz(name: "Borrows & Mutation 1")[

  What is the result of running these two programs?

  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    [
      ```rust
      // (A)
      fn main() {
          let mut s = String::from("yo!");
          let r1 = &s;
          let r2 = &s;
          println!("{} and {}", r1, r2);
      }
      ```
    ],
    [
      ```rust
      // (B)
      fn main() {
          let mut s = String::from("yo!");
          let r1 = &s;
          let r2 = &mut s;
          println!("{} and {}", r1, r2);
      }
      ```
    ],
  )
]

#pagebreak()

#quiz(name: "Borrows & Mutation 2")[

  What is the result of running these two programs?

  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    [
      ```rust
      // (A)
      fn main() {
        let mut v = vec![10, 20, 30];
        let r0 = &v[0];
        let r1 = &v[1];
        let r2 = &v[2];
        println!("elems are {:?}, {:?}, {:?}", *r0, *r1, *r2);
        let mr = &mut v;
        change(mr);
        change(mr);
        println!("v is {:?}", v);
      }
      fn change(z: &mut Vec<i32>) {
          z.pop();
      }
      ```
    ],
    [
      ```rust
      // (B)
      fn main() {
        let mut v = vec![10, 20, 30];
        let r0 = &v[0];
        let r1 = &v[1];
        let r2 = &v[2];
        println!("elems are {:?}, {:?}, {:?}", *r0, *r1, *r2);
        let mr = &mut v;
        change(mr);
        change(mr);
        println!("r1 is {:?}", *r1);
      }
      ```
    ],
  )
]

#quiz(name: "Your turn!")[

  What is something you found confusing in today's lecture (or earlier)?

  #rect(width: 100%, height: 5cm, stroke: 0.5pt)
]
