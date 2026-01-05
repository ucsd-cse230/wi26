module Lec_4_13_20 where


{- 
  this is a long comment 
-}
-- twoPlusZero :: Int
twoPlusZero = 2 + zero

zero :: Int
zero = 0

twoPlusTwo :: Int
twoPlusTwo = 2 + 2

ex :: Double
ex = 3.1 * (4.5 + 3.1)

ex6 :: Int
ex6 = 4 + 5

ex7 :: Int
ex7 = 4 * 5

ex8 :: Bool
ex8 = 5 > 4 

-- >>> 45 + 23
-- 68
--

quiz = if ex8 then ex6 else ex7 


incr :: Int -> Int
-- incr = \n -> n + 1 
incr n = n + 1


mickeyMouse :: Int -> Bool
mickeyMouse n = (n > 0)

-- mickeyMouse 10
-- ==> 10 > 0
-- ==> True

-- mickeyMouse (10 - 100)
-- ==> mickeyMouse (-90)
-- ==> (-90 > 0)
-- ==> False


-- pat :: Int -> (Int -> (Int -> Int))
-- pat = \x -> (\y -> (\z -> x * (y + z)))

pat :: Int -> Int -> Int -> Int
-- pat = \x y z -> x * (y + z)
-- pat x = \y z -> x * (y + z)
-- pat x y = \z -> x * (y + z)
pat x y z = x * (y + z)

-- In1 -> In2 -> In3 -> Out

-- pat 10 20
-- ==> \z -> 10 * (20 + z)

-- sharad 30
-- ==> (pat 10 20) 30 
--

-- 

sharad = pat 10 20

-- >>> pat 10 20 30
-- 500
--
-- (((pat 10) 20) 30)
-- ((((\x -> (\y -> \z -> x * (y + z))) 10) 20) 30)
-- =*> ((\y -> \z -> 10 * (y + z)) 20) 30 
-- ==> (\z -> 10 * (20 + z)) 30
-- ==> 10 * (20 + 30) 
-- ==> 500


-- quiz :: ???
-- quiz2 x y = (x + y) > 0
quiz2 :: (Num a, Ord a) => a -> a -> Bool
quiz2 = \x y -> (x + y) > 0


-- T1 -> (T2 -> (T3 -> (T4 -> T5))))