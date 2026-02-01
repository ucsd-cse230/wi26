#import "@preview/sheetstorm:0.4.0": *

#let quiz(name: none, ..args, body) = task(task-prefix: "Quiz", name: name, ..args, body)

#show: assignment.with(
  course: smallcaps[CSE 230 Winter 2026],
  title: "Worksheet 5A",
  authors: (
    (name: "NAME: _________________________ ", id: "SID: _________________________________"),
  ),
  info-box-enabled: false,
  score-box-enabled: false,
  date: datetime(year: 2026, month: 2, day: 3),
)

#quiz(name: "Evaluate with Error")[

  Recall the evaluator from lecture

  ```haskell
  evalR :: Expr -> Result Int
  evalR (Number n)    = Ok n
  evalR (Bin o e1 e2) = evalR e1 >>= \v1 ->
                         evalR e2 >>= \v2 ->
                          evalOp o (v1 + v2)
  ```

  Complete the implementation of `evalOpR` (and maybe `evalR`!)

  ```haskell
  evalOp :: ______________________________________________________

  evalOp Add n1 n2 = _____________________________________________

  evalOp Sub n1 n2 = _____________________________________________

  evalOp Mul n1 n2 = _____________________________________________

  evalOp Div n1 0  = _____________________________________________

  evalOp Div n1 n2 = _____________________________________________
  ```

  so that we get the following behavior

  ```haskell
  -- >>> evalR (Bin Plus (Num 3) (Num 5))
  -- Ok 8
  -- >>> evalR (Bin Div (Num 6) (Bin Sub (Num 3) (Num 3)))
  -- Err "dbz: Bin Sub (Num 3) (Num 3)"
  ```
]

#quiz(name: "Return")[

  Suppose we wrote the `evalR` as

  ```haskell
  evalR :: Expr -> Result Int
  evalR (Number n)    = return n
  evalR (Bin o e1 e2) = do v1 <- evalR e1
                           v2 <- evalR e2
                           evalOp o (v1 + v2) ("dbz: " ++ show e2)
  ```

  What is the type of `return` ?

  ```haskell
  return :: ______________________________________________________
  ```
]

#quiz(name: "Maybe")[

  Here's a `Maybe a` type to represent "maybe-null" values

  ```haskell
  data Maybe val = Just val | Nothing
  ```

  Can you implement the `Monad` instance for `Maybe`?

  ```haskell
  instance Monad Maybe where
      (>>=) :: ______________________________________________________

      Nothing  >>= _ = ______________________________________________

      (Just v) >>= f = ______________________________________________

      return :: _____________________________________________________

      return v = ____________________________________________________
  ```

]


#quiz(name: "List Monad Instance")[
  ```haskell
    instance Monad [] where
      return = returnForList
      (>>=)  = bindForList
  ```

  Can you fill in the type and implementations

  ```haskell
  returnForList :: ______________________________________________________

  returnForList v = _____________________________________________________

  bindForList :: ________________________________________________________

  bindForList ___________________________________________________________

  bindForList ___________________________________________________________
  ```
]


#quiz(name: "Using the List Monad")[

  What does the following program evaluate to?

  ```haskell
  quiz = do x <- ["cat", "dog"]
            y <- [0, 1]
            return (x, y)

  -- >>> quiz
  -- _____________________________________________________
  ```
]

#quiz(name: "Your turn!")[

  What is something you found confusing in today's lecture (or earlier)?

  #rect(width: 100%, height: 5cm, stroke: 0.5pt)
]
