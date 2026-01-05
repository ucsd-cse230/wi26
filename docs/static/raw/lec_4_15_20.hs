module Lec_4_15_20 where

-- >>> myMax 10 20
-- 20
--

-- >>> myMax 100 5
-- 100
--

-- >>> myMax 'a' 'b'
-- 'b'
--


-- >>> myMax 3.1 'a'
-- 4.8


-- p implements Ord
-- myMax :: Int -> Int -> Int
myMax :: (Ord a) => a -> a -> a
myMax x y = if x >= y then x else y

{- 

A myMax<A implements Ord>(x: A, y: A) {

}

 -}

tup1 :: (Char, Int)
tup1 = ('a', 5) 



-- >>> getFst tup1
-- 'a'
--

-- >>> getSnd tup1
-- 5
--

getFst :: (t1, t2) -> t1
getFst p = case p of  
             (x1, x2) -> x1


getSnd :: (t1, t2) -> t2
getSnd p = case p of  
             (x1, x2) -> x2


-- >>> addPair (10, 20)
-- 30

-- >>> addPair (10, 200)
-- 210
--

-- internal representation
addPair :: (Int, Int, Int) -> Int 
addPair p = case p of
              (x1, x2, _) -> x1 + x2

-- nicer syntax
-- addPair (x1, x2) = x1 + x2




add2 :: Int -> Int -> Int
add2 = \x1 x2 -> x1 + x2 

-- (T1, T2)
-- (T1, T2, T3)
-- (T1, T2, T3, T4)








tup2 :: (Char, Double, Int)
tup2 = ('a', 5.2, 7) 

-- snd3 (x1, x2, x3) = x2

-- snd3 tup2
-- => snd3 ('a', 5.2, 7)
-- => 5.2

chars :: [Char]
chars = ['a','b','c'] 

ints :: [Int]
ints = [1,3,7]

pairs :: [(Int, Bool)]
pairs = [ (1,True), (2,False)]

things :: [ [Int] ] 
things = [ [1], [2, 3], [4, 5, 6] ] 


emptyList = []

one_empty = 1 : []

two_one_empty = 2 : 1 : []

-- >>> three_two_one_empty
-- [3,2,1]
--
three_two_one_empty = 3: 2 : 1 : []

-- >>> sumList three_two_one_empty 
-- 6 

sumList :: [Int] -> Int
sumList = _fixme

-- >>> insertAtEnd 1 [2,3,4]
-- [2,3,4,1]
--

insertAtEnd :: thing -> [thing] -> [thing]
insertAtEnd x ys = ys ++ [x]

-- >>> [1,2,3,4] ++ [5,6,7,8]
-- [1,2,3,4,5,6,7,8]
--
-- >>> getFirstElem [1,2,3,4]
-- 1
--


getFirstElem :: [a] -> a
getFirstElem xs = case xs of
                    h:t -> h


getNth :: Int -> [a] -> a
getNth n xs = xs !! n

-- CONS 3 (CONS 2 (CONS 1 EMP)) 