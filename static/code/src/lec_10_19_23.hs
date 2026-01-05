module Lec_10_12_23 where
import Data.Time.Format.ISO8601 (yearFormat)

-- >>> 1 + 2
-- 3

-- >>> tails0 [1,2,3]


thing2 :: Double
thing2 = 5.1 + 6.9

thing3 :: Bool
thing3 = True

thing4 :: Char
thing4 = 'c'

ex0 = 5 > 4

thing1 :: Integer
thing1 = 2 * (5 + 6)

-- quiz = if ex0 then thing1 else 20

--  Type_of_INPUT -> Type_of_OUTPUT

quiz :: Bool -> Integer
quiz mickeymouse = if mickeymouse then thing1 else 0


add3 :: Integer -> Integer -> Integer -> Integer
add3 x y z = x + y + z

bob :: (Integer, Bool)
bob = (10 + 12, True)

bob3 :: (Integer, Bool, Char)
bob3 = (10 + 12, True, 'd')


-- (e1, e2, e3) :: (T1, T2, T3)

tup1 :: (Char, Integer)
tup1 = ('a', 5)


tup3 :: ((Int, Double), Bool)
tup3 = ((7, 5.2), True)

blob :: Int
blob = 12


getFst4 :: (a, b,c,d) -> a
getFst4 (x1, x2, x3, x4) = x1

getSnd4 :: (a, b, c, d) -> b
getSnd4 (x1, x2, x3, x4) = x2

-- >>> getSnd4 (1, "horse", 4.5, True)
-- "horse"

tup2 :: (Char, Double, Int)
tup2 = ('a', 5.2, 7)

snd3 :: (t1, t2, t3) -> t2
snd3 (x1, x2, x3) = x2

{-
    snd3 tup2
    =>
    snd3 ('a', 5.2, 7)
    =>
    5.2

-}

chars :: [Char]
chars = ['a','b','c']
        -- ('a' : ('b' : ('c' : [])))

bools :: [Bool]
bools = [True, True, False, False, True]

l1 :: [Int]
l1 = [1,2,3]

l2 :: [Int]
l2 = 1 : 2 : 3 : []


-- >>> l1 == l2
-- True



-- oops = [True, False, 'c']

-- getNth :: Int -> [Stuff] -> Stuff
-- getNth l n = returns the 'nth' element of l

{-
blobs :: [(Int, Int)]
blobs = [(1,2),(3,4),(5,6)]

-}



--   takes an input x and
--   returns a list with three copies of x

copy3 :: t -> [t]
copy3 x = [x,x,x]

-- >>> copy3 "cat"
-- ["cat","cat","cat"]


-- >>> clone 1 "dog"
-- ["dog"]

-- >>> "wom" == ['w', 'o', 'm']
-- True

-- >>> getNth 100005 (clone (-1) "dog")
-- "dog"
{-
   getNth 105 (clone (-1) "dog")
   ==
   getNth 1 ("dog" : clone (-2) "dog")
   ==
   getNth 1 ("dog" : "dog" : clone (-3) "dog")
   ==
   getNth 1 ("dog" : "dog" : "dog" : clone (-4) "dog")
   ==
   getNth 0 (        "dog" : "dog" : clone (-4) "dog")
   ==
   "dog"

-}

-- (1) undefined?
-- (2) looping looping ...
-- (3) type error
-- (4) "dog"

clone :: Int -> String -> [String]
clone 0 x = []
clone n x = x : clone (n-1) x

myHead :: [a] -> a
myHead []     = undefined
myHead (x:xs) = x

-- getNth 0 (x:xs) = x
-- getNth n (x:xs) = getNth (n-1) xs

-- getNth n (x:xs) = if n == 0 then x else getNth (n-1) xs

getNth :: Int -> [a] -> a
getNth n (x:xs)
  | n == 0    = x
  | otherwise = getNth (n-1) xs

-- >>> range 0 3
-- [0,1,2,3]

-- >>> sumList  ['c', 'a', 't']

-- range 4  3 =            []
-- range 3  3 =         3 : []
-- range 2  3 =     2 : 3 : []
-- range 1  3 = 1 : 2 : 3 : []
range :: Int -> Int -> [Int]
range lo hi
  | lo > hi   = []
  | otherwise = lo : range (lo+1) hi


mystery :: [a] -> Int
mystery []     = 0
mystery (x:xs) = 1 + mystery xs


-- sumList :: Num a => [a] -> a
sumList []     = 0
sumList (x:xs) = x + sumList xs

{- mystery (10:20:30:[])
  =
   1 + mystery (20:30:[])
  =
   1 + (1 + mystery (30:[]))
  =
   1 + (1 + (1 + mystery []))
  =
   1 + (1 + (1 + 0))
  =
   3

-}

type Circle = (Double, Double, Double)

circle0 :: Circle
circle0 = (0,0, 5)

-- >>> circleArea circle0
-- 78.53981633974483

circleArea :: Circle -> Double
circleArea (x, y, r) = pi * r * r

type Cuboid = (Double, Double, Double)

cub0 :: Cuboid
cub0 = (10, 20, 30)

-- >>> cubVolume cub0
-- 6000.0

cubVolume :: Cuboid -> Double
cubVolume (l, b, h) = l * b * h

-- >>> cubVolume circle0
-- 0.0

data CircleT = MkCircle Double Double Double

cir1 :: CircleT
cir1 = c 0 0 5

-- >>> vol cir1
-- Couldn't match expected type `CuboidT' with actual type `CircleT'
-- In the first argument of `vol', namely `cir1'
-- In the expression: vol cir1
-- In an equation for `it_a3woO': it_a3woO = vol cir1

area :: CircleT -> Double
area (MkCircle x y r) = pi * r * r

c :: Double -> Double -> Double -> CircleT
c x y r = MkCircle x y r

data CuboidT = MkCuboid Double Double Double

data CC = MkCC { len :: Double, br :: Double, ht :: Double }

vol' :: CC -> Double
vol' c = len c * br c * ht c

vol :: CuboidT -> Double
vol (MkCuboid l b h) = l * b * h

cub1 :: CuboidT
cub1 = MkCuboid 10 20 30


-- area' :: CircleT -> Double
-- area' a  = case a of
--              MkCuboid x y r -> pi * r * r
