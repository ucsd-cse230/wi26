{-# Language GADTs #-}

module Lec_4_22_20 where

firstElem :: a -> [a] -> a
-- firstElem d []      = d 
-- firstElem d (x : _) = x
firstElem d xs = case xs of 
                   [] -> d
                   x:_ -> x

mystery :: [a] -> Int
-- mystery l = case l of
--               [] -> 0
--               x:xs -> 1 + mystery xs
mystery []     = 0
mystery (x:xs) = 1 + mystery xs


secondElem :: a -> [a] -> a
-- secondElem d []      = d
-- secondElem d (_:[])  = d
-- secondElem d (_:x:_) = x
secondElem d xs = case xs of
                    []      -> d
                    (_:[])  -> d
                    (_:x:_) -> x

{- 
  mystery (10 :  20 :  30 : [])
  => 1 + mystery (20 : 30 : [])
  => 1 + (1 + mystery (30 : []))
  => 1 + (1 + (1 + mystery ([]))))
  => 1 + (1 + (1 + 0)))
  => 3  
 -}

sumList           []  = 0
sumlist (h: t)        = h + sumList t
-- sumlist        (3:[]) = 3
-- sumlist    (2: 3: []) = 5
-- sumlist (1: 2: 3: []) = 1 + sumList(2:3:[]) 




type Number = Int

-- >>> foo 
-- 6
--

foo :: Number
foo = 2 + 4

type Circle = (Double, Double, Double)



circ0 :: Circle 
circ0 = (0, 0, 100)

cub0 :: Cuboid
cub0 = (10, 20, 30)

-- >>> area circ0
-- 31415.926535897932
--

-- volume circ0
-- ==> volume (0, 0, 100)
-- ==> 0 * 0 * 100
-- ==> 0



-- "smart constructor"
mkCuboid :: Double -> Double ->Double -> CuboidT
mkCuboid d1 d2 d3 = if d1 >= 0 && d2 >= 0 && d3 >= 0 
                      then MkCuboid d1 d2 d3
                      else error "invalid CUBOID"

circAtOrigin :: Double -> CircleT
circAtOrigin = MkCircle 0 0

circAtPos :: Double -> Double -> CircleT
circAtPos = \x y -> MkCircle x y 100

cub1 :: CuboidT
cub1 = MkCuboid 10 20 30 



type Cuboid = (Double, Double, Double)

-- data CuboidT = MkCuboid Double Double Double 
-- data CircleT = MkCircle Double Double Double 

data CuboidT where 
  MkCuboid :: Double -> Double -> Double -> CuboidT

data CircleT where 
  MkCircle :: Double -> Double -> Double -> CircleT


data List a where
  Nil  :: List a
  Cons :: a -> List a -> List a


volume :: CuboidT -> Double
-- volume (MkCuboid l d h) = l * d * h

volume c = case c of
            (MkCuboid l d h) -> l * d * h

area :: CircleT -> Double
area (MkCircle _ _ r) = pi * r * r



-- quiz = area (MkCuboid 10 20 30)



-- shapes = [(MkCuboid 10 20 30), (MkCircle 0 0 50)]



