#import "@preview/sheetstorm:0.4.0": *

#let quiz(name: none, ..args, body) = task(task-prefix: "Quiz", name: name, ..args, body)

#show: assignment.with(
  course: smallcaps[CSE 230 Winter 2026],
  title: "Worksheet 7A",
  authors: (
    (name: "NAME: _________________________ ", id: "SID: _________________________________"),
  ),
  info-box-enabled: false,
  score-box-enabled: false,
  date: datetime(year: 2026, month: 2, day: 17),
)

A parser converts unstructured data into structured data:

```haskell
data Parser a = P (String -> [(a, String)])

runParser :: Parser a -> String -> [(a, String)]
runParser (P f) s = f s

failP :: Parser a
failP = P (\_ -> [])

satP :: (Char -> Bool) -> Parser Char
```

#quiz(name: "String")[
  Use `satP` to implement `strP s` which should parse *exactly*
  the string `s` and *nothing else*

  ```haskell
  strP :: String -> Parser String
  strP _______________________________________________

       _______________________________________________

  -- >>> runParser (strP "cat") "caterpillar"
  -- [("cat", "erpillar")]

  -- >>> runParser (strP "cat") "cutlet"
  -- []
  ```

]

#quiz(name: "orElse")[
  Implement an `orElse p1 p2` function that produces the results
  of `p1` if non-empty *or else* the results of `p2`

  ```haskell
  orElse :: Parser a -> Parser a -> Parser a

  orElse p1 p2 =  _______________________________________________
  ```

  -- >>> runParser (orElse alphaP digitP) "cat"
  [('c', "at")]
  -- >>> runParser (orElse alphaP digitP) "230"
  [('2', "30")]
  -- >>> runParser (orElse alphaP digitP) "..."
  []
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

#quiz(name: "Parsing an Integer")[
  Use `manyP` to implement `intP` which parses a whole `Int`.
  *HINT:* `read "123"` returns the `Int` with value `123`.

  ```haskell
  int :: Parser Int
  int = do _________________________

           _________________________
  ```
]

#quiz(name: "One or More")[

  Lets implement `oneOrMore vP oP` as a combinator

  - `vP` parses a _single_ `a` value
  - `oP` parses an _operator_ `a -> a -> a`
  - `oneOrMore vP oP` parses and returns the result `((v1 o v2) o v3) o v4) o ... o vn)`

  ```haskell
  oneOrMore :: Parser a -> Parser (a -> a -> a) -> Parser a

  oneOrMore vP oP = _______________________________________________
    where
      continue v1 = _______________________________________________

                    _______________________________________________
  ```
]

#quiz(name: "Your turn!")[

  What is something you found confusing in today's lecture (or earlier)?

  #rect(width: 100%, height: 3cm, stroke: 0.5pt)
]
