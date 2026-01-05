---
title: Parser Combinators
date: 2020-05-22
headerImg: books.jpg
--- 

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>



## Before we continue ... 

A Word from the Sponsor! 

			Don't Fear Monads

They are just a versatile abstraction, like `map` or `fold`.

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Parsers 

A _parser_ is a function that 

- converts _unstructured_ data (e.g. `String`, array of `Byte`,...) 
- into _structured_ data (e.g. JSON object, Markdown, Video...)

```haskell
type Parser = String -> StructuredObject
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Every large software system contains a Parser


| **System**    | **Parses**            |
|:--------------|:----------------------|
| Shell Scripts | Command-line options  |
| Browsers      | HTML                  |
| Games         | Level descriptors     |
| Routers       | Packets               |
| Netflix       | Video                 | 
| Spotify       | Audio, Playlists...   | 

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## How to build Parsers?

Two standard methods 

### Regular Expressions 

- Doesn't really scale beyond simple things 
- No nesting, recursion

### Parser Generators 

1. Specify *grammar* via rules

```haskell
Expr : Var            { EVar $1       }
     | Num            { ENum $1       }
     | Expr Op Expr   { EBin $1 $2 $3 }
     | '(' Expr ')'   { $2            }
     ;
```

2. Tools like `yacc`, `bison`, `antlr`, `happy` 
  - convert *grammar* into *executable function* 

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>


## Grammars Don't Compose! 

If we have *two* kinds of structured objects `Thingy` and `Whatsit`. 

```haskell
Thingy : rule 	{ action } 
;

Whatsit : rule  { action }
;
``` 

To parse *sequences* of `Thingy` and `Whatsit` we must *duplicate* the rules

```haskell
Thingies : Thingy Thingies  { ... } 
           EmptyThingy      { ... }
;

Whatsits : Whatsit Whatsits { ... }
           EmptyWhatsit     { ... }
;
```

No nice way to _reuse_ the sub-parsers for `Whatsit` and `Thingy` :-(

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## A New Hope: Parsers as Functions

Lets think of parsers directly **as functions** that 

- **Take** as input a `String`
- **Convert** a part of the input into a `StructuredObject`
- Return the **remainder** unconsumed to be parsed _later_

```haskell
data Parser a = P (String -> (a, String))
```

A `Parser a` 

- Converts a _prefix_ of a `String` 
- Into a _structured_ object of type `a` and 
- Returns the _suffix_ `String` unchanged

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Parsers Can Produce Many Results

Sometimes we want to parse a `String` like

```haskell
"2 - 3 - 4"
```

into a **list** of possible results

```haskell
[(Minus (Minus 2 3) 4),   Minus 2 (Minus 3 4)]
```

So we generalize the `Parser` type to

```haskell
data Parser a = P (String -> [(a, String)])
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## EXERCISE 

Given the definition 

```haskell
data Parser a = P (String -> [(a, String)])
```

Implement a function

```haskell
runParser :: Parser a -> String -> [(a, String)]
runParser p s = ???
``` 

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## QUIZ 

Given the definition 

```haskell
data Parser a = P (String -> [(a, String)])
```

Which of the following is a valid `oneChar :: Parser Char`

that returns the **first** `Char` from a string (if one exists)

```haskell
-- A
oneChar = P (\cs -> head cs)

-- B
oneChar = P (\cs -> case cs of 
                      []   -> [('', [])] 
                      c:cs -> [c, cs])

-- C
oneChar = P (\cs -> (head cs, tail cs))

-- D
oneChar = P (\cs -> [(head cs, tail cs)])

-- E
oneChar = P (\cs -> case cs of
                      [] -> [] 
                      cs -> [(head cs, tail cs)])
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Lets Run Our First Parser!

```haskell
>>> runParser oneChar "hey!"
[('h', "ey")]

>>> runParser oneChar "yippee"
[('y', "ippee")]

>>> runParser oneChar ""
[]
```

**Failure** to parse means result is an **empty** list!

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## EXERCISE 

Your turn: Write a parser to grab **first two chars** 

```haskell
twoChar :: Parser (Char, Char)
twoChar = P (\cs -> ???) 
```

When you are done, we should get

```haskell
>>> runParser twoChar "hey!"
[(('h', 'e'), "y!")]

>>> runParser twoChar "h"
[]
```


<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>


## QUIZ

Ok, so recall 

```haskell
twoChar :: Parser (Char, Char)
twoChar  = P (\cs -> case cs of
                       c1:c2:cs' -> [((c1, c2), cs')]
                       _         -> [])
