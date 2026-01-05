{-# LANGUAGE PartialTypeSignatures #-}

module Lec_10_22_20 where

firstElem :: [Int] -> Int
firstElem []    = 0
firstElem (h:t) = h


-- >>> firstElem [12, 12123,123,7,80,1012]
-- 12

mystery :: [a] -> Int
mystery [] = 0
mystery (x:xs) = 1 + mystery xs

{- 
mystery = \l -> case l of 
                  [] -> 0
                  (x:xs) -> 1 + mystery xs

-}
-- mystery (10 : 20 : 30 : [])
-- ==> 1 + mystery (20 : 30 : [])
-- ==> 1 + 1 + mystery (30 : [])
-- ==> 1 + 1 + 1 + mystery []
-- ==> 1 + 1 + 1 + 0
-- ==> 3



-- | A type definition for Circle

type Circle = (Double, Double, Double)

circ0 :: Circle
circ0 = (0, 0, 100)

circ1 :: Circle
circ1 = (10, 25, 350)

area :: Circle -> Double
area = \c -> case c of 
               (_, _, r) -> pi * r * r 

-- >>> area circ1
-- 384845.1000647496


type Cuboid = (Double, Double, Double)

cub0 :: Cuboid
cub0 = (10, 20, 30)

volume :: Cuboid -> Double
volume = \t -> case t of 
                 (l, b, h) -> l * b * h

-- >>> volume circ0
-- 0.0




-- -- | A new type `CircleT` with constructor `MkCircle`
-- data CircleT = MkCircle Double Double Double     


-- -- >>> :t MkCircle 
-- -- MkCircle :: Double -> Double -> Double -> CircleT

-- circ0' :: CircleT
-- circ0' = MkCircle 0 0 100

-- circ1' :: CircleT
-- circ1' = MkCircle 10 25 350


-- -- quiz = volume circ0'

-- -- >>> :t MkCuboid
-- -- MkCuboid :: Double -> Double -> Double -> CuboidT


-- -- | A new type `CuboidT` with constructor `MkCuboid`
-- data CuboidT = MkCuboid Double Double Double

-- cub0' :: CuboidT
-- cub0' = MkCuboid 10 20 30

-- volume' :: CuboidT -> Double
-- volume' = \c ->  case c of
--                    MkCuboid l b h -> l * b * h

-- >>> volume' cub0'
-- 6000.0

circ0' :: Shape
circ0' = MkCircle 0 0 100

cub0' :: Shape
cub0' = MkCuboid 10 20 30


data Shape 
  = MkCircle Double Double Double   -- ^ Circle at x, y with radius r 
  | MkCuboid Double Double Double   -- ^ Cuboid with length, depth, height




shapes :: [Shape] 
shapes = [circ0', cub0']

{- 

class Shape 
class CircleT extends Shape
class CuboidT extends Shape

interface Shape 
class CircleT implements Shape
class CuboidT implements Shape


-}




data Shape2D 
  = MkRect Double Double -- ^ 'MkRect w h' is a rectangle with width 'w', height 'h'
  | MkCirc Double        -- ^ 'MkCirc r' is a circle with radius 'r'
  | MkPoly [Vertex]      -- ^ 'MkPoly [v1,...,vn]' is a polygon with vertices at 'v1...vn'

type Vertex = (Double, Double)

area2d :: Shape2D -> Double
area2d (MkRect w h) = h * w
area2d (MkCirc r  ) = pi * r * r
area2d (MkPoly vs ) = areaPolygon vs

areaPolygon :: [Vertex] -> Double
areaPolygon (v1:v2:v3:rest) = areaTriangle v1 v2 v3 + areaPolygon (v1: v3: rest)
areaPolygon (_)             = 0

areaTriangle :: Vertex -> Vertex -> Vertex -> Double
areaTriangle v1 v2 v3 = sqrt (s * (s - s1) * (s - s2) * (s - s3))
  where 
      s  = (s1 + s2 + s3) / 2
      s1 = distance v1 v2 
      s2 = distance v2 v3
      s3 = distance v3 v1

distance :: Vertex -> Vertex -> Double
distance (x1, y1) (x2, y2) = sqrt ((x2 - x1) ** 2 + (y2 - y1) ** 2)




----

data IntList = INil 
             | ICons Int IntList

data StrList = SNil 
             | SCons String StrList

data List a  = Nil 
             | Cons a (List a)

-- >>> :t Cons
-- Cons :: forall a. a -> List a -> List a

mystery' :: List a -> Int
mystery' l = case l of
                Nil -> 0
                Cons x xs -> 1 + mystery' xs

ints :: List Integer
ints = 1 `Cons` (2 `Cons` (3 `Cons` Nil))

strs :: List [Char]
strs = "1" `Cons` ("2" `Cons` ("3" `Cons` Nil))

























