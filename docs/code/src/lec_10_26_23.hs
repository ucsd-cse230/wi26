{-# LANGUAGE InstanceSigs #-}
{-# LANGUAGE TypeSynonymInstances #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE UndecidableInstances #-}
module Lec_10_26_23 where

import Prelude hiding (showList)

-- >>> 1 + 2
-- 3

inc :: Int -> Int
inc x = x + 1


-- >>> plus True False
-- No instance for (Num Bool) arising from a use of `plus'
-- In the expression: plus True False
-- In an equation for `it_aKhA': it_aKhA = plus True False

plus :: Num a => a -> a -> a
plus x y = x + y

eq :: Eq a => a -> a -> Bool
eq x y = x == y

lt :: Ord a => a -> a -> Bool
lt x y = x < y

-- >>> show [1,2,3]
-- "[1,2,3]"

-- >>> Taco < Burrito
-- True

-- >>> Taco
-- <Taco>

data Filling = Rice | Beans deriving (Eq, Ord)

data Jhala = Taco | Burrito  | Salsa deriving (Eq, Ord )

-- jInt :: Jhala -> Int
-- jInt Taco    = 0
-- jInt Burrito = 1
-- jInt Salsa   = 2

-- instance Show Jhala where
--     show Taco = "<Taco>"
--     show Burrito = "<Burrito>"
--     show Salsa = "<Salsa>"

-- instance Eq Jhala where
--   (==) :: Jhala -> Jhala -> Bool
--   (==) x y = jInt x == jInt y

-- instance Ord Jhala where
--     compare x y = compare (jInt x) (jInt y)

-- >>> get menu0 "taco"
-- 5

-- >>> get menu1 Salsa
-- 0

data Table k v
  = Emp
  | Bind k v (Table k v)
  deriving (Show)

instance Mappable (Table k) where
  gmap _ Emp = Emp
  gmap f (Bind k v rest) = Bind k (f v) (gmap f rest)

menu0 :: Table String Int
menu0 = Bind "burrito" 10 (Bind "salsa" 0 (Bind "taco" 5 Emp))

menu1 :: Table Jhala Int
menu1 = Bind Burrito 10 (Bind Taco 5 (Bind Salsa 0 Emp))

-- >>> getU menu0 "churro"
-- Fail

data Option v   = Some v          | None
data Maybe v    = Just v          | Nothing
data Nullable v = Value v         | Null deriving (Show)
data List v     = Cons v (List v) | Empty

-- >>> waiter menu0 "taco"
-- "the price is $5"

-- >>> read "67.45" :: Float
-- 67.45

waiter :: Table String Int -> String -> String
waiter menu item = case getU menu item of
                      Null -> "sorry, we do not sell " ++ item
                      Value n -> "the price is $" ++ show n

getU :: Ord k => Table k v -> k -> Nullable v
getU (Bind key value rest) k
  | k == key      = Value value
  | k <  key      = Null
  | otherwise     = getU rest k
getU Emp   _      = Null

get :: Eq k => Table k v -> k -> v
get (Bind key value rest) k
  | key == k      = value
  | otherwise     = get rest k
get Emp   _       = undefined -- spl value or exception

getWithDefault :: Eq k => v -> Table k v -> k -> v
getWithDefault def (Bind key value rest) k
  | key == k              = value
  | otherwise             = getWithDefault def rest k
getWithDefault def Emp  _ = def -- spl value or exception




data Blah = Aaa | Baa | Haa

foo :: Blah -> Int
foo Aaa = 0
foo Baa = 1
foo Haa = 2


data JVal
  = JNum  Double
  | JBool Bool
  | JStr  String
  | JArr  [JVal]
  | JObj  [ (String, JVal) ]
  deriving (Show)

class ToJVal a where
  jval :: a -> JVal

instance ToJVal Integer where
 jval i = JNum (fromIntegral i)

instance ToJVal Int where
 jval i = JNum (fromIntegral i)


instance ToJVal Double where
  jval d = JNum d

data MyString = S String

instance ToJVal MyString where
  jval (S s) = JStr s

instance ToJVal a => ToJVal [a] where
  jval xs = JArr (map jval xs)

instance (ToJVal a, ToJVal b) => ToJVal (a, b) where
--  jval (x, y) = JArr [ jval x, jval y]
  jval (x, y) = JObj [ ("0", jval x), ("1", jval y)]

-- >>> jval (S "one", (2, (S "three", (S "four", menu0))))
-- JObj [("0",JStr "one"),("1",JObj [("0",JNum 2.0),("1",JObj [("0",JStr "three"),("1",JObj [("0",JStr "four"),("1",JObj [("burrito",JNum 10.0),("salsa",JNum 0.0),("taco",JNum 5.0)])])])])]


instance ToJVal a => ToJVal (Table String a) where
  jval t = JObj [ (k, jval v) | (k, v) <- kvs ]
             -- JObj (map (\(k, v) -> (k, intJVal v)) kvs)
    where
      kvs = keyVals t

-- >>> jval [[1,2,3], [4,5,6]]
-- JArr [JArr [JNum 1.0,JNum 2.0,JNum 3.0],JArr [JNum 4.0,JNum 5.0,JNum 6.0]]





keyVals :: Table k v -> [(k, v)]
keyVals (Bind k v rest) = (k, v) : keyVals rest
keyVals Emp             = []

showw :: (Mappable c) => c Int -> c String
showw = gmap show

sq :: (Mappable c) => c Int -> c Int
sq = gmap (\x -> x * x)

-- >>> sq [1,2,3,4,5]
-- [1,4,9,16,25]

-- >>> sq (Node 30 (Node 1 Leaf Leaf) (Node 2 Leaf Leaf))
-- Node 900 (Node 1 Leaf Leaf) (Node 4 Leaf Leaf)

-- >>> sq menu0

-- Bind "burrito" 100 (Bind "salsa" 0 (Bind "taco" 25 Emp))
data Tree a
  = Leaf
  | Node a (Tree a) (Tree a)
  deriving (Show)

showTree :: Tree Int -> Tree String
showTree = mapTree show
-- showTree Leaf         = Leaf
-- showTree (Node v l r) = Node (show v) (showTree l) (showTree r)

sqTree :: Tree Int -> Tree Int
sqTree = mapTree (\x -> x * x)
-- sqTree Leaf         = Leaf
-- sqTree (Node v l r) = Node (v * v) (sqTree l) (sqTree r)

mapTree :: (t -> a) -> Tree t -> Tree a
mapTree _ Leaf         = Leaf
mapTree f (Node v l r) = Node (f v) (mapTree f l) (mapTree f r)

type MyList a = [a]

-- mapList :: (t -> a) -> MyList t -> MyList a
-- mapTree :: (t -> a) -> Tree t -> Tree a

class Mappable c where
  gmap :: (a -> b) -> c a -> c b

-- >>> :kind Table
-- Table :: * -> * -> *

instance Mappable [] where
  gmap _ [] = []
  gmap f (x:xs) = f x : gmap f xs

-- Functor

instance Mappable Tree where
  gmap _ Leaf         = Leaf
  gmap f (Node v l r) = Node (f v) (gmap f l) (gmap f r)
