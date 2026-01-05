{-# LANGUAGE PartialTypeSignatures #-}
{-# LANGUAGE DeriveFunctor #-}

module Lec_10_27_20 where

import Data.Char (toUpper)

--- type synonym
type Date = (Int, Int, Int)

today :: Date
today = (10, 27, 2020)

--- type synonym
data DateT = MkDate Int Int Int

todayT :: DateT
todayT = MkDate 10 27 2020

----------

data IntList 
  = INil 
  | ICons Int IntList

ints :: IntList
ints = ICons 1 (ICons 2 (ICons 3 INil))

data StrList 
  = SNil 
  | SCons String StrList




strings :: StrList
strings = SCons "1" (SCons "2" (SCons "3" SNil))


----------


doTwice :: (a -> a) -> a -> a
doTwice f x = f (f x)


inc :: Int -> Int
inc x = x + 1

yum :: String -> String
yum s = s ++ " yum!" 

-- >>> doTwice inc 100  
-- 102

-- >>> doTwice yum "burrito"
-- "burrito yum! yum!"

-- >>> doTwice inc "burrito"
-- Couldn't match expected type ‘Int’ with actual type ‘[Char]’

greaterThan :: Int -> Int -> Bool
greaterThan x = \y -> x > y

-- quiz = doTwice (greaterThan 10) 0

{- doTwice (greaterThan 10) 0
   ==> (greaterThan 10) ((greaterThan 10) 0)
   ==> (greaterThan 10) (10 > 0)
   ==> (greaterThan 10) True 
   ==> 10 > True 

-}

apply :: a -> (a -> b) -> b 
apply x f = f x


quiz = apply 100 (greaterThan 10)

-- >>> quiz 
-- False

{- apply 100 (greaterThan 10)
   ==> (greaterThan 10) 100
   ==> 10 > 100
   ==> False
-}

data IntTree 
  = ILeaf 
  | INode Int IntTree IntTree

tree :: IntTree
tree = INode 1 (INode 2 ILeaf ILeaf) (INode 3 ILeaf ILeaf)

-----------------------------
data List a 
  = Nil 
  | Cons a (List a) 

-- example = Cons 1 (Cons "cat" Nil)
-- >>> :t Cons
-- Cons :: forall a. a -> List a -> List a

{-  
What is the type of `Cons` ? 

(A) `List a`
(C) `a -> List a`
(D) `a -> List a -> List a`


(A) `List a`
(B) `a`
(C) `a -> List a`
(D) `a -> List a -> List a`
(E) `List a -> a`

-}




data Tree a 
  = Leaf 
  | Node a (Tree a) (Tree a) 
  deriving (Functor, Show)

type ListInt = List Int
type ListStr = List String
type TreeInt = Tree Int

-----------------------------

-- List Int
-- List Bool
-- List a



sq x = x * x

{- 
foo xs = case xs of
                [] -> []
                x:xs' -> (sq x) : (foo xs')

foo :: String -> String 
foo xs = case xs of
                [] -> []
                x:xs' -> (toUpper x) : (foo xs')

foo op xs = case xs of
                [] -> []
                x:xs' -> (op x) : (foo op xs')

listIter f xs = case xs of 
        [] -> []
        (x:ys) -> (f x) : (listIter f ys)
  

squares = listIter sq

-}

listIter :: (a -> b) -> [a] -> [b]
listIter f = \xs -> case xs of 
  [] -> []
  (x:ys) -> (f x) : (listIter f ys)


treeIter :: (a -> b) -> Tree a -> Tree b
treeIter f = \t -> case t of
  Leaf -> Leaf
  Node x l r -> Node (f x) (treeIter f l) (treeIter f r)




-- >>> fmap sq [1,2,3]
-- [1,4,9]

-- >>> fmap sq (Node 1 (Node 2 Leaf Leaf) (Node 3 Leaf Leaf))
-- Node 1 (Node 4 Leaf Leaf) (Node 9 Leaf Leaf)

-- >>> :t fmap 
-- fmap ::  (a -> b) -> t a -> t b

shout :: String -> String
shout str = listIter toUpper str 

{- 
shout = listIter toUpper 

shout = \xs -> case xs of 
        [] -> []
        (x:ys) -> (f x) : (shout ys)

-}


-- where did the 'xs' go?
-- >>> shout "hello!"
-- "HELLO!"

-- >>> shout ['v', 'o', 't', 'e']
-- "VOTE"




































