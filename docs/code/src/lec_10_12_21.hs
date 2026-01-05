module Lec_10_12_21 where

import Debug.Trace
import Data.Char (toUpper)
import Prelude hiding (map)

type Circle = (Double, Double, Double)

data CircleT = MkCircle Double Double Double


type Cuboid = (Double, Double, Double)

data CuboidT = MkCuboid 
  { cubLen :: Double 
  , cubHgt :: Double 
  , cubDep :: Double
  }
  deriving (Show)

-- >>> ex1 == ex2
-- True


exCirc :: Shape
exCirc = MkCirc 1.1 2.2 3.3

exCuboid :: Shape
exCuboid = MkCube 1.1 2.2 3.3

data Shape'
  = ShCube CuboidT
  | ShCirc CircleT

area' :: Shape' -> Double
-- area' (ShCirc (MkCircle _ _ r)) = pi * r * r
-- area' (ShCube (MkCuboid l b h)) = 2 * l * b + 2 * l * h + 2 * b * h
area' (ShCirc circ) = areaCircleT circ 
area' (ShCube cube) = areaCuboidT cube

areaCircleT :: CircleT -> Double
areaCircleT (MkCircle _ _ r) = pi*r*r

areaCuboidT :: CuboidT -> Double
areaCuboidT (MkCuboid l b h) = 2*(l*b + b*h + l*h)


data Shape 
  = MkCube Double Double Double
  | MkCirc Double Double Double

area :: Shape -> Double
area (MkCirc _ _ r) = pi * r * r
area (MkCube l b h) = 2 * l * b + 2 * l * h + 2 * b * h

shapes :: [Shape]
shapes = [exCirc, exCuboid]

{- 

interface Shape {
    volume ...

}

Array<Shape> shapes = new Array(exCirc, exCub) 

Shape foo = shapes[0]

-}



-- >>> cubDep exCuboid
-- 3.3

-- >>> area (MkCube 10 20 30)

 

volume :: Shape -> Double
volume c = case c of 
             MkCube l b h -> l * myTrace "b =" b * h

foo = trace

myTrace :: Show a => String -> a -> a
myTrace msg x = trace ("TRACE: " ++ msg ++ " " ++ show x) x 




idk = pi

data IntList 
  = INil
  | ICons Int IntList
  deriving (Show)

data CharList 
  = CNil
  | CCons Char CharList
  deriving (Show)

data List a 
  = Nil 
  | Cons a (List a)
  deriving (Show)

-- List is "TYPE CONSTRUCTOR"



-- Nil ???

foo' :: Int -> Int
foo' x = x + 1

-- 'c', 'a', 't'
exChars :: List Char 
exChars = 'c' `Cons` ('a' `Cons` ('t' `Cons` Nil)) 


-- 1, 2, 3, 4
exInts :: List Int
exInts =  1 `Cons` (2 `Cons` (3 `Cons` (4 `Cons` Nil))) 


data Shape2D 
  = MkRect2 Double Double 
  | MkCirc2 Double        
  | MkPoly2 [Vertex]      

type Vertex = (Double, Double)

area2D :: Shape2D -> Double
area2D (MkRect2 w h) = w * h 
area2D (MkCirc2 r)   = pi * r * r 
area2D (MkPoly2 vs)  = areaPoly vs 

areaPoly :: [Vertex] -> Double
areaPoly (v1 : v2 : v3 : rest) = areaTriangle v1 v2 v3 + areaPoly (v1: v3: rest)
areaPoly _ =  0 
  -- [v1, v2, v3, v4, v5] -> areaTriangle v1 v2 v3 + areaPoly [v1, v3, v4, v5]
  -- [v1, v2, v3, v4, v5, v6] -> areaTriangle v1 v2 v3 + areaPoly [v1, v3, v4, v5, v6]

-- 
areaTriangle :: Vertex -> Vertex -> Vertex -> Double
areaTriangle v1 v2 v3 = sqrt (s * (s - s1) * (s - s2) * (s - s3))
  where 
      s  = (s1 + s2 + s3) / 2
      s1 = distance v1 v2 
      s2 = distance v2 v3
      s3 = distance v3 v1


distance :: Vertex -> Vertex -> Double
distance (x1, y1) (x2, y2) = sqrt ((x2 - x1) ** 2 + (y2 - y1) ** 2)

map op [] = [] 
map op (x:xs) = op x : map op xs


squares :: [Int] -> [Int]
squares xs = map sq xs
sq x = x * x

angry :: [Char] -> [Char]
angry xs = map toUpper xs

-- >>> squares [1,2,3,4]
-- [1,4,9,16]

-- >>> angry "hello"
-- "HELLO"

-- squares [1,2,3,4,5] = [1,4,9,16,25]