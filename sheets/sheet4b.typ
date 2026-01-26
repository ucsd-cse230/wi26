#import "@preview/sheetstorm:0.4.0": *

#let quiz(name: none, ..args, body) = task(task-prefix: "Quiz", name: name, ..args, body)

#show: assignment.with(
  course: smallcaps[CSE 230 Winter 2026],
  title: "Worksheet 4B",
  authors: (
    (name: "NAME: _________________________ ", id: "SID: _________________________________"),
  ),
  info-box-enabled: false,
  score-box-enabled: false,
  date: datetime(year: 2026, month: 1, day: 29),
)

Consider the following tree datatype

```haskell
data Tree a
  = Leaf
  | Node a (Tree a) (Tree a)
```

#quiz(name: "Showing the Node Values of a Tree")[
  Complete the implementation of `showTree` so that we get the following behavior

  ```haskell
  -- >>> showTree (Node 2 (Node 1 Leaf Leaf) (Node 3 Leaf Leaf))
  -- (Node "2" (Node "1" Leaf Leaf) (Node "3" Leaf Leaf))

  showTree :: Tree Int -> Tree String

  showTree Leaf         = __________________________________________

  showTree (Node v l r) = __________________________________________
  ```
]

#quiz(name: "Showing the Node Values of a Tree")[
  Complete the implementation of `sqrTree` so that we get the following behavior

  ```haskell
  -- >>> sqrTree (Node 2 (Node 1 Leaf Leaf) (Node 3 Leaf Leaf))
  -- (Node 4 (Node 1 Leaf Leaf) (Node 9 Leaf Leaf))

  sqrTree :: Tree Int -> Tree Int

  sqrTree Leaf         = __________________________________________

  sqrTree (Node v l r) = __________________________________________
  ```
]

#quiz(name: "Mapping over Trees")[

  Write a function `mapTree` such that we can refactor `showTree` and `sqrTree` as

  ```haskell
  -- showTree = mapTree (\v -> show v)
  -- sqrTree  = mapTree (\v -> v * v)

  mapTree ::  _______________________________________________

  mapTree ___________________________________________________

          ___________________________________________________
  ```
]

#pagebreak()

#quiz(name: "The Mappable Pattern")[

  How can we _abstract_ the `mapX` operator

  ```haskell
  mapList :: (a -> b) -> List a -> List b    -- List
  mapTree :: (a -> b) -> Tree a -> Tree b    -- Tree
  ```

  into a pattern that is _generic_ i.e. _reusable_
  across different _types_ like `List` or `Tree`, i.e.

  ```haskell
  class Mappable t where

    gmap :: ____________________________________________
  ```

  which will let us use `gmap` across different types!

  ```haskell
  -- >>> gmap (\v -> v * v) [1, 2, 3]
  -- [1, 4, 9]
  -- >>> gmap (\v -> show v) (Node 2 (Node 1 Leaf Leaf) (Node 3 Leaf Leaf))
  -- (Node "2" (Node "1" Leaf Leaf) (Node "3" Leaf Leaf))
  ```
]

#quiz(name: "Your turn!")[

  What is something you found confusing in today's lecture (or earlier)?

  #rect(width: 100%, height: 5cm, stroke: 0.5pt)
]
