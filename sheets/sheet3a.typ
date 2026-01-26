#import "@preview/sheetstorm:0.4.0": *

#let quiz(name: none, ..args, body) = task(task-prefix: "Quiz", name: name, ..args, body)

#show: assignment.with(
  course: smallcaps[CSE 230 Winter 2026],
  title: "Worksheet 3A",
  authors: (
    (name: "NAME: _________________________ ", id: "SID: _________________________________"),
  ),
  info-box-enabled: false,
  score-box-enabled: false,
  date: datetime(year: 2026, month: 1, day: 20),
  // Here you can customize the layout of the page, the header, the widgets.
  // Look at the parameters of the `assignment` function.
)


#quiz(name: "Using Map")[
  Here is a function `map`

  ```haskell
  map f []     = []
  map f (x:xs) = f x : map f xs
  ```


  Fill in the definition of `totals` such that it behaves as shown below

  ```haskell
  -- >>> totals [(10, 15), (10, 12), (9, 12), (9, 10)]
  -- [25, 22, 21, 19]

  totals = map ____________________________________
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

#quiz(name: "Filter")[
  Fill in the definition of `filter` so that we get the following behavior

  ```haskell
  -- >>> filter (\n -> n > 10) [18, 8, 12, 10, 9, 16]
  -- [18, 12, 16]
  -- >>> filter (\s -> length s == 3) ["cat", "mouse", "dog", "giraffe"]
  -- ["cat", "dog"]

  filter f []     = ______________________________________________

  filter f (x:xs) = ______________________________________________
  ```
]

#pagebreak()

#quiz(name: "Tree Fold")[

  Here is a `Tree a` type

  ```haskell
  data Tree a = Leaf | Node a (Tree a) (Tree a)
  ```

  and here is a particular value of that type

  ```haskell
    tree0 :: Tree Int
    tree0 =
      Node 0
        (Node 1
          (Node 2 Leaf Leaf)
          (Node 3 Leaf Leaf))
        Leaf
  ```

  Write a function `treeFold` such that

  ```haskell
  -- >>> treeFold (\n l r -> n : (l ++ r)) [] tree0
  -- [0,1,2,3]


  treeFold ______________________________________________

  treeFold ______________________________________________
  ```
]

#quiz(name: "Your turn!")[

  What is something you found confusing in today's lecture (or earlier)?

  #rect(width: 100%, height: 5cm, stroke: 0.5pt)
]
