module Lec_10_17_23 where

import Prelude hiding (map, foldr)

-- >>> 2 + 1
-- 3

thing2 :: Double
thing2 = 5.1 + 6.9


data CircleT = MkCircle {
  xLoc :: Double,
  yLoc :: Double,
  radius :: Double
}

circle0 :: CircleT
circle0 = MkCircle 0 0 5

area :: CircleT -> Double
area c = pi * radius c * radius c

-- DOUBLE AND DOUBLE AND DOUBLE
data CuboidT = MkCuboid
  { cLength  :: Double,
    cBreadth :: Double,
    cHeight  :: Double
  }

cub0 :: CuboidT
cub0 = MkCuboid 10 20 30

volume :: CuboidT -> Double
volume c = cLength c * cBreadth c * cHeight c

data Shape
  = ShCircle CircleT
  | ShCuboid CuboidT

-- data Shape
--   = MkCir Double Double Double
--   | MkCub Double Double Double


shapes :: [Shape]
shapes = [ShCircle circle0, ShCuboid cub0]

data Shape2D
  = MkRect Double Double -- ^ 'MkRect w h' is a rectangle with width 'w', height 'h'
  | MkCirc Double        -- ^ 'MkCirc r' is a circle with radius 'r'
  | MkPoly [Vertex]      -- ^ 'MkPoly [v1,...,vn]' is a polygon with vertices at 'v1...vn'

type Vertex = (Double, Double)

area2 :: Shape2D -> Double
area2 (MkRect w h) = w * h
area2 (MkCirc r  ) = pi * r * r
area2 (MkPoly vs ) = areaPolygon vs

areaPolygon :: [Vertex] -> Double
areaPolygon (v1:v2:v3:vs) = areaTriangle v1 v2 v3 + areaPolygon (v1:v3:vs)
areaPolygon _ = 0

{-
areaPoly p = case p of
  (v1:v2:v3:vs) -> areaTriangle v1 v2 v3 + areaPolygon (v1:v3:vs)
  _             -> 0

-}

-- areaPolygon [v1,v2,v3]       = areaTriangle v1 v2 v3
-- areaPolygon [v1,v2,v3,v4]    = areaTriangle v1 v2 v3 + areaPolygon [v1,v3,v4]
-- areaPolygon [v1,v2,v3,v4,v5] = areaTriangle v1 v2 v3 + areaPolygon [v1,v3,v4,v5]


areaTriangle :: Vertex -> Vertex -> Vertex -> Double
areaTriangle v1 v2 v3 = sqrt (s * (s - s1) * (s - s2) * (s - s3))
  where
      s  = (s1 + s2 + s3) / 2
      s1 = distance v1 v2
      s2 = distance v2 v3
      s3 = distance v3 v1

distance :: Vertex -> Vertex -> Double
distance (x1, y1) (x2, y2) = sqrt ((x2 - x1) ** 2 + (y2 - y1) ** 2)



--

data IList
  = INil
  | ICons Int IList
  deriving (Show)

data SList
  = SNil
  | SCons String SList
  deriving (Show)

data List t
  = Nil
  | Cons t (List t)
  deriving (Show)

-- >>> size sleupr
-- (1) (2) (3) (4) (5)

blerp :: List String
blerp = Cons "1" (Cons "2" (Cons "3" Nil))

glerp :: List Integer
glerp = Cons 1 (Cons 2 (Cons 3 Nil))

sleupr :: List (List Int)
sleupr = Cons (Cons 1 (Cons 2 Nil)) (Cons (Cons 3 Nil) Nil)

-- append :: List a -> List a -> List a
(+++) :: List t -> List t -> List t
(+++) Nil            ys = ys
(+++) (Cons x1 xs)   ys = Cons x1 (xs +++ ys)

size :: List a -> Int
size = foldr (\_ r -> 1 + r)  0
-- size Nil        = 0
-- size (Cons h t) = op h (size t)
--   where op = \h r -> 1 + r

total :: List Int -> Int
total = foldr (+) 0
-- total Nil = 0
-- total (Cons h t) = h + total t

maxList :: List Int -> Int
maxList = foldr max 0
-- maxList Nil        = 0
-- maxList (Cons h t) = max h (maxList t)

concatList Nil = ""
concatList (Cons h t) = h ++ concatList t


-- total   = megabob (+)  0
-- maxlist = megabob max  0
-- concat  = megabob (++) ""

foldr :: (a -> b -> b) -> b -> List a -> b
foldr op b Nil         = b
foldr op b (Cons h t)  = h `op` foldr op b t

foo2_in :: List Int
foo2_in  = 1 `Cons` (2 `Cons` (3 `Cons` Nil))

foo2_out :: List String
foo2_out = "1" `Cons` ("22" `Cons` ("333" `Cons` Nil))

goo2_out =  1 `Cons` (4 `Cons` (9 `Cons` Nil))

foo3_in = 2 `Cons` (3 `Cons` (1 `Cons` Nil))
foo3_out = "22" `Cons` ("333" `Cons` ("1" `Cons` Nil))

foo4_in = "blue" `Cons` ("cat" `Cons` ("a" `Cons` Nil))
foo4_out = 'b' `Cons` ('c' `Cons` ('a' `Cons` Nil))

