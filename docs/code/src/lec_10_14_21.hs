module Lec_10_12_21 where

import Prelude hiding (map, foldr)
import Data.Char (ord, toUpper)

-- rename 'squares' to 'foo'
foo1 []     = [] 
foo1 (x:xs) = sq x : foo1 xs

-- >>> foo1 [1,2,3,4]
-- [1,4,9,16]

sq x = x * x 

-- rename 'shout' to 'foo'
foo2 []     = [] 
foo2 (x:xs) = toUpper x : foo2 xs

-- generalize as map 
--- map :: (a -> a) -> [a] -> [a]
map op [] = [] 
map op (x:xs) = op x : map op xs

squares :: [Int] -> [Int]
squares = map sq 

angry :: [Char] -> [Char]
angry xs = map toUpper xs

funky :: [Char] -> [Int]
funky = map ord 

-- >>> funky "cat"
-- [99,97,116]

{- 
  foo x y = bar y x 

 -}


-- >>> (map sq) [1,2,3,4]

-- >>> angry "hello"
-- "HELLO"

-- squares [1,2,3,4,5] = [1,4,9,16,25]


type Score = (Int, Int)

bob :: [Score] -> [Int]
bob = map (\(x, y) -> x + y)


-- listSum :: [Int] -> Int 
-- listSum [] = 0
-- listSum (x:xs) = x + listSum xs

-- listMax def []     = def
-- listMax def (x:xs) = x `max` (listMax def xs) 
listSum :: [Int] -> Int
listSum = myfoldr (+) 0

listMax :: Int -> [Int] -> Int
listMax = myfoldr max 

myfoldr op base []      = base
myfoldr op base (x:xs)  = x `op` (myfoldr op base xs)

-- size :: [a] -> Int 
-- -- size []     = 0
-- -- size (x:xs) = 1 + size xs
-- size = foldr ?op ?base 

{- 

size = foldr (+) 0 

-}

mySize :: [t] -> Int
mySize = myfoldr (\_ n -> n + 1) 0


-- mySize = myfoldr (\x -> x + 1) 0
-- >>> mySize  [1,2,3,4,5]
-- 5


{- 
foldr op b (x1:x2:x3:x4:[])

  ==> x1 `op` foldr op b (x2:x3:x4:[])
  ==> x1 `op` (x2 `op` foldr op b (x3:x4:[]))
  ==> x1 `op` (x2 `op` (x3 `op` foldr op b (x4:[])))
  ==> x1 `op` (x2 `op` (x3 `op` (x4 `op` foldr op b [])))

  ==> x1 `op` (x2 `op` (x3 `op` (x4 `op` b)))


-}


{- 

bar op base []      = base
bar op base (x:xs)  = x `op` bar op base xs



listSum []         = 0
listSum (x:xs)     = x + listSum xs

bar def []     = def
bar def (x:xs) = x `max` (bar def xs) 


-}



-- >>> max 10 2
-- 10

-- >>> listSum [1,3,4,5]
-- 13


data Tree a 
  = Leaf 
  | Node a (Tree a) (Tree a)
  deriving (Show)


t2 :: Tree Int
t2 = Node 1 
      (Node 2 
        Leaf 
        Leaf) 
      (Node 3 
        Leaf 
        (Node 4 
          Leaf 
          Leaf)) 




treeSum :: Tree Int -> Int
treeSum Leaf         = 0
treeSum (Node v l r) = v + treeSum l + treeSum r 

treeSum' :: Tree Int -> Int
treeSum' = pat (\v l r -> v + l + r) 0

treeHeight :: Tree Int -> Int
treeHeight Leaf         = 1
treeHeight (Node v l r) = 1 + max (treeHeight l) (treeHeight r)

treeHeight' :: Tree Int -> Int
treeHeight' = pat (\v l r -> 1 + max l r) 0

treeMax :: Tree Int -> Int
treeMax = pat f b
  where 
     f  = \v l r -> maximum [v, l, r]
     b  = 0 

-- >>> treeHeight' t2
-- 3

pat op b Leaf         = b 
pat op b (Node v l r) = op v (pat op b l) (pat op b r) 


{- 
pat Leaf           = 0
pat (Node v l r)   = v +      pat l + pat r 

pat Leaf           = 1
pat (Node v l r)   = 1 + max (pat l) (pat r)



-}
 
