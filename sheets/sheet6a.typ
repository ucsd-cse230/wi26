#import "@preview/sheetstorm:0.4.0": *

#let quiz(name: none, ..args, body) = task(task-prefix: "Quiz", name: name, ..args, body)

#show: assignment.with(
  course: smallcaps[CSE 230 Winter 2026],
  title: "Worksheet 6A",
  authors: (
    (name: "NAME: _________________________ ", id: "SID: _________________________________"),
  ),
  info-box-enabled: false,
  score-box-enabled: false,
  date: datetime(year: 2026, month: 2, day: 10),
)


A tree with data at the *leaves*

```haskell
data Tree a = Leaf a | Node (Tree a) (Tree a)
    deriving (Eq, Show)
```


Here's an example `Tree Char`

```haskell
charT :: Tree Char
charT = Node
            (Node (Leaf 'a') (Leaf 'b'))
            (Node (Leaf 'c')  (Leaf 'a'))
```

#quiz(name: "Label")[

  Write a function `label` that adds a *distinct* label to each *leaf*

  ```haskell
  label :: Tree a -> Tree (a, Int)
  label = ____________________________________________

          ____________________________________________

          ____________________________________________

          ____________________________________________

          ____________________________________________

          ____________________________________________
  ```

  such that we get the following behavior

  ```haskell
  >>> label charT
  Node
      (Node (Leaf ('a', 0)) (Leaf ('b', 1)))
      (Node (Leaf ('c', 2)) (Leaf ('a', 3)))
  ```
]

#quiz(name: "Evaluating a Transformer 1")[
  Suppose we have defined

  ```haskell
  type State = Int
  data ST a = STC (State -> (State, a))
  ```

  Fill in the implementation of a function

  ```haskell
  evalState :: State -> ST a -> a
  evalState ____________________________________________
  ```
]


#quiz(name: "Evaluating a Transformer 2")[

  What is the value of `evalState 100 st` where `st` is defined below?

  ```haskell
  st :: St [Int]
  st = STC (\n -> (n+3, [n, n+1, n+2]))

  -- >>> evalState 100 st
  -- ____________________________________________
  ```
]


#quiz(name: "Evaluating a Transformer 3")[

  What does `evalState 100 next` evaluate to, where `next` is defined as

  ```haskell
  next :: ST String
  next = STC (\s -> (s+1, show s))

  -- >>> quiz
  -- _______________________________________________
  ```
]

// #quiz(name: "ST Monad: Return!")[
//   Fill in the implementation of `returnST`

//   ```haskell
//   returnST :: a -> ST a
//   returnST = ____________________________________________
//   ```
// ]

#quiz(name: "ST Monad: Bind!")[
  Fill in the *type* and *implementation* of `bindST`

  ```haskell
  bindST :: ____________________________________________

  bindST _______________________________________________

         _______________________________________________

         _______________________________________________

         _______________________________________________
  ```
]

#quiz(name: "Bind and Return")[

  What does `evalState 100 wtf1` evaluate to, where `wtf1` is defined as

  ```haskell
  wtf1 = ST String
  wtf1 = next >>= (\n -> return n)

  -- >>> evalState 100 wtf1
  _______________________________________________
  ```
]


#quiz(name: "Bind and Return")[

  What does `evalState 100 wtf2` evaluate to, where `wtf2` is defined as

  ```haskell
  wtf2 = next >>= \n1 ->
           next >>= \n2 ->
             next >>= \n3 ->
               return [n1, n2, n3]

  -- >>> evalState 100 wtf2
  _______________________________________________
  ```
]



#quiz(name: "Your turn!")[

  What is something you found confusing in today's lecture (or earlier)?

  #rect(width: 100%, height: 3cm, stroke: 0.5pt)
]
