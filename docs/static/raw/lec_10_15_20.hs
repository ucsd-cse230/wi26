{-# LANGUAGE PartialTypeSignatures #-}

module Lec_10_15_20 where

-- this is a comment! 
{- this is ALSO a comment -}

{- 
   10 * (12 + 134)
   54 * (19 + 7)
   98 * (34 + 9)
 -}

-- pat_int :: Int
pat_int = pat 10 12 30

-- pat_dbl :: Double
--- pat_dbl = pat 10.1 12.2 30.3 

isThisDouble :: Double
isThisDouble = 20

myChar :: Char
myChar = 'r'

myBool :: Bool
myBool = False


-- >>> pat_dbl
-- 429.25
--

-- >>> 10 * (12 + 134)
-- 1460
-- >>> ex1 
-- 1460
-- >>> pat 10 12 134
-- 1460
--
silly :: Int
silly = 12

billy :: Int
billy = 12 + 23

milly :: Int
milly = silly + billy

bat = \x y -> x + y

ex1 = pat 10 12 134
ex2 = pat 54 19 7
ex3 = pat 98 34 9




exThen :: Int
exThen = 12

exElse :: Int
exElse = 120

exCond :: Bool
exCond = exThen > exElse

isPos :: Int -> Bool  
isPos = \n -> (n > 0)

blerb = isPos 10
flerb = isPos (100 - 100)


-- pat :: Int -> (Int -> (Int -> Int)) 
-- pat = \x -> \y -> \z -> x * (y + z) 
pat :: Int -> Int -> Int -> Int 
-- pat = \x -> \y -> \z -> x * (y + z) 
-- pat x = \y -> \z -> x * (y + z) 
-- pat x y  = \z -> x * (y + z) 
pat x y z = x * (y + z) 

-- pat 10 20 30 ==> 10 * (20 + 30)
{- 
  LHS = \x -> BODY
  LHS x = BODY
 -}

add :: (Num t) => t -> t -> t
add x y = x + y

add_int :: Int
add_int = add 100 200

add_dbl :: Double
add_dbl = add 100.1 200.3

{- 

lemma :: {x:[a] | x == []} -> {len x = 0}
lemma = \_ -> ()


-}






--
-- \param -> body
-- >>> isPos (100 - 1000)
-- False
--

quizz :: Int -> Int -> Bool 
quizz = \x -> \y -> (x + y) > 0

-- >>> myMax 10 100
-- 100
-- >>> myMax 100 99
-- 100
--


myMax :: Int -> Int -> Int
myMax = \x y -> ite (x > y) x y

ite :: Bool -> t -> t -> t
ite b x y = if b then x else y

-- isPos 12 ==> (\n -> n > 0) 12 ==> (12 > 0) ==> True 

-- True
-- >>> (\n -> n > 0) 12
-- True
--

{-

   \param -> EXPR





(A) False
(B) Compile-time Type Error 
(C) Run-time" Errors


 -}

exErr :: Int
exErr = 10 `div` 0

-- exVansh = True == (\x y -> x)

-- >>> exErr 
-- *** Exception: divide by zero
--