goo3_out = 4 `Cons` (9 `Cons` (1 `Cons` Nil))

square :: List Int -> List Int
square = map (\h -> h * h)
-- square Nil        = Nil
-- square (Cons h t) = Cons (h*h) (square t)

-- -- sq h = h * h
-- sq = \h -> h * h

stringify :: List Int -> List String
stringify = map repeet
-- stringify Nil        = Nil
-- stringify (Cons h t) = Cons (repeet h) (stringify t)

firstChars :: List String -> List Char
firstChars = map head
-- firstChars Nil = Nil
-- firstChars (Cons h t) = Cons (head h) (firstChars t)

map :: (t1 -> t2) -> List t1 -> List t2
map op Nil        = Nil
map op (Cons h t) = Cons (op h) (map op t)

mapTree :: (a -> b) -> Tree a -> Tree b
mapTree op (Leaf x)   = Leaf (op x)
mapTree op (Node l r) = Node (mapTree op l) (mapTree op r)



{-

getTimeOfDay
askUserName () = -- asks for input a string and returns that string

foo x = x + 29

... askUserName () ... askUserName () ...


bob Nil        = Nil
bob (Cons h t) = Cons (h*h) (bob t)

bob Nil        = Nil
bob (Cons h t) = Cons (repeet h) (bob t)

bob Nil        = Nil
bob (Cons h t) = Cons (head h) (bob t)

-}

repeet :: Int -> String
repeet 1 = "1"
repeet 2 = "22"
repeet 3 = "333"


{-
foldr op b (h1 `Cons` (h2 `Cons` (h3 `Cons` Nil)))
==> h1 `op` foldr op b (Cons h2 (Cons h3 Nil))
==> h1 `op` (h2 `op` foldr op b (Cons h3 Nil))
==> h1 `op` (h2 `op` (h3 `op` foldr op b Nil))
==> h1 `op` (h2 `op` (h3 `op` b))


-}







bob1 Nil        = 0
bob1 (Cons h t) = h   +   bob1 t

bob2 Nil        = 0
bob2 (Cons h t) = h `max` bob2 t

bob3 Nil        = ""
bob3 (Cons h t) = h ++ bob3 t

plus x y = x + y





data Tree a
  = Leaf a
  | Node (Tree a) (Tree a)
  deriving (Show)

-- >>> (Cons 1 (Cons 2 (Cons 3 Nil))) +++ (Cons 4 (Cons 5 (Cons 6 Nil)))
-- Cons 1 (Cons 2 (Cons 3 (Cons 4 (Cons 5 (Cons 6 Nil)))))

-- >>> "cat" == ['c', 'a', 't']
-- True

foo :: Int -> Int -> Int
foo x y = x + y

-- >>> 10 `foo` 100
-- 110

-- >>> concatTree myOtherTree
-- "onetwothreefourfive"

myTree :: Tree Int
myTree =
  Node
    (Node
      (Node (Leaf 1) (Leaf 2))
      (Node (Leaf 3) (Leaf 4)))
    (Leaf 5)

myOtherTree :: Tree String
myOtherTree =
  Node
    (Node
      (Node (Leaf "one") (Leaf "two"))
      (Node (Leaf "three") (Leaf "four")))
    (Leaf "five")

concatTree :: Tree String -> String
concatTree = foldTree (++) ""
-- concatTree (Leaf str) = str
-- concatTree (Node l r) = concatTree l ++ concatTree r

height :: Tree a -> Int
height = foldTree (\a b -> 1 + max a b) 0
-- height (Leaf _)   = 0
-- height (Node l r) = 1 + max (height l) (height r)

foldTree :: (t -> t -> t) -> t -> Tree a -> t
foldTree _  b (Leaf _)   = b
foldTree op b (Node l r) = lr `op` rr
                              where
                                lr = foldTree op b l
                                rr = foldTree op b r
{-
    let x1 = e1
        x2 = e2
        ...
        xn = en
    in
        e


    e where
        x1 = e1
        x2 = e2
        x3 = en


-}

{-
bob (Leaf x)   = str
bob (Node l r) = op (bob l) (bob r)
  where
    op         = (++)

bob (Leaf x)   = 0
bob (Node l r) = op (bob l) (bob r)
  where
    op         = \a b -> 1 + max a b

-}

-- >>> height myTree
-- 3



-- append (Cons x1 Nil)           ys           = Cons x1          ys
-- append (Cons x1 (Cons x2 Nil)) ys           = Cons x1 (Cons x2 ys)
-- append (Cons x1 (Cons x2 (Cons x3 Nil))) ys = Cons x1 (Cons x2 (Cons x3 ys))
-- append (Cons x1 (Cons x2 (Cons x3 Nil))) ys = Cons x1 (append (Cons x2 (Cons x3 Nil)) ys)

{-

size (Cons (Cons 1 (Cons 2 Nil)) (Cons (Cons 3 Nil) Nil))
-->
1 + size (Cons (Cons 3 Nil) Nil)
-->
1 + (1 + size Nil)
-->
1 + (1 + 0)
-->
2
-}