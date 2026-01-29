---
title: Functors
date: 2023-10-26
headerImg: books.jpg
---

## Abstracting Code Patterns

a.k.a. **Dont Repeat Yourself**

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

### Lists

```haskell
data List a
  = []
  | (:) a (List a)
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

### Rendering the Values of a List

```haskell
-- >>> incList [1, 2, 3]
-- ["1", "2", "3"]

showList        :: [Int] -> [String]
showList []     =  []
showList (n:ns) =  show n : showList ns
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

### Squaring the values of a list

```haskell
-- >>> sqrList [1, 2, 3]
-- 1, 4, 9

sqrList        :: [Int] -> [Int]
sqrList []     =  []
sqrList (n:ns) =  n^2 : sqrList ns
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

## Common Pattern: `map` over a list

Refactor iteration into `mapList`

```haskell
mapList :: (a -> b) -> [a] -> [b]
mapList f []     = []
mapList f (x:xs) = f x : mapList f xs
```

Reuse `map` to implement `inc` and `sqr`

```haskell
showList xs = map (\n -> show n) xs

sqrList  xs = map (\n -> n ^ 2)  xs
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

## Trees

Same "pattern" occurs in other structures!

```haskell
data Tree a
  = Leaf
  | Node a (Tree a) (Tree a)
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

### String Converting the values of a Tree

```haskell
-- >>> showTree (Node 2 (Node 1 Leaf Leaf) (Node 3 Leaf Leaf))
-- (Node "2" (Node "1" Leaf Leaf) (Node "3" Leaf Leaf))

showTree :: Tree Int -> Tree String
showTree Leaf         = ???
showTree (Node v l r) = ???
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

### Squaring the values of a Tree

```haskell
-- >>> sqrTree (Node 2 (Node 1 Leaf Leaf) (Node 3 Leaf Leaf))
-- (Node 4 (Node 1 Leaf Leaf) (Node 9 Leaf Leaf))

sqrTree :: Tree Int -> Tree Int
sqrTree Leaf         = ???
sqrTree (Node v l r) = ???
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## QUIZ: `map` over a Tree

Refactor iteration into `mapTree`! What should the type of `mapTree` be?

```haskell
mapTree :: ???

showTree t = mapTree (\n -> show n) t
sqrTree  t = mapTree (\n -> n ^ 2)  t

{- A -} (Int -> Int)    -> Tree Int -> Tree Int
{- B -} (Int -> String) -> Tree Int -> Tree String
{- C -} (Int -> a)      -> Tree Int -> Tree a
{- D -} (a -> a)        -> Tree a   -> Tree a
{- E -} (a -> b)        -> Tree a   -> Tree b
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Lets write `mapTree`

```haskell
mapTree :: (a -> b) -> Tree a -> Tree b
mapTree f Leaf         = ???
mapTree f (Node v l r) = ???
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

Wait ... there is a common pattern across two _datatypes_

```haskell
mapList :: (a -> b) -> List a -> List b    -- List
mapTree :: (a -> b) -> Tree a -> Tree b    -- Tree
```

Lets make a `class` for it!

```haskell
class Mappable t where
  gmap :: ???
```

What type should we give to `gmap`?

```haskell
{- A -} (b -> a) -> t b    -> t a
{- B -} (a -> a) -> t a    -> t a
{- C -} (a -> b) -> [a]    -> [b]
{- D -} (a -> b) -> t a    -> t b
{- E -} (a -> b) -> Tree a -> Tree b
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

### Reuse Iteration Across Types

Haskell's libraries use the name `Functor` instead of `Mappable`

```haskell
instance Functor [] where
  fmap = mapList

instance Functor Tree where
  fmap = mapTree
```

And now we can do

```haskell
-- >>> fmap (\n -> n + 1) (Node 2 (Node 1 Leaf Leaf) (Node 3 Leaf Leaf))
-- (Node 4 (Node 1 Leaf Leaf) (Node 9 Leaf Leaf))

-- >>> fmap show [1,2,3]
-- ["1", "2", "3"]
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
