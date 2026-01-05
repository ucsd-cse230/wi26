module Lec_4_29_20 where

import Data.Char

-- >>> inc 100
-- 101
--

inc :: Int -> Int 
inc x = x + 1

-- >>> squares [1,2,3,4,5]
-- [1,4,9,16,25]

squares :: [Int] -> [Int]
squares []    = []
squares (h:t) = (h * h) : squares t



-- >>> shout "hello"
-- "HELLO"
--

shout :: [Char] -> [Char]
shout []     = []
shout (c:cs) = toUpper c : shout cs 

-- mymap :: (Int -> Int) -> [Int] -> [Int]

mymap :: (a -> b) -> [a] -> [b]
mymap f []     = []
mymap f (x:xs) = f x : mymap f xs 

{- 
 (in -> out) -> [in] -> [out]
 f :: in -> out
 x :: in
 -}



-- >>> shout' "hello"
-- "HELLO"
--
shout' = mymap toUpper -- a := 'Char'

-- >>> squares' [1,2,3,4,5]
-- [1,4,9,16,25]
--

squares' = mymap (\h -> h * h) -- a := Int

-- >>> asciiVals "hello"
-- [104,101,108,108,111]
--
asciiVals :: [Char] -> [Int]
asciiVals cs = mymap ord cs


{- 
foo []     = []
foo (h:t)  = (h * h) : foo t

foo []     = []
foo (c:cs) = toUpper c : foo cs 


-}





-- >>> sumz [] []
-- []
-- >>> sumz [3] [30]
-- [33]
-- >>> sumz [2,3] [20,30]
-- [22, 33]
-- >>> sumz [1,2,3] [10,20,30]
-- [11, 22, 33] 


sumz :: [Int] -> [Int] -> [Int]
sumz []     []     = []
sumz (x:xs) (y:ys) = (x+y) : (sumz xs ys)

{- 
sumz l1 l2 = case l1 of
                [] -> []
                (x:xs) -> case l2 of
                            [] -> []
                            (y:ys) -> (x+y) : (sumz xs ys)
-}

-- >>> total [(10, 20), (15, 5), (21, 22), (14, 16)]
-- [30,20,43,30]


total :: [(Int, Int)] -> [Int]
total = mymap (\(x1,x2) -> x1 + x2) 

{-
foo []     = 0
foo (x:xs) = x + foo xs

foo []     = "" 
foo (x:xs) = x ++ foo xs
-}

myfoldr op b []     = b
myfoldr op b (x:xs) = op x (myfoldr op b xs)

sumList xs = myfoldr (\x y -> x + y)  0  xs 
catList xs = myfoldr (\x y -> x ++ y) "" xs 
