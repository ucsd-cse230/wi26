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


-- data CircleT = MkCircle { x :: Double, y:: Double, radius :: Double }
data CircleT = MkCircle Double Double Double
  deriving (Show)

data CuboidT = MkCuboid { l :: Double, b :: Double, h :: Double }
  deriving (Show)

data Funky = McFunky { n::Int, boo :: Bool, s:: String }

-- McFunky :: Int -> Bool -> String -> Funky

-- blaaaa = McFunky True

crc0 :: CircleT
-- crc0 = MkCircle { radius = 100, y = 0, x = 0}
crc0 = MkCircle 100 0 0

cubb0 :: CuboidT
cubb0 = MkCuboid 10 20 30


cubVolume :: CuboidT -> Double
cubVolume c = case c of
                MkCuboid len breadth height -> len * breadth * height

circArea :: CircleT -> Double
-- circArea (MkCircle radus _ _  ) = pi * radus * radus
circArea c = pi * r * r
  where
    r = radius c

radius :: CircleT -> Double
radius c = case c of
            MkCircle _ _ r -> r


data Shape
    = ShCircle CircleT
    | ShCuboid CuboidT
    deriving (Show)

shapes :: [Shape]
shapes = [ ShCuboid cubb0, ShCircle crc0 ]

-- >>> circArea cubb0
-- Couldn't match expected type `CircleT' with actual type `CuboidT'
-- In the first argument of `circArea', namely `cubb0'
-- In the expression: circArea cubb0
-- In an equation for `it_a3zH1': it_a3zH1 = circArea cubb0


-- 0 0 100
-- 10 20 30

data Seq
  = Emp
  | Push Int Seq
  deriving(Show)

seqEmp :: Seq
seqEmp = Emp

seq3 :: Seq
seq3 = Push 3 Emp

seq23 :: Seq
seq23 = Push 2 seq3

seq123 :: Seq
seq123 = Push 1 seq23

-- >>> seq123
-- Push 1 (Push 2 (Push 3 Emp))
