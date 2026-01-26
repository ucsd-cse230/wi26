#import "@preview/sheetstorm:0.4.0": *

#let quiz(name: none, ..args, body) = task(task-prefix: "Quiz", name: name, ..args, body)

#show: assignment.with(
  course: smallcaps[CSE 130 Winter 2026],
  title: "Worksheet 1B",
  authors: (
    (name: "NAME: _________________________ ", id: "SID: _________________________________"),
  ),
  info-box-enabled: false,
  score-box-enabled: false,
  date: datetime(year: 2026, month: 1, day: 8),
  // Here you can customize the layout of the page, the header, the widgets.
  // Look at the parameters of the `assignment` function.
)


#quiz(name: "Tuples and Patterns")[

  What is the value of `quiz` defined as

  ```haskell
  tup2 :: (Char, Double, Int)
  tup2 = ('a', 5.2, 7)

  snd3 :: (t1, t2, t3) -> t2
  snd3 x = case x of
             (x1, x2, x3) -> x2

  quiz = snd3 tup2
  ```

  1. `'a'`
  2. `5.2`
  3. `7`
  4. `('a', 5.2)`
  1. `(5.2, 7)`

]

Lets write a function `range` such that `range i j` returns the list of values `[i, i+1, ..., j]`

#quiz(name: "Range: Type")[

  Next, what is a suitable *type* for `range`?

  ```haskell
  range :: _________ -> _________ -> _________
  ```

]

#quiz(name: "Range: Inputs")[

  Next, lets fill in some *inputs* for `range`


  ```haskell
  range 3 2 = _________________________________

  range 2 2 = _________________________________

  range 1 2 = _________________________________

  range 0 2 = _________________________________
  ```

]


#quiz(name: "Range: Implementation")[

  Finally, lets write the *implementation* for `range`?

  ```haskell
  range ___________________________________

        ___________________________________

        ___________________________________
  ```

]

#pagebreak()

#quiz(name: "Mystery function")[

  Suppose we have the following `mystery` function

  ```haskell
  mystery :: [a] -> Int
  mystery []     = 0
  mystery (x:xs) = 1 + mystery xs
  ```

  What does `mystery [10, 20, 30]` evaluate to?

  1. `10`
  2. `20`
  3. `30`
  4. `3`
  5. `0`

]



#quiz(name: "Your turn!")[

  What is something you are foxed by in today's lecture (or earlier)?

  #rect(width: 100%, height: 5cm, stroke: 0.5pt)
]
