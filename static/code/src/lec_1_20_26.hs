{- HLINT ignore "Eta reduce" -}
{- HLINT ignore "Use uncurry" -}
{- HLINT ignore "Use :" -}
{- HLINT ignore "Use id" -}
module Lec_1_20_26  where

{-
import Prelude hiding (map, foldr)

sumTo :: Int -> Int
-- sumTo n = if n <= 0 then 0 else n + sumTo (n-1)
sumTo = go 0
  where
    go acc n = if n <= 0 then acc else go (acc + n) (n - 1)

{-
data TT a = Node [TT a]

-}

data Tree a
  = Leaf a
  | Node (Tree a) (Tree a)
  deriving (Show)

data Tree23 a
  = Leaf23 a
  | NodeTwo (Tree23 a) (Tree23 a)
  | NodeThree (Tree23 a) (Tree23 a) (Tree23 a)

exTree :: Tree Int
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

-- >>> sumTree exTree
-- 21

-- sumTree :: Tree Int -> Int
-- sumTree (Leaf n)   = n
-- sumTree (Node l r) = sumTree l + sumTree r

-- leaves :: Tree a -> [a]
-- leaves (Leaf x)   = [x]
-- leaves (Node l r) = leaves l ++ leaves r

foldTree :: (b -> b -> b) -> ( a -> b) -> Tree a -> b
foldTree op b (Leaf x)   = b x
foldTree op b (Node l r) = op (foldTree op b l) (foldTree op b r)

leaves :: Tree a -> [a]
leaves  = foldTree (++) (\x -> [x])

sumTree :: Tree Int -> Int
sumTree = foldTree (+)  (\x -> x)


{-

bar (Leaf x)   = x
bar (Node l r) = bar l + bar r

bar (Leaf x)   = [x]
bar (Node l r) = bar l ++ bar r

op   is  `+` vs `++`
base is `x` vs `[x]`
-}




exTree' :: Tree String
exTree' =
  Node
  (Node
   (Node
     (Leaf "a")
     (Leaf "to"))
   (Node
     (Leaf "cat")
     (Leaf "leaf")))
  (Node
    (Leaf "trunk")
    (Leaf "branch"))

leafToInt :: Tree String -> Tree Int
leafToInt (Leaf s)   = Leaf (length s)
leafToInt (Node l r) = Node (leafToInt l) (leafToInt r)

mapTree :: (a -> b) -> Tree a -> Tree b
mapTree op (Leaf s)   = Leaf (op s)
mapTree op (Node l r) = Node (mapTree op l) (mapTree op r)

leafToInt' :: Tree String -> Tree Int
leafToInt' = mapTree length





data List a
  = Nil
  | Cons a (List a)

data Stream a
  = Next a (Stream a)


mkStream :: Int -> Stream Int
mkStream n = Next n (mkStream (n+1))

first3 :: Stream a -> (a, a, a)
first3 (Next x1 ( Next x2 (Next x3 _))) = (x1, x2, x3)

-- >>> first3 (mkStream 100)
-- (100,101,102)


{-


data [a]
  = []
  | (:) a [a]

(++)
-}

tuesday :: t
tuesday = wednesday

wednesday :: t
wednesday = tuesday

-- >>> tuesday

{-

(A) editor hangs
(B) editor is fine but if you RUN (i.e. evaluate tuesday or wed THAT hangs)(C)
(C) editor complains that it can't figure out the type of tue/wed

-}




lstBBB :: List (Int, Int)
lstBBB = Cons (4, 10) (Cons (5, 20) (Cons (6, 30) Nil))

addPairs = map adder
  where
    adder (x,y) = x + y

{-
foo = <blah>
-}

lst456 :: List Int
lst456 = Cons 4 (Cons 5 (Cons 6 Nil))

lst123 :: List Int
lst123 = Cons 1 (Cons 2 (Cons 3 Nil))

lstabc :: List String
lstabc = Cons "c" (Cons "at" (Cons "cat" Nil))


map :: (a -> b) -> List a -> List b
map op Nil         = Nil
map op (Cons x xs) = Cons (op x) (map op xs)


lengths xs = map length xs
add3 xs    = map (\x -> x+3) xs

-- lengths :: List String -> List Int
-- lengths Nil         = Nil
-- lengths (Cons x xs) = Cons (length x) (lengths xs)

-- add3 :: List Int -> List Int
-- add3 Nil         = Nil
-- add3 (Cons x xs) = Cons (x + 3) (add3 xs)

{-

bob Nil         = Nil
bob (Cons x xs) = Cons (length x) (bob xs)

bob Nil         = Nil
bob (Cons x xs) = Cons (x + 3) (bob xs)


-}


-- >>> length "ca"
-- 2


-- >>> sumList' [10, 20, 30, 40,50]
-- 150

sumList' :: [Int] -> Int
sumList'    = foldr (+) 0


sumList :: [Int] -> Int
sumList []     = 0
sumList (n:ns) = n + sumList ns


-- sizeOf :: [a] -> Int
-- sizeOf []     = 0
-- sizeOf (x:xs) = 1 + sizeOf xs

sizeOf :: [t] -> Int
sizeOf = foldr (\_ n -> 1 + n) 0

-- >>> sizeOf ["cat", "dog", "horse"]
-- 3

-- >>> concatList' ["cat", "dog", "horse"]
-- "catdoghorse"

concatList' :: [String] -> String
concatList' = foldr (++) ""


concatList :: [String] -> String
concatList []     = ""
concatList (w:ws) = w ++ concatList ws


foldr :: (a -> b -> b) -> b -> [a] -> b
foldr op b []     = b
foldr op b (x:xs) = op x (foldr op b xs)


{-

goo op b (x1 : (x2 : (x3 : (x4 : []))))
==
op x1 (goo op b (x2 : (x3 : (x4 : []))))
==
op x1 (op x2 (goo op b (x3 : (x4 : []))))
==
op x1 (op x2 (op x3 (goo op b (x4 : []))))
==
op x1 (op x2 (op x3 (op x4 (goo op b []))))
==
op x1 (op x2 (op x3 (op x4 (b))))
==
x1 `op` (x2 `op` (x3 `op` (x4 `op` b)))

foldr




goo []     = 0
goo (x:xs) = x + goo xs


goo []     = ""
goo (x:xs) = x ++ goo xs

(a) `+` vs `++`
(b) `0` vs `""`



goo :: (stuff -> BASE -> BASE) -> BASE -> [stuff] -> BASE
goo op b []     = b
goo op b (x:xs) = op x (goo op b xs)





-}

append :: [a] -> [a] -> [a]
append []      ys = ys
append (x: xs) ys = x : append xs ys

-- >>> append' [1,2,3] [4,5,6]
-- [1,2,3,4,5,6]

append' :: [a] -> [a] -> [a]
append' xs ys = foldr (:) ys xs

-}

-- >>> pat 2 3 5
-- 16

pat :: Int -> Int -> Int -> Int
pat x y z = x * (y + z)


ex1 :: Double
ex1 = 1.1 + 2.2

ex2 :: Int
ex2 = pat 2 3 nine

nine :: Int
nine = 4 + 5

-- >>> ex2
-- pat 2 3 nine
-- 2 * (3 + nine)
-- 2 * (3 + (4 + 5))
-- 24



boo :: Bool
boo = True



ex6 :: Int
ex6 = 4 + 5

ex7 :: Double
ex7 = 4.0 * 5.0

quiz :: Int
quiz = if 5 > 4 then ex6 else ex7 -- HEREHEREHERE

{-
x = cond ? this : that

quiz :: ???

(A) INT
(B) BOOL
(C) ERROR
(D) DOUBLE
(E) write-in

-}
