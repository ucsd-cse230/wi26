---
title: From Failures to Lists of Successes
date: 2019-06-5
headerImg: books.jpg
---

## Recap: Monad

`Monad` is a typeclass with two functions

```haskell
class Monad m where
  return :: a -> m a
  (>>=)  :: m a -> (a -> m b) -> m 
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## A `Maybe` Monad

We can define a `Maybe a` type to represent "maybe-null" values

```haskell
data Maybe val 
  = Just val        -- ^ "Just one value" :-) 
  | Nothing         -- ^ "No value" :-(
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>


## A the `Monad` instance for `Maybe`

Can you help me fill this in?

```haskell
instance Monad Maybe where
    (>>=) :: Maybe a -> (a -> Maybe b) -> Maybe b
    Nothing    >>= _ = ???
    (Just v)   >>= f = ???

    return :: a -> Result a
    return v = ???
```

### `Maybe` represents computations that *may produce no value*

A value of type `Maybe a` is either 

- `Nothing` which we can think of as representing *failure*, or 

- `Just x` for some `x` of type `a`, which we can think of as *success*

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>


### Using `Maybe` for computations that *may produce no value*

We saw how to write an `eval` function that *doesn't crash*

- But instead gracefully returns a `Nothing` (if there is a div-by-zero)

```haskell
eval :: Expr -> Maybe Int
eval (Number n)   = Just n
eval (Plus e1 e2) = do n1 <- eval e1
                       n2 <- eval e2
                       return (v1 + v2)
eval (Div e1 e2)  = do n1 <- eval e1
                       n2 <- eval e2
                       if n2 == 0
                          then Nothing
                          else Just (v1 `div` v2)
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Replacing Failure by a List of Successes

Lets *generalize* the `Maybe` monad into a *List* monad!

- `Nothing` is the *empty list* `[]`
- `Just v`  is the *singleton list* `[v]`

... but maybe there's something sensible for lists with *many* elements?

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

Lets make lists an instance of `Monad` by:

```haskell
class Monad m where
  return :: a -> m a
  (>>=)  :: m a -> (a -> m b) -> m b

instance Monad [] where 
  return = returnForList
  (>>=)  = bindForList
```

What must the type of `returnForList` be ?

**A.** `[a]`

**B.** `a -> a`

**C.** `a -> [a]`

**D.** `[a] -> a`

**E.** `[a] -> [a]`

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>


## A Monad Instance for Lists

Lets implement the `Monad` instance for lists?

```haskell
-- returnForList :: a -> [a]
returnForList x = ???
```

What's the only sensible implementation?

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

Lets make lists an instance of `Monad` by:

~~~~~{.haskell}
class Monad m where 
  return :: a -> m a
  (>>=)  :: m a -> (a -> m b) -> m b

instance Monad [] where 
  return = returnForList
  (>>=)  = bindForList
~~~~~


What must the type of `bindForList` be?

**A.** `[a] -> [b] -> [b]` 

**B.** `[a] -> (a -> b) -> [b]`

**C.** `[a] -> (a -> [b]) -> b`

**D.** `[a] -> (a -> [b]) -> [b]`

**E.** `[a] -> [b]`

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

Which of the following is a valid

```haskell
bindForList :: [a] -> (a -> [b]) -> [b] 
bindForList = bfl

-- a
bfl f []     = []
bfl f (x:xs) = f x : bfl f xs

-- b
bfl f []     = []
bfl f (x:xs) = f x ++ bfl f xs

-- c
bfl []     f = []
bfl (x:xs) f = f x ++ bfl f xs

-- d
bfl []     f = []
bfl (x:xs) f = f x : bfl f xs

-- e
bfl []     f = []
bfl (x:xs) f = x : f xs
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


## The List Monad 

Lets "run" the `>>=` on some inputs to see how it behaves!

```haskell
(>>=)  :: [a] -> (a -> [b]) -> [b]
[]         >>= _ = [] 
(x:xs)     >>= f = f x ++ (xs >>= f) 
```


```haskell
[] >>= f  ==> []
```

```haskell
[x3] >>= f  ==> f x3 ++ ([] >>= f)  ==> f x3
```

```haskell
[x2,x3] >>= f  ==> f x2 ++ ([x3] >>= f)    ==> f x2 ++ f x3
```

```haskell
[x1,x2,x3] >>= f  ==> f x1 ++ ([x2,x3] >>=f ) ==> f x1 ++ f x2 ++ f x3
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

What does the following program evaluate to?

```haskell
quiz = do x <- ["cat", "dog"]
          y <- [0, 1]
          return (x, y)
```

**A.** `[("cat", 0)]`

**B.** `[("dog", 1)]`

**C.** `["cat", "dog", 0, 1]`

**D.** `["cat", 0, "dog", 1]`

**E.** `[("cat", 0), ("cat", 1), ("dog", 0), ("dog", 1)]`

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Whoa, behaves like a `for`-loop!

Lets work it out.

```haskell
do {x <- ["cat", "dog"]; y <- [0, 1]; return (x, y)}

== ["cat", "dog"] >>= (\x -> [0, 1] >>= (\y -> return (x, y)))
```

Now lets break up the evaluation

```haskell
[0, 1] >>= (\y -> [(x, y)])

==>  ((\y -> [(x, y)]) 0) ++ ((\y -> [(x, y)]) 1)

==> [(x, 0)] ++ [(x, 1)] 

==> [(x, 0), (x, 1)] 
```

So 

```haskell
["cat", "dog"] >>= (\x -> [(x, 0), (x, 1)])

==> (\x -> [(x, 0), (x, 1)]) "cat") ++ (\x -> [(x, 0), (x, 1)]) "dog")