``` 

Suppose we had some `foo` such that `twoChar'` was equivalent to `twoChar`  

```haskell
twoChar' :: Parser (Char, Char)
twoChar' = foo oneChar oneChar 
```

What must the type of `foo` be?

**A.** `Parser (Char, Char)` 

**B.** `Parser Char -> Parser (Char, Char)`

**C.** `Parser a -> Parser a -> Parser (a, a)` 

**D.** `Parser a -> Parser b -> Parser (a, b)` 

**E.** `Parser a -> Parser (a, a)` 

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## EXERCISE: A `forEach` Loop

Lets write a function

```haskell
forEach :: [a] -> (a -> [b]) -> [b]
forEach xs f = ???
```

such that we get the following behavior

```haskell
>>> forEach [] (\i -> [i, i + 1])
[]

>>> forEach [10,20,30] (\i -> [show i, show (i+1)])
["10", "11", "20", "21", "30", "31"]
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## QUIZ 

What does `quiz` evaluate to?

```haskell
quiz = forEach [10, 20, 30] (\i -> 
         forEach [0, 1, 2] (\j -> 
           [i + j] 
         )
       )
```

**A.** `[10,20,30,0,1,2]`

**B.** `[10,0,20,1,30,2]`

**C.** `[[10,11,12], [20,21,22] [30,31,32]]`

**D.** `[10,11,12,20,21,22,30,31,32]`

**E.** `[32]`

<br>
<br>
<br>
<br>
<br>
<br>
<br>


## A `pairP` Combinator

Lets implement the above as `pairP`

```haskell
forEach :: [a] -> (a -> [b]) -> [b]
forEach xs f = concatMap f xs 

