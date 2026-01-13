module Lec_1_13_26 where

type Circle = (Double, Double, Double)

circ0 :: Circle
circ0 = (0, 0, 500)

-- >>> circleArea circ0

circleArea :: Circle -> Double
circleArea (_, _, r) = pi * r * r

type Cuboid = (Double, Double, Double)

cub0 :: Cuboid
cub0 = (10, 20, 30)

volume :: Cuboid -> Double
volume (l, b, h) = l * b * h