==> [("cat", 0), ("cat", 1)] ++ [("dog", 0), ("dog", 1)] 

==> [("cat", 0), ("cat", 1), ("dog", 0), ("dog", 1)] 
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
foo f xs = do
  x <- xs
  return (f x)

quiz = foo (\n -> n*n)  [0,1,2,3]
```

**A.** `[0]`
**B.** `[0,1,4,9]`
**C.** `[9]`
**D.** _Type Error_
**E.** _Runtime Exception_

<br>
<br>
<br>
<br>
<br>
<br>
<br>

## QUIZ 

What does the following evaluate to?

```haskell
triples :: [(Int, Int, Int)]
triples = do
    x <- [0,1]
    y <- [10,11]
    z <- [100,101]
    []
```

**A.** `[(0,10,100), (0,10,101),(1,10,100),(1,10,101),(0,11,100),(0,11,101)]`

**B.** `[]`

**C.** `[[]]`

**D.** `[(0,10,100), (1,11,101)]`

**E.** `[0,1,10,100,100,101]` 

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## EXERCISE: Using the List Monad

A **Pythagorean Triple** is a

- triple of positive integers `a`, `b`, `c`
- such that `a*a + b*b = c*c`

Lets implement a function to return all triples where 

- `a`,`b`,`c` are between `0..n` 

```haskell
pyTriples :: Int -> [(Int, Int, Int)] 
pyTriples n = do
  a <- ???
  b <- ???
  c <- ???
  ???
```

**HINT:** You can write `[i..j]` to generate the list of numbers between `i` and `j`

```haskell
>>> [0..5]
[0,1,2,3,4,5]
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


## Using the List Monad

So lets implement a function 

```haskell
bits :: Int -> [String]
```

Such that

```haskell
>>> bits 0 
[]
>>> bits 1
["0", "1"]
>>> bits 2 
["00", "01", "10", "11"]

>>> bits 3 
["000", "001", "010", "011", "100", "101", "110", "111"]
```

<!-- 
```haskell
bits 0 = return "" 
bits n = do { s <- bits (n-1); c <- ['0', '1']; return (c:s) }
```
-->

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




## Summary

The `Maybe` or `Result` monad instance 

- Conveniently work with computations that *may fail*

Generalize to `List` monad instance

- *empty list* is *failure*
- *non-empty* list is *successes*

Gives us a `for`-loop or iterator *for free*.

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



