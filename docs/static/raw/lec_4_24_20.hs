module Lec_4_24_20 where

import Text.Printf

{-
type Cuboid = (Double, Double, Double)
type Circle = (Double, Double, Double)

data CuboidT = MkCuboid 
  { len :: Double
  , wid :: Double 
  , ht  :: Double 
  } deriving (Show)

toString :: CuboidT -> String
toString (MkCuboid d w h) = printf "depth = %f, width = %f, height = %f" d w h

-- construct 
cub1 :: CuboidT

-- destruct / use
volume :: CuboidT -> Double
-- volume c = case c of (MkCuboid l d h) -> l * d * h
volume (MkCuboid l d h) = l * d * h

 
data CircleT = MkCircle 
  { xPos   :: Double
  , yPos   :: Double
  , radius :: Double 
  }


area :: CircleT -> Double
area (MkCircle _ _ r) = pi * r * r

-}
data Circle = MkCir Double Double Double

data Shape 
  = MkCircle Double Double Double   -- ^ Circle at x, y with radius r 
  | MkCuboid Double Double Double   -- ^ Cuboid with length, depth, height

cub1  = MkCuboid 10 20 30 
circ1 = MkCircle 0 0 400

shapes = [cub1, circ1]

{- 

Shape 

  CuboidT extends Shape
  CircleT extends Shape
-}


data Shape2D 
    = MkRect Double Double 
    | MkCirc Double
    | MkPoly [Vertex]

type Vertex = (Double, Double)

area2D :: Shape2D -> Double
area2D (MkRect l b) 
  = l * b
area2D (MkCirc r  ) 
  = pi * r * r
area2D (MkPoly (v1:v2: v3:rest))
  = areaTriangle v1 v2 v3 + area2D (MkPoly (v1:v3:rest))
area2D (MkPoly _)
  = 0

sq = MkPoly [(0,0), (0,100), (100,100), (100,0)]


areaTriangle :: Vertex -> Vertex -> Vertex -> Double
areaTriangle v1 v2 v3 = sqrt (s * (s - s1) * (s - s2) * (s - s3))
  where 
      s  = (s1 + s2 + s3) / 2
      s1 = distance v1 v2 
      s2 = distance v2 v3
      s3 = distance v3 v1

distance :: Vertex -> Vertex -> Double
distance (x1, y1) (x2, y2) = sqrt ((x2 - x1) ** 2 + (y2 - y1) ** 2)

data IList = INil | ICons Int IList

data List a 
  = Nil 
  | Cons a (List a)

myList = Cons 1 (Cons 2 (Cons 3 Nil))


firstElem :: List Int -> Int 
firstElem (Cons h t) = h
firstElem Nil        = 0

-- can `Nil` match `Cons v1 (Cons v2 (Cons v3 Nil))` NO!



isSubSequence :: (Eq a) => [a] -> [a] -> Bool
isSubSequence []     _      = error "fill this in"
isSubSequence _      []     = error "fill this in"
isSubSequence (x:xs) (y:ys) = error "TBD"

