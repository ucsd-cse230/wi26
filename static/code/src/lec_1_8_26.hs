{- HLINT ignore "Eta reduce" -}
module Lec_1_8_26 where

bob :: (Int, Bool)
bob = (10 + 12, True)

bob3 :: (Int, Bool, Char)
bob3 = (10 + 12, 10 > 2, 'd')

funnyTuple :: (Integer, Double, Bool)
funnyTuple = (7, 5.2, True)



blah1 :: (a, b, c) -> a
blah1  (a, _, _) = a

blah2 :: (a, b, c) -> b
blah2 (_, x2, _) = x2

blah3 :: (a, b, c) -> c
blah3 (_, _, x3)= x3

badList = [1, 2, 3]

blah0 :: [t] -> t
blah0 []              = error "oh no..."
blah0 (firstElem : _) = firstElem

-- >>> blah0 []
-- oh no empty list!!!aaaa!!

-- Data.Vector

-- >>> getElem ["cat", "dog", "mnouse"] 2
-- yikes DEAD.

getElem :: [t] -> Int -> t
getElem (h:_) 0 = h
getElem (_:t) i = getElem t (i - 1)
getElem []    _ = error "yikes DEAD."

-- >>> divideBy 20 0
-- ProgressCancelledException

divideBy :: Int -> Int -> Int
divideBy n m = if m /= 0
                 then div n m
                 else divideBy n m


-- 1. CHECKTHAT(n:Int, m:Int  |-  m /= 0,  Bool)           OK!


-- 2. CHECKTHAT(n:Int, m:Int  |- div n m,  Int)           OK!

-- 3. CHECKTHAT(n:Int, m:Int, divideBy: Int -> Int -> Int  |-  divideBy n m,  Int)      OK!


-- CHECKTHAT(n:Int, m:Int,  if e1 then e2 else e3,  Int)


foo :: Int -> [Int]
foo n  = [n-1, n, n+1]

-- >>> clone 20 "dog"
-- /Users/rjhala/teaching/230-wi26/static/code/src/lec_1_8_26.hs:(47,1)-(50,29): Non-exhaustive patterns in function clone


clone 0 _   = []
clone n cat = cat: clone (n-1) cat


-- >>> range 0 2
-- /Users/rjhala/teaching/230-wi26/static/code/src/lec_1_8_26.hs:(56,1)-(60,21): Non-exhaustive patterns in function range

-- range lo hi ==> [lo, lo+1, lo+2 ... hi]
-- >>> range 10 20
-- [10,11,12,13,14,15,16,17,18,19,20]

-- >>> getElem (range 10 20) 35
-- 13


range :: Int -> Int -> [Int]
range lo hi
  | otherwise = lo : range (lo + 1) hi
  | lo > hi   = []

{-
(A) _
(B) False
(C) True
(D) else

-}

-- range 4 3 =        []
-- range 3 3 =       [3]
-- range 2 3 =     [2,3]
-- range 1 3 =   [1,2,3]
-- range 0 3 = 0:(range 1 3)



{-

blah t (i-1)

blah t i - 1



blah list idx = if idx == 0
                    then case list of
                           h : _ -> h
                           _     -> error "DUIE"
                    else  case list of
                           _ : t -> blah t (i-1)
                           _     -> error "ASDASDASD"



blah [0,10,20] 3 = YIKES

* "return last elem"
* CRASH somehow with error message
+ undefined
* "optional" / null
+ loop forever!

-}

-- blah :: (a, b, c, d, e) -> Int -> ???
-- blah tuple index = returns i-th element of that tuple


{-

blah1 funnyTuple = 7
blah2 funnyTuple = 5.2
blah3 funnyTuple = True

-}


























nextThree :: Int -> [Int]
nextThree n = [n, n + 1, n + 2, n + 3]

nextK n 0 =                      [n]
nextK n 1 =               [n, n + 1]
nextK n 2 =        [n, n + 1, n + 2]
nextK n 3 = [n, n + 1, n + 2, n + 3]
nextK n _ = error "OH NO!!!!"




type Circle = (Double, Double, Double)

circ0 :: Circle
circ0 = (0, 0, 500)

-- >>> circleArea cub0
-- 2827.4333882308138

circleArea :: Circle -> Double
circleArea (_, _, r) = pi * r * r

type Cuboid = (Double, Double, Double)

cub0 :: Cuboid
cub0 = (10, 20, 30)

volume :: Cuboid -> Double
volume (l, b, h) = l * b * h


-- nameOfDay d = case d of
--                      0 -> "sunday"
--                      1 -> "monday"
--                      _ -> "tuesday"

-- nameOfDay 0 = "sunday"
-- nameOfDay 1 = "monday"
-- nameOfDoy _ = "tuesday"



-- tuesday :: Integer
-- tuesday = 99
-- tuesday = 46