pairP :: Parser a -> Parser b -> Parser (a, b)
pairP aP bP = P (\s -> forEach (runParser aP s) (\(a, s') ->
                         forEach (runParser bP s') (\(b, s'') -> 
                           ((a, b), s'')
                       )
                ) 
```

Now we can write 

```haskell
twoChar = pairP oneChar oneChar
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## QUIZ 

What does `quiz` evaluate to?


```haskell
twoChar = pairP oneChar oneChar

quiz    = runParser twoChar "h" 
```

**A.** `[((`h`, `h`), "")]`

**B.** `[(`h`, "")]`

**C.** `[("", "")]`

**D.** `[]`

**E.** Run-time exception

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Does the `Parser a` type remind you of something?

Lets implement the above as `pairP`

```haskell
data Parser a = P (String -> [(a, String)])

data ST s a   = S (s -> (a, s))
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## `Parser` is a Monad!

Like a state transformer, [`Parser` is a monad!][2]

We need to implement two functions

```haskell
returnP :: a -> Parser a

bindP   :: Parser a -> (a -> Parser b) -> Parser b
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## QUIZ

Which of the following is a valid implementation of `returnP`

```haskell
data Parser a = P (String -> [(a, String)])

returnP   :: a -> Parser a

returnP a = P (\s -> [])          -- A

returnP a = P (\s -> [(a, s)])    -- B

returnP a = P (\s -> (a, s))      -- C

returnP a = P (\s -> [(a, "")])   -- D

returnP a = P (\s -> [(s, a)])    -- E
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

**HINT:** `return a` should just 

- "produce" the parse result `a` and 
- leave the string unconsumed.

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Bind 

Next, lets implement `bindP` 

  - we almost saw it as `pairP`

```haskell
bindP :: Parser a -> (a -> Parser b) -> Parser b
bindP aP fbP = P (\s -> 
  forEach (runParser aP s) (\(a, s') -> 
    forEach (runParser (fbP a) s') (\(b, s'') ->
      [(b, s'')]
    )   
  )
)
```

The function 

- Builds the `a` values out of `aP` (using `runParser`)
- Builds the `b` values by calling `fbP a` on the _remainder_ string `s'` 
- Returns `b` values and the remainder string `s''` 

![](/static/img/bind-0.png)


## The `Parser` Monad

We can now make `Parser` an instance of `Monad`

```haskell
instance Monad Parser where
  (>>=)  = bindP
  return = returnP
```

![](https://www.artgroup.com/assets/img/products/WDC44013)

And now, let the *wild rumpus start!*

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Parser Combinators

Lets write lots of *high-level* operators to **combine** parsers!

Here's a cleaned up `pairP` 

```haskell
pairP :: Parser a -> Parser b -> Parser (a, b)
pairP aP bP = do 
  a <- aP
  b <- bP
  return (a, b)
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Failures are the Pillars of Success!

Surprisingly useful, always _fails_ 

- i.e. returns `[]` no successful parses 

```haskell
failP :: Parser a
failP = P (\_ -> [])
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## QUIZ

Consider the parser 

```haskell
satP :: (Char -> Bool) -> Parser Char
satP p = do 
  c <- oneChar
  if p c then return c else failP
```

What is the value of

```haskell
quiz1 = runParser (satP (\c -> c == 'h')) "hellow"
quiz2 = runParser (satP (\c -> c == 'h')) "yellow"
```

|       | `quiz1`           | `quiz2`              | 
|------:|------------------:|---------------------:| 
| **A** | `[]`              | `[]`                 |
| **B** | `[('h', "ellow")]`| `[('y', "ellow")]`   |
| **C** | `[('h', "ellow")]`| `[]`                 |
| **D** | `[]`              | `[('y', "ellow")]`   |


<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Parsing Alphabets and Numerics 

We can now use `satP` to write 

```haskell
-- parse ONLY the Char c
char :: Parser Char
char c = satP (\c' -> c == c')

-- parse ANY ALPHABET 
alphaCharP :: Parser Char
alphaCharP = satP isAlpha

-- parse ANY NUMERIC DIGIT
digitChar :: Parser Char
digitChar = satP isDigit
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## QUIZ 

We can parse a single `Int` digit

```haskell
digitInt :: Parser Int
digitInt = do
  c <- digitChar      -- parse the Char c
  return (read [c])   -- convert Char to Int
```

What is the result of 

```haskell
quiz1 = runParser digitInt "92"
quiz2 = runParser digitInt "cat"
```

|       | `quiz1`           | `quiz2`          | 
|------:|------------------:|-----------------:| 
| **A** | `[]`              | `[]`             |
| **B** | `[('9', "2")]`    | `[('c', "at")]`  |
| **C** | `[(9, "2")]`      | `[]`             |
| **D** | `[]`              | `[('c', "at")]`  |

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## EXERCISE

Write a function 

```haskell 
strP :: String -> Parser String 
strP s = -- parses EXACTLY the String s and nothing else
```

when you are done, we should get the following behavior


```haskell
>>> dogeP = strP "doge"

>>> runParser dogeP "dogerel"
[("doge", "rel")]

>>> runParser dogeP "doggoneit"
[]
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## A Choice Combinator

Lets write a combinator `orElse p1 p2` such that 

- returns the results of `p1` 

**or, else** _if those are empty_

- returns the results of `p2`

```haskell
:: Parser a -> Parser a -> Parser a
orElse p1 p2 = -- produce results of `p1` if non-empty
               -- OR-ELSE results of `p2`
```

e.g. `orElseP` lets us build a parser that produces an alphabet _OR_ a numeric character

```haskell
alphaNumChar :: Parser Char
alphaNumChar = alphaChar `orElse` digitChar
```

Which should produce 

```haskell
>>> runParser alphaNumChar "cat"
[('c', "at")]

>>> runParser alphaNumChar "2cat"
[('2', "cat")]

>>> runParser alphaNumChar "230"
[('2', "30")]
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## QUIZ 

```haskell
orElse :: Parser a -> Parser a -> Parser a
orElse p1 p2 = -- produce results of `p1` if non-empty
               -- OR-ELSE results of `p2`
```

Which of the following implements `orElse`?

```haskell
-- a 
orElse p1 p2 = do 
  r1s <- p1
  r2s <- p2
  return (r1s ++ r2s) 

-- b
orElse p1 p2 = do 
  r1s <- p1 
  case r1s of 
    [] -> p2 
    _  -> return r1s

-- c
orElse p1 p2 = P (\cs -> 
  runParser p1 cs ++ runParser p2 cs
  )

-- d
orElse p1 p2 = P (\cs -> 
  case runParser p1 cs of
    []  -> runParser p2 cs
    r1s -> r1s
  )
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## An "Operator" for `orElse` 

It will be convenient to have a short "operator" for `orElse`

```haskell
p1 <|> p2 = orElse p1 p2
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

<!--  
## QUIZ: A Choice Combinator

Lets write an `orElse` combinator such that `orElse p1 p2` 
- returns the results of `p1` 

**or, else** _if those are empty_

- returns the results of `p2`


```haskell
:: Parser a -> Parser a -> Parser a
chooseP p1 p2 = -- produce non-empty results of `p1` 
                -- or-else results of `p2`
```

e.g. `chooseP` lets us build a parser that produces an alphabet _OR_ a numeric character

```haskell
alphaNumChar :: Parser Char
alphaNumChar = chooseP alphaChar digitChar
```

Which should produce 

```haskell
>>> runParser alphaNumChar "cat"
[('c', "at")]

>>> runParser alphaNumChar "2cat"
[('2', "cat")]

>>> runParser alphaNumChar "230"
[('2', "30")]
```

```haskell
-- a 
chooseP p1 p2 = do xs <- p1
                   ys <- p2
                   return (x1 ++ x2) 
-- b
choose p1 p2  = do xs <- p1 
                   case xs of 
                     [] -> p2 
                     _  -> return xs

-- c
chooseP p1 p2 = P (\cs -> runParser p1 cs ++ runParser p2 cs)

-- d
chooseP p1 p2 = P (\cs -> case runParser p1 cs of
                            [] -> runParser p2 cs
                            rs -> rs)
```



## QUIZ 

Here's a parser that grabs the first `n` characters

```haskell
grabN :: Int -> Parser String
grabN n 
  | n <= 0    = return ""
  | otherwise = do {c <- oneChar; cs <- grabN (n-1); return (c:cs) }

grab2or4 = chooseP (grabN 2) (grabN 4)

quiz = runParser grab2or4 "mickeymouse"
```

**A.** `[]`

**B.** `[("mi","ckeymouse")]`

**C.** `[("mick","eymouse")]`

**D.** `[("mi","ckeymouse"),("mick","eymouse")]`

**E.** `[("mick","eymouse"), ("mi","ckeymouse")]`

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>


## Choice Combinator

Crucially if _both_ succeed, we end up with _all_ the results

```haskell
chooseP :: Parser a -> Parser a -> Parser a
p1 `chooseP` p2 = P (\cs -> runParser p1 cs ++ runParser p2 cs)
```

and only one result if thats possible

```haskell
>>> runParser grab2or4 "mic"
[("mi","c")]

>>> runParser grab2or4 "m"
[]
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
-->

## A Simple Expression Parser

Now, lets write a _tiny_ calculator!

```haskell
-- 1. First, parse the operator 
intOp      :: Parser (Int -> Int -> Int) 
intOp      = plus <|> minus <|> times <|> divide 
  where 
    plus   = do { _ <- char '+'; return (+) }
    minus  = do { _ <- char '-'; return (-) }
    times  = do { _ <- char '*'; return (*) }
    divide = do { _ <- char '/'; return div }

-- 2. Now parse the expression!
calc :: Parser Int
calc = do x  <- digitInt
          op <- intOp
          y  <- digitInt 
          return (x `op` y)
```

When `calc` is run, it will both parse _and_ calculate 

```haskell
>>> runParser calc "8/2"
[(4,"")]

>>> runParser calc "8+2cat"
[(10,"cat")]

>>> runParser calc "8/2cat"
[(4,"cat")]

>>> runParser calc "8-2cat"
[(6,"cat")]

>>> runParser calc "8*2cat"
[(16,"cat")]
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## QUIZ 

What will `quiz` evaluate to? 

```haskell
calc :: Parser Int
calc = do x  <- digitInt
          op <- intOp
          y  <- digitInt 
          return (x `op` y)

quiz = runParser calc "99bottles"
```

**A.** Type error

**B.** `[]`

**C.** `[(9, "9bottles")]`

**D.** `[(99, "bottles")]`

**E.** Run-time exception

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Next: Recursive Parsing

Its cool to parse individual `Char` ... 

... but _way_ more interesting to parse recursive structures! 

```haskell
"((2 + 10) * (7 - 4)) * (5 + 2)"
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## EXERCISE: A "Recursive" String Parser

The parser `string s` parses *exactly* the string `s` 
  - fails otherwise

```haskell
>>> runParser (string "mic") "mickeyMouse"
[("mic","keyMouse")]

>>> runParser (string "mic") "donald duck"
[]
```

Lets fill in an implementation

```haskell
string :: String -> Parser String
string s = ???
```

Which library function will _eliminate_ the recursion from `string`?


<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## QUIZ: Parsing Many Times

Often we want to _repeat_ parsing some object

```haskell
-- | `manyP p` repeatedly runs `p` to return a list of [a]
manyP  :: Parser a -> Parser [a]
manyP p = m0 <|> m1
  where
    m0  = return [] 
    m1  = do { x <- p; xs <- manyP p; return (x:xs) } 
```

Recall `digitChar :: Parser Char` returned a _single_ numeric `Char`

What will `quiz` evaluate to?

```haskell
quiz = runParser (manyP digitChar) "123horse"
```

**A.** `[(""  , "1234horse")]` 

**B.** `[("1" , "234horse")]` 

**C.** `[("1", "23horse"), ("12", "3horse"), ("123", "horse )]` 


**D.** `[("123", "horse")]` 

**E.** `[]` 


<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Lets fix `manyP`!

Run `p` _first_ and only `return []` if it fails ... 
  
```haskell
-- | `manyP p` repeatedly runs `p` to return a list of [a]
manyP  :: Parser a -> Parser [a]
manyP p = m1 <|> m0
  where
    m0  = return [] 
    m1  = do { x <- p; xs <- manyP p; return (x:xs) } 
```

now, we can write an `Int` parser as

```haskell
int :: Parser Int
int = do { xs <- manyP digitChar; return (read xs) }
```

which will produce

```haskell
>>> runParser oneChar "123horse"
[("123", "horse")]

>>> runParser int "123horse"
[(123, "horse")]
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Parsing Arithmetic Expressions

_Now_ we can build a proper calculator!

```haskell
calc0 ::  Parser Int
calc0 = binExp <|> int 

int :: Parser Int
int = do 
  xs <- many digitChar 
  return (read xs)

binExp :: Parser Int
binExp = do
  x <- int 
  o <- intOp 
  y <- calc0 
  return (x `o` y) 
```

Works pretty well!

```haskell
>>> runParser calc0 "11+22+33"
[(66,"")]

ghci> doParse calc0 "11+22-33"
[(0,"")]
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## QUIZ 

```haskell
calc0 ::  Parser Int
calc0 = binExp <|> int 

int :: Parser Int
int = do 
  xs <- many digitChar 
  return (read xs)

binExp :: Parser Int
binExp = do
  x <- int 
  o <- intOp 
  y <- calc0 
  return (x `o` y) 
```

What does `quiz` evaluate to? 

```haskell
quiz = runParser calc0 "10-5-5"
```

**A.** `[(0, "")]`

**B.** `[]`

**C.** `[(10, "")]`

**D.** `[(10, "-5-5")]`

**E.** `[(5, "-5")]`

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Problem: Right-Associativity

Recall 

```haskell
binExp :: Parser Int
binExp = do
  x <- int 
  o <- intOp 
  y <- calc0 
  return (x `o` y)
``` 

`"10-5-5"` gets parsed as `10 - (5 - 5)` because

![](/static/img/parse-left.png)

The `calc0` parser implicitly forces each operator to be **right associative** 

- doesn't matter for `+`, `*` 

- but is incorrect for `-`

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## QUIZ

Recall 

```haskell
binExp :: Parser Int
binExp = do
  x <- int 
  o <- intOp 
  y <- calc0 
  return (x `o` y)
``` 

What does `quiz` get evaluated to?

```haskell
quiz = runParser calc0 "10*2+100"
```

**A.** `[(1020,"")]`

**B.** `[(120,"")]`

**C.** `[(120,""), (1020, "")]`

**D.** `[(1020,""), (120, "")]`

**E.** `[]`


<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

The `calc0` parser implicitly forces *all operators* to be *right associative* 

- doesn't matter for `+`, `*` 

- but is incorrect for `-`

**Does not respect precedence!**

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Simple Fix: Parentheses!

Lets write a combinator that parses something within `(...)`

```haskell
parensP :: Parser a -> Parser a
parensP p = do 
  _ <- char '(' 
  x <- p
  _ <- char ')'
  return x 
```

now we can try 

```haskell
calc1 :: Parser Int
calc1 = parens binExp <|> int 

binExp :: Parser Int
binExp = do
  x <- int 
  o <- intOp 
  y <- calc1 
  return (x `o` y)
```

now the original string wont even parse


```haskell
>>> runParser calc1 "10-5-5" 
[]
```

but we can add parentheses to get the right result

```haskell
>>> runParser calc1 "((10-5)-5)" 
[(0 ,"")]

>>> runParser calc1 "(10-(5-5))" 
[(10 ,"")]

>>> runParser calc1 "((10*2)+100)"
[(120, "")]

>>> runParser calc1 "(10*(2+100))"
[(1020, "")]
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Left Associativity

But how to make the parser *left associative*

- i.e. parse "10-5-5" as `(10 - 5) - 5` ?

Lets flip the order!

```haskell
calc1      ::  Parser Int
calc1      = binExp <|> oneInt 

binExp :: Parser Int
binExp = do 
  x <- calc1 
  o <- intOp 
  y <- int
  return (x `o` y)
```

But ...

```haskell
>>> runParser calc1 "2+2"
...
```

Infinite loop! `calc1 --> binExp --> calc1 --> binExp --> ...` 

- without _consuming_ any input :-( 

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Solution: Parsing with Multiple *Levels*

Any expression is a **sum-of-products**

```haskell
  10 * 20 * 30 + 40 * 50 + 60 * 70 * 80
=> 
  ((((10 * 20) * 30) + (40 * 50)) + ((60 * 70) * 80))
=>  
  ((((base * base) * base)  + (base * base)) + ((base * base) * base))
=>  
  (((prod * base) + prod)  + (prod * base))
=>  
  ((prod + prod) + prod) 
=>   
  (sum + prod)
=>
   sum 
=>   
   expr
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Parsing with Multiple *Levels*

So lets **layer** our language as

```haskell
  expr :== sum
  sum  :== (((prod "+" prod) "+" prod) "+" ... "+" prod)
  prod :== (((base "*" base) "*" base) "*" ... "*" base) 
  base :== "(" expr ")" ORELSE int
```

that is the recursion looks like

```haskell
  expr = sum
  sum  = oneOrMore prod "+" 
  prod = oneOrMore base "*"
  base = "(" expr ")" <|> int 
```

No infinite loop!

- `expr --> prod --> base -->* expr` 

- but last step `-->*` _consumes_ a `(` 

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Parsing `oneOrMore`

Lets implement `oneOrMore vP oP` as a combinator
  - `vP` parses a *single* `a` value
  - `oP` parses an *operator* `a -> a -> a` 
  - `oneOrMore vP oP` parses and returns the result `((v1 o v2) o v3) o v4) o ... o vn)`

But how?

1. *grab* the first `v1` using `vP` 

2. *continue* by 
    - either trying `oP` then `v2` ... and recursively continue with `v1 o v2` 
    - `orElse` (no more `o`) just return `v1`

```haskell
oneOrMore :: Parser a -> Parser (a -> a -> a) -> Parser a
oneOrMore vP oP = do {v1 <- vP; continue v1}
  where 
    continue v1 = do { o <- oP; v2 <- vP; continue (v1 `o` v2) }
               <|> return v1
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Implementing Layered Parser

Now we can implement the grammar 

```haskell
  expr = sum
  sum  = oneOrMore prod "+" 
  prod = oneOrMore base "*"
  base = "(" expr ")" <|> int 
```

simply as

```haskell
expr = sum
sum  = oneOrMore prod addOp
prod = oneOrMore base mulOp
base = parens expr <|> int
```

where `addOp` is `+` or `-` and `mulOp` is `*` or `/`  

```haskell
addOp, mulOp :: Parser (Int -> Int -> Int)
addOp = constP "+" (+) <|> constP "-" (-)
mulOp = constP "*" (*) <|> constP "/" div

constP :: String -> a -> Parser a 
constP s x = do { _ <- string s; return x }
```

Lets make sure it works!

```haskell
>>> doParse sumE2 "10-1-1"
[(8,"")]

>>> doParse sumE2 "10*2+1"
[(21,"")]

>>> doParse sumE2 "10+2*1"
[(12,"")]
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Parser combinators 

That was a taste of Parser Combinators

- Transferred from Haskell to [_many_ other languages][3]. 

Many libraries including [Parsec][3] used in your homework
  -  `oneOrMore` is called `chainl`

Read more about the *theory* 
  - in these [recent][4] [papers][5]

Read more about the *practice* 
  - in this recent post that I like [JSON parsing from scratch][6]

[2]: http://homepages.inf.ed.ac.uk/wadler/papers/marktoberdorf/baastad.pdf
[3]: http://www.haskell.org/haskellwiki/Parsec
[4]: http://www.cse.chalmers.se/~nad/publications/danielsson-parser-combinators.html
[5]: http://portal.acm.org/citation.cfm?doid=1706299.1706347
[6]: https://abhinavsarkar.net/posts/json-parsing-from-scratch-in-haskell/
