#import "@preview/sheetstorm:0.4.0": *

#let quiz(name: none, ..args, body) = task(task-prefix: "Quiz", name: name, ..args, body)

#show: assignment.with(
  course: smallcaps[CSE 230 Winter 2026],
  title: "Worksheet 6B",
  authors: (
    (name: "NAME: _________________________ ", id: "SID: _________________________________"),
  ),
  info-box-enabled: false,
  score-box-enabled: false,
  date: datetime(year: 2026, month: 2, day: 12),
)

A parser converts unstructured data into structured data:

```haskell
data Parser a = P (String -> [(a, String)])

runParser :: Parser a -> String -> [(a, String)]
runParser (P f) s = f s
```

#quiz(name: "oneChar")[

  Write a parser `oneChar :: Parser Char` that returns the *first* `Char` from a string (if one exists), and returns `[]` on empty strings.

  ```haskell
  oneChar :: Parser Char
  oneChar = ____________________________________________

            ____________________________________________

            ____________________________________________
  ```
]

#quiz(name: "returnP")[

  Fill in the implementation of `returnP`

  ```haskell
  returnP :: a -> Parser a
  returnP = ____________________________________________
  ```
]


#quiz(name: "bindP")[

  Fill in the implementation of `returnP`

  ```haskell
  bindP :: Parser a -> (a -> Parser b) -> Parser b

  bindP aP a_bP = P (\s -> ________________________________________________________________

                           ________________________________________________________________

                           ________________________________________________________________
                    )
  ```
]

#quiz(name: "satP")[

  ```haskell
  satP :: (Char -> Bool) -> Parser Char
  satP p = do
    c <- oneChar
    if p c then return c else failP
  ```

  What are do the following evaluate to?

  ```haskell
  -- >>> runParser (satP (\c -> c == 'h')) "hellow"

  -- __________________________________________________________

  -- >>> runParser (satP (\c -> c == 'h')) "yellow"

  -- _______________________________________________
  ```
]

#quiz(name: "orElse")[
  Implement an `orElse p1 p2` function that produces the results
  of `p1` if non-empty *or else* the results of `p2`

  ```haskell
  orElse :: Parser a -> Parser a -> Parser a

  orElse p1 p2 =  _______________________________________________
  ```
]

#quiz(name: "manyP take 1")[

  ```haskell
  manyP :: Parser a -> Parser [a]
  manyP p = m0 `orElse` m1
    where
      m0  = return []
      m1  = do { x <- p; xs <- manyP p; return (x:xs) }
  ```

  What does `quiz` evaluate to?

  ```haskell
  quiz = runParser (manyP digitChar) "123horse"

  -- >>> quiz
  -- _______________________________________________
  ```
]

#quiz(name: "manyP take 2")[

  ```haskell
  manyP :: Parser a -> Parser [a]
  manyP p = m1 `orElse` m0
    where
      m0  = return []
      m1  = do { x <- p; xs <- manyP p; return (x:xs) }
  ```

  What does `quiz` evaluate to?

  ```haskell
  quiz = runParser (manyP digitChar) "123horse"

  -- >>> quiz
  -- _______________________________________________
  ```
]

#quiz(name: "Your turn!")[

  What is something you found confusing in today's lecture (or earlier)?

  #rect(width: 100%, height: 3cm, stroke: 0.5pt)
]
