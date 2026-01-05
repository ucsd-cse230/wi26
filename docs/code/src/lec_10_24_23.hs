{-# LANGUAGE InstanceSigs #-}
module Lec_10_24_23 where

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
  = Def v
  | Bind k v (Table k v)


menu0 :: Table String Int
menu0 = Bind "burrito" 10 (Bind "taco" 5 (Bind "salsa" 0 (Def 1000000)))

menu1 :: Table Jhala Int
menu1 = Bind Burrito 10 (Bind Taco 5 (Bind Salsa 0 (Def 1000000)))


get :: Eq k => Table k v -> k -> v
get (Bind key value rest) k = if key == k then value else get rest k
get (Def value )          _ = value
