{- HLINT ignore "Eta reduce" -}
{- HLINT ignore "Use uncurry" -}
module Lec_1_15_26  where


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

forever :: Int -> [Int]
forever k = k : forever (k + 1)

get2 :: [a] -> a
get2 (_:(x:_)) = x
get2 _         = error "DEATH!"

-- >>> get2 (forever 3)
-- 4

{-
  get2 (forever 3)
  ==
  get2 (3 : forever 4)
  ==
  get2 (3 : (4 : forever 5))
  ==
  4

-}




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

data IList
  = INil
  | ICons Int IList
  deriving (Show)

data BList
  = BNil
  | BCons Bool BList
  deriving (Show)

data List a
  = Nil
  | Cons a (List a)
  deriving (Show)

firstList :: List Int
firstList = Cons 1 (Cons 2 (Cons 3 Nil))

secondList :: List Int
secondList = Cons 4 (Cons 5 (Cons 6 Nil))



-- >>> plusPlus firstList secondList

{-
pp (Cons 1 (Cons 2 (Cons 3 Nil))) secondList
==
Cons 1 (pp (Cons 2 (Cons 3 Nil)) secondList)
==
Cons 1 (Cons 2 (pp (Cons 3 Nil)) secondList))
==
Cons 1 (Cons 2 (Cons 3 (pp Nil secondList)))
==
Cons 1 (Cons 2 (Cons 3 ( Cons 4 (Cons 5 (Cons 6 Nil)) )))


-}
-- Cons 1 (Cons 2 (Cons 3 (Cons 4 (Cons 5 (Cons 6 Nil)))))

-- Cons 1 (Cons 2 (Cons 3 (Cons 4 (Cons 5 (Cons 6 Nil)))))

-- plusPlus (Cons 3 Nil) (Cons 4 (Cons 5 (Cons 6 Nil)))
-- == Cons 3 (plusplus Nil (Cons 4 (Cons 5 (Cons 6 Nil)))

plusPlus :: List a -> List a -> List a
plusPlus Nil         ys = ys
plusPlus (Cons x xs) ys = Cons x (plusPlus xs ys)



thing1 :: a -> [a] -> [a]
thing1 = (:)

thing2 :: [a] -> [a] -> [a]
thing2 = (++)


{-

[1,2,3,4]

1 : (2 : (3 : ( 4 : []) ))

data [] a
  = []
  | (:) a [a]

-}

qqqq = (+) 10 20


glalsdasd x y = x : y

data Bizzaro a
  = BizarroNul

{-



data List
  = Nil
  | Cons Int List

data List
  = Nil
  | Cons Bool List

      x.(y + z + a)
-}


qouldItWork = BCons True BNil

listNil :: IList
listNil = INil

-- >>> questionAboutCons list123
-- ICons 3 (ICons 1 (ICons 2 (ICons 3 INil)))


-- ICons 1 (ICons 2 (ICons 3 INil))

questionAboutCons = ICons 3

-- list3  :: IList
list3 = ICons 3 INil
list23 = ICons 2 list3
list123 = ICons 1 (ICons 2 list3)

-- >>> list123
-- ICons 1 (ICons 2 (ICons 3 INil))


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

scopeExample :: Int -> Int
scopeExample ohno =
  (let aa  = ohno
       cc  = bb + 2
       bb = aa + 1
   in
       aa + cc + 100)
  +
   (let aa  = ohno
        bb = aa + 1
        cc  = bb + 2
   in
        aa + cc + 100)

data Tree a
  = Leaf a
  | Node (Tree a) (Tree a)
  deriving (Show)

exTree =
  Node
  (Node
   (Node
     (Leaf 1)
     (Leaf 2))
   (Node
     (Leaf 3)
     (Leaf 4)))
  (Node
    (Leaf 5)
    (Leaf 6))

lstBBB :: List (Int, Int)
lstBBB = Cons (4, 10) (Cons (5, 20) (Cons (6, 30) Nil))

addPairs xs = bob (\(x1, x2) -> x1 + x2) xs


lst456 :: List Int
lst456 = Cons 4 (Cons 5 (Cons 6 Nil))

lst123 :: List Int
lst123 = Cons 1 (Cons 2 (Cons 3 Nil))

lstabc :: List String
lstabc = Cons "c" (Cons "at" (Cons "cat" Nil))


bob op Nil         = Nil
bob op (Cons x xs) = Cons (op x) (bob op xs)


lengths xs = bob length xs
add3 xs    = bob (\x -> x+3) xs

-- lengths :: List String -> List Int
-- lengths Nil = Nil
-- lengths (Cons x xs) = Cons (length x) (lengths xs)

add3 :: List Int -> List Int
add3 Nil         = Nil
add3 (Cons x xs) = Cons (x + 3) (add3 xs)

{-

bob Nil         = Nil
bob (Cons x xs) = Cons (length x) (bob xs)

bob Nil         = Nil
bob (Cons x xs) = Cons (x + 3) (bob xs)


-}


-- >>> length "ca"
-- 2
