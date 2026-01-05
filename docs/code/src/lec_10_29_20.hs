{-# LANGUAGE PartialTypeSignatures #-}

module Lec_10_29_20 where

-- map 
-- foldr 
-- foldl 
-- treeFold
-- dirFold
import Data.Char ( toUpper )

sq :: Int -> Int
sq x = x * x

{-
foo :: [Int] -> [Int]
foo xs = case xs of
  [] -> []
  x:xs' -> (sq x) : (foo xs')

foo' :: String -> String 
foo' xs = case xs of
  [] -> []
  x:xs' -> (toUpper x) : (foo' xs')

listIter f xs = case xs of 
  [] -> []
  (x:ys) -> (f x) : (listIter f ys)

-}
squares = map sq

shout = map toUpper

{- 
foo op xs = case xs of
                [] -> []
                x:xs' -> (op x) : (foo op xs')



squares = listIter sq


listIter :: (a -> b) -> [a] -> [b]
listIter f = \xs -> case xs of 
  [] -> []
  (x:ys) -> (f x) : (listIter f ys)

-}





-----------------

-- >>> sumList [1,2,3,4]
-- 10

-- >>> sumList []
-- 0

-- >>> sumList [3, 4]
-- 7

-- >>> sumList' [1,2,3,4]
-- 10

sumList :: [Int] -> Int
sumList []     = 0
sumList (x:xs) = x + sumList xs

-- >>> concatList' [ "nov3", "already"]
-- "nov3already"

concatList :: [String] -> String
concatList []     = ""
concatList (x:xs) = x ++ concatList xs

add x y = x + y

-- >>> 10 `add` 20
-- 30

{-

foo op b (x1 : (x2 : (x3 : (x4 : []))))

==> op x1 (foo op b (x2 : x3 : x4 : []))

==> op x1 (op x2 (foo op b (x3 : x4 : [])))

==> op x1 (op x2 (op x3 (foo op b (x4 : [])))

==> op x1 (op x2 (op x3 (op x4 (foo op b []))))

==> x1 `op` (x2 `op` (x3 `op` (x4 `op` b)))


-}



sumList' :: [Int] -> Int
sumList' = foo (+) 0

concatList' :: [[Char]] -> [Char]
concatList' = foo (++) ""

-- >>> len "i am the walrus"
-- 15

len :: [a] -> Int
len = foo (\x xs -> 1 + xs) 0

foo :: (a -> b -> b) -> b -> [a] -> b  
foo op b []     = b
foo op b (x:xs) = op x (foo op b xs)




{- 

sumList [] = 0
sumList (x:xs) = x + sumList xs

sumList' tot [] = tot 
sumList' tot (x:xs) = sumList' (tot + x) xs 





foldl o b []      = b 
foldl o b (x1:xs) = foldl o (b `o` x1) xs

 foldl o b (x1:x2:x3:[])
 
 ==> foldl o (b `o` x1) (x2:x3:[])
 
 ==> foldl o ((b `o` x1) `o` x2) (x3:[])
 
 ==> foldl o (((b `o` x1) `o` x2) `o` x3) []
 
 ==> (((b `o` x1) `o` x2) `o` x3)
-}



data Tree a = Leaf | Node a (Tree a) (Tree a)
  deriving (Show)


treeN :: a -> Tree a
treeN n = Node n Leaf Leaf

tree3 :: Tree Int
tree3 = treeN 3

tree2 :: Tree Int
tree2 = treeN 2

tree1 = Node 1 tree2 tree3

ht :: Tree a -> Int 
ht Leaf         = 1
ht (Node v l r) = 1 + max (ht l) (ht r)

sumTree :: Tree Int -> Int
sumTree Leaf         = 0 
sumTree (Node v l r) = v + sumTree l + sumTree r

bar :: (a -> b -> b -> b) -> b -> Tree a -> b
bar op b Leaf         = b
bar op b (Node v l r) = op v (bar op b l) (bar op b r)

ht' :: Tree a -> Int
ht' = bar (\v hl hr -> 1 + max hl hr) 1

sumTree' :: Tree Int -> Int
sumTree' = bar (\v sl sr -> v + sl + sr) 0

{- 

bar Leaf         = 1
bar (Node v l r) = 1 + max (bar l)  (bar r)

bar Leaf         = 0 
bar (Node v l r) = v +     (bar l) + (bar r)

-}


-- >>> ht tree2
-- 2

-- >>> ht tree3
-- 2
-- >>> ht tree1
-- 3