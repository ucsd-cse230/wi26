#import "@preview/sheetstorm:0.4.0": *

#let quiz(name: none, ..args, body) = task(task-prefix: "Quiz", name: name, ..args, body)

#show: assignment.with(
  course: smallcaps[CSE 230 Winter 2026],
  title: "Worksheet 4A",
  authors: (
    (name: "NAME: _________________________ ", id: "SID: _________________________________"),
  ),
  info-box-enabled: false,
  score-box-enabled: false,
  date: datetime(year: 2026, month: 1, day: 27),
)


#quiz(name: "Typing +")[

  Which of the following would be appropriate types for `(+)` ?

  1. `(+) :: Integer -> Integer -> Integer`

  2. `(+) :: Double  -> Double  -> Double`

  3. `(+) :: a       -> a       -> a`

  4. _All_ of the above

  5. _None_ of the above

]


#quiz(name: "Comparison")[

  Recall the datatype:

  ```haskell
  data Showable = A | B | C deriving (Eq, Show)
  ```

  What is the result of

  ```haskell
  -- >>> A < B

  ______________________________________________
  ```
]

#quiz(name: "Implementing Comparison")[

  Fill in the implementation of the `Ord` typeclass for `Showable`

  ```haskell
  instance Ord Showable where

    (<=) s1 s2 = ______________________________________________
  ```

  So that we get the following behavior

  ```haskell
  -- >>> A < B && B < C
  -- True
  ```
]



#quiz(name: "Combine with Intermediate Result")[

  Suppose we have a _key-value table_ datatype defined as

  ```haskell
  data Table k v = MkTable { def :: v, bindings :: [(k, v)] }
    deriving (Show)
  ```

  Let's write a function that returns the `keys` of the `Table`

  ```haskell
  keys :: Table k v -> [k]
  keys  _____________________________________________

        _____________________________________________

        _____________________________________________
  ```

]

#pagebreak()

#quiz(name: "Get the value of a Key")[

  Write an implementation of `get` that looks up the value of a key in a table,
  but which _requires_ the keys are in *increasing order* and so returns "default"
  the moment we see a key that's _larger_ than the one we're searching for.

  ```haskell
  get :: ______________________________________________

  get (MkTable def binds) = go binds
    where
       go ______________________________________________

          ______________________________________________

          ______________________________________________
  ```
]

#quiz(name: "Set the value of a Key")[
  Write an implementation of `set` that _inserts_ a key-value pair into a table,
  _ensuring_ the keys are in *increasing order*.

  ```haskell
  set :: __________________________________________________________

  get key val (MkTable def binds) = _______________________________
    where
       go _________________________________________________________

          _________________________________________________________

          _________________________________________________________
  ```
]

#quiz(name: "Your turn!")[

  What is something you found confusing in today's lecture (or earlier)?

  #rect(width: 100%, height: 5cm, stroke: 0.5pt)
]
