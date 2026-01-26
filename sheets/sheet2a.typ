#import "@preview/sheetstorm:0.4.0": *

#let quiz(name: none, ..args, body) = task(task-prefix: "Quiz", name: name, ..args, body)

#show: assignment.with(
  course: smallcaps[CSE 230 Winter 2026],
  title: "Worksheet 2A",
  authors: (
    (name: "NAME: _________________________ ", id: "SID: _________________________________"),
  ),
  info-box-enabled: false,
  score-box-enabled: false,
  date: datetime(year: 2026, month: 1, day: 13),
  // Here you can customize the layout of the page, the header, the widgets.
  // Look at the parameters of the `assignment` function.
)


#quiz(name: "Data Constructor Types")[

  Suppose we create a new type with a data definition

  ```haskell
  -- | A new type `CircleT` with constructor `MkCircle`
  data CircleT = MkCircle Double Double Double
  ```

  What is the type of the `MkCircle` constructor?

  ```haskell
  MkCircle :: ___________________________________
  ```
]


#quiz(name: "Constructed Data")[

  Lets create a single type for both shapes

  ```haskell
  data Shape
    = MkCircle Double Double Double   -- ^ Circle at x, y with radius r
    | MkCuboid Double Double Double   -- ^ Cuboid with length, depth, height
  ```

  What is the type of


  ```haskell
  sh0 :: ___________________________________

  sh0 = MkCircle 0 0 100
  ```

]


#quiz(name: "The Cons Constructor")[

  Given the following definition

  ```haskell
  data IntList
    = INil                -- ^ empty list
    | ICons Int IntList   -- ^ list with "hd" Int and "tl" IntList
  ```

  What is the type of `ICons` ?

  ```haskell
  ICons :: ___________________________________
  ```
]

#quiz(name: "Representing Sequences")[
  How can you represent the sequence of numbers `1, 2, 3` as a value of type `IntList`?

  ```hs
  list123 :: IntList

  list123 = __________________________________________
  ```
]


#quiz(name: "Using Map")[
  Here is a function `map`

  ```haskell
  map f []     = []
  map f (x:xs) = f x : map f xs
  ```


  Fill in the definition of `totals`

  ```haskell
  -- >>> totals [(10, 15), (10, 12), (9, 12), (9, 10)]
  -- [25, 22, 21, 19]

  totals = map ____________________________________
  ```
]


#quiz(name: "Typing Map")[

  What is the _type_ of `map`?

  ```haskell
  map :: __________________________________________
  ```
]


#quiz(name: "Using foldr")[
  Here is a function `foldr`

  ```haskell
  foldr op b []     = b
  foldr op b (x:xs) = op x (foldr op b xs)
  ```

  Fill in the definition of `size`

  ```haskell
  -- >>> size [(10, 15), (10, 12), (9, 12), (9, 10)]
  -- 4

  size = foldr _________________________________________
  ```
]


#quiz(name: "Typing foldr")[

  What is the _type_ of `foldr`?

  ```haskell
  map :: ______________________________________________
  ```
]



#quiz(name: "Your turn!")[

  What is something you found confusing in today's lecture (or earlier)?

  #rect(width: 100%, height: 5cm, stroke: 0.5pt)
]
