{-# LANGUAGE PartialTypeSignatures #-}

module Lec_10_20_20 where


type MickeyMouse = (Int, Double)

quiz :: (MickeyMouse, Bool)
quiz = ((7, 5.2), True)

getFst :: (a, b) -> a
getFst (x1, _) = x1

getSnd :: (a, b) -> b
getSnd (_, x2) = x2

example = getFst ((1, "cat"), True)

chars :: [Char]
chars = ['a', 'b', 'c']

ints :: [Int]
ints = [1,2,3,4]

-- type String = [Char]

tuples :: [(Int, Bool)]
tuples = [(1, True), (2, False)]


nil = []

l3 = 3 : nil

l2 = 2 : l3

l1 = 1 : l2


another = 1 : 2 : 3 : []

blergh  = 1 : (2 : (3 : []))


bad = 1 : 2 : []



yutong :: [Int]
yutong = 1 : [2]


copy3 :: a -> [a]
copy3 x = [x, x, x]

clone :: Int -> a -> [a]
-- clone n x 
--   | n > 0     = x : clone (n-1) x
--   | otherwise = []

clone n x = if (n > 0) 
              then x : clone (n-1) x 
              else []

range :: Int -> Int -> [Int]
range n m = if (n > m) then [] else (n : (range (n+1) m)) 



-- >>> range 0 3 
-- [1,2,3]


-- >>> clone 3 "horse"
-- ["horse","horse","horse"]

{- 

clone 3 "cat"

  ==> if (3 > 0) then "cat" : clone (3-1) "cat" else []

  ==> if True then "cat" : clone (3-1) "cat" else []

  ==> "cat" : clone 2 "cat"

  ==> "cat" : ("cat" : clone 1 "cat")

  ==> "cat" : ("cat" : ("cat" : clone 0 "cat"))
  
  ==> "cat" : ("cat" : ("cat" : (if 0 > 0 then ... else []))))

  ==> "cat" : ("cat" : ("cat" : (if False then ... else []))))
  
  ==> "cat" : ("cat" : ("cat" : ([]))))
  
-}


-- >>> clone 50 99
-- [99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99]

-- >>> copy3 9 
-- [9,9,9]

{- 

link [1,2,3] [4,5,6] = [1,2,3,4,5,6]
Can you do?


(A) YES!!!

(B) No!!!!




 -}




-- >>> 3 : (1 : [])
-- [3,1]

-- [1,2,3,4]

-- 1 :( 2 :( 3 :( 4 :[] ) )


-- >>> l1 == another
-- True

-- 1 : (2 : (3 : []))

{- 
  Is : 

  (A) RIGHT ASSOCIATIVE
  (B) LEFT ASSOCIATIVE

 -}









-- >>> getSnd quiz
-- True





add :: Int -> Int -> Int
add x y = x + y


-- >>> add  (1+2)  (3+4)
-- 10




firstElem :: [Int] -> Int
firstElem []    = 0
firstElem (h:t) = h

-- [1,2,3,5]
-- >>> firstElem [1260,12123,123,7,80,1012]
-- 1260
