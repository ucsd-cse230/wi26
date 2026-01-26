#import "@preview/sheetstorm:0.4.0": *

#let quiz(name: none, ..args, body) = task(task-prefix: "Quiz", name: name, ..args, body)

#show: assignment.with(
  course: smallcaps[CSE 230 Winter 2026],
  title: "Worksheet 3B",
  authors: (
    (name: "NAME: _________________________ ", id: "SID: _________________________________"),
  ),
  info-box-enabled: false,
  score-box-enabled: false,
  date: datetime(year: 2026, month: 1, day: 22),
  // Here you can customize the layout of the page, the header, the widgets.
  // Look at the parameters of the `assignment` function.
)


#quiz(name: "Multiple Recipes 1")[
  Suppose that

  ```hs
  putStrLn :: String -> Recipe ()
  ```

  What is the type of `quiz` defined as

  ```haskell
  quiz :: ______________________________________________

  quiz = (putStrLn "Hello!", putStrLn "World!")
  ```
]


#quiz(name: "Combining Two Recipes")[
  Suppose that

  ```haskell
  quiz :: Recipe ()
  quiz = combine r1 r2
    where
      r1 = putStrLn "Hello!"
      r2 = putStrLn "World!")
  ```

  What must the type of `combine` be ?

  ```hs
  combine :: ______________________________________________
  ```
]


#quiz(name: "Combining Many Recipes")[

  Complete the implementation of `sequence` that

  + Takes a _non-empty list_ of recipes `[r1,...,rn]` as input and
  + Returns a _single_ recipe equivalent to `do {r1; ...; rn}`

  ```haskell
  sequence :: [Recipe ()] -> Recipe ()

  sequence = _____________________________________

             _____________________________________
  ```
]

#quiz(name: "Combine with Intermediate Result")[

  Suppose you have two recipes

  ```haskell
  crack     :: Recipe Yolk
  eggBatter :: Yolk -> Recipe Batter
  ```

  and we want to get

  ```haskell
  mkBatter :: Recipe Batter
  mkBatter = combineWithResult crack eggBatter
  ```

  What is the type of

  ```hs
  combineWithResult :: ______________________________________________
  ```
]

#quiz(name: "Your turn!")[

  What is something you found confusing in today's lecture (or earlier)?

  #rect(width: 100%, height: 5cm, stroke: 0.5pt)
]
