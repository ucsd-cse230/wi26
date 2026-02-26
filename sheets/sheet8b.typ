#import "@preview/sheetstorm:0.4.0": *

#let quiz(name: none, ..args, body) = task(task-prefix: "Quiz", name: name, ..args, body)

#show: assignment.with(
  course: smallcaps[CSE 230 Winter 2026],
  title: "Worksheet 8B",
  authors: (
    (name: "NAME: _________________________ ", id: "SID: _________________________________"),
  ),
  info-box-enabled: false,
  score-box-enabled: false,
  date: datetime(year: 2026, month: 2, day: 26),
)

#quiz(name: "Borrows & Mutation: Recap")[

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
        println!("elems {}, {}, {}", *r0, *r1, *r2);
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
        println!("elems {}, {}, {}", *r0, *r1, *r2);
        let mr = &mut v;
        change(mr);
        change(mr);
        println!("r1 is {:?}", *r1);
      }
      fn change(z: &mut Vec<i32>) {
          z.pop();
      }
      ```
    ],
  )
]

#quiz(name: "Structs")[

  What gets printed when we run

  #grid(
    columns: (1fr, 1.5fr),
    gutter: 1em,
    [
      ```rust
      fn circle_area(c: Circle) -> f64 {
          let r = c.radius;
          std::f64::consts::PI * r * r
      }
      ```
    ],
    [
      ```rust
      fn main() {
        let c = Circle { x: 0.0, y: 0.0, radius: 10.0 };
        let a = circle_area(c);
        println!("Circle {c:?} has area = {a:?}");
      }
      ```
    ],
  )
]

#quiz(name: "Enums")[
  What gets printed when we run
  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    [
      ```rust
      fn shape_area(sh: &Shape) -> f64 {
        match sh {
          Shape::Rect(w, h) => w * h,
          Shape::Poly(pts) => poly_area(pts),
        }
      }
      ```
    ],
    [
      ```rust
      fn main() {
        let sh = Shape::Rect(10.0, 20.0);
        let a = shape_area(&sh0);
        println!("Shape {sh:?} has area {a:?}")
      }
      ```
    ],
  )

]

#quiz(name: "Box and Bin")[
  Consider the `Expr` type defined below and the "smart constructor" `bin`

  #grid(
    columns: (1.2fr, 1fr),
    gutter: 1em,
    [
      ```rust
      enum Op { Add, Sub, Mul, Div }
      enum Expr {
        Num(i32),
        Bin(Op, Expr, Expr),
      }

      fn bin(op: Op, left: Expr, right: Expr) -> Expr {
        Expr::Bin(op, Box::new(left), Box::new(right))
      }
      ```
    ],
    [
      1. Why does `Op` not require `Box` shenanigans?

      #v(1em)

      #line(length: 3in)


      #v(1em)

      2. Why does `bin` take `Expr` (not `&Expr`)?

      #v(1em)

      #line(length: 3in)
    ],
  )
]

#quiz(name: "Matching and Borrowing")[
  What is printed when I run the below?

  ```rust
  fn eval_op(op: &Op, lval: i32, rval: i32) -> i32 {
    match op {
        Op::Add => lval + rval,
        Op::Mul => lval * rval,
        // ...
    }
  }
  fn eval(e: &Expr) -> i32 {
    match e {
      Expr::Num(n) => n,
      Expr::Bin(op, left, right) => eval_op(op, eval(e1), eval(e2))
    }
  }
  fn main() {
    let expr = bin(Op::Mul, bin(Op::Add, Expr::Num(3), Expr::Num(4)), Expr::Num(5));
    let n = eval(&expr);
    println!("TRACE: eval {expr:?} ==> {n:?}");
  }
  ```

  #line(length: 4in)
]

#quiz(name: "Result")[
  Rewrite `eval_op` to return a `Result<i32, String>`

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
]

// #quiz(name: "Slices")[
//   What is the result of running this code?

//   ```rust
//   fn quiz() {
//     let mut str = vec!['b', 'a', 't', ' ', 'm', 'a', 'n'];
//     let last = last_word_slice(&str);
//     str.pop();
//     print_word_slice(&str, last);
//   }
//   ```
// ]

#quiz(name: "Your turn!")[

  What is something you found confusing in today's lecture (or earlier)?

  #rect(width: 100%, height: 3cm, stroke: 0.5pt)
]
