{- HLINT ignore "Eta reduce" -}
{- HLINT ignore "Use uncurry" -}
{- HLINT ignore "Use :" -}
{- HLINT ignore "Use id" -}
{-# LANGUAGE InstanceSigs #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE UndecidableInstances #-}

module Lec_1_27_26  where

-- >>> :t (+)
-- (+) :: Num a => a -> a -> a

-- >>> myAdder True False
-- No instance for `Num Bool' arising from a use of `myAdder'
-- In the expression: myAdder True False
-- In an equation for `it_aApO': it_aApO = myAdder True False

-- No instance for `Num Char' arising from a use of `myAdder'
-- In the expression: myAdder 'a' 'b'
-- In an equation for `it_aA4y': it_aA4y = myAdder 'a' 'b'

-- >>> :k Num
-- Num :: * -> Constraint

-- >>> :i Eq
-- type Eq :: * -> Constraint
-- class Eq a where
--   (==) :: a -> a -> Bool
--   (/=) :: a -> a -> Bool
--   {-# MINIMAL (==) | (/=) #-}
--   	-- Defined in ‘GHC.Classes’
-- instance Eq Integer -- Defined in ‘GHC.Num.Integer’
-- instance Eq Bool -- Defined in ‘GHC.Classes’
-- instance Eq Char -- Defined in ‘GHC.Classes’
-- instance Eq Double -- Defined in ‘GHC.Classes’
-- instance Eq Float -- Defined in ‘GHC.Classes’


-- >>> listA == listB
-- False

llistA :: List (List Int)
llistA = Cons listA Nil

llistB :: List (List Int)
llistB = Cons listB Nil

-- >>> :i Show
-- type Show :: * -> Constraint
-- class Show a where
--   showsPrec :: Int -> a -> ShowS
--   show :: a -> String
--   showList :: [a] -> ShowS
--   {-# MINIMAL showsPrec | show #-}





listA :: List Int
listA = Cons 1 (Cons 2 Nil)

listB :: List Int
listB = Cons 1 (Cons 3 Nil)

-- >>> :i Ord
-- type Ord :: * -> Constraint
-- class Eq a => Ord a where
--   compare :: a -> a -> Ordering
--   (<) :: a -> a -> Bool
--   (<=) :: a -> a -> Bool
--   (>) :: a -> a -> Bool
--   (>=) :: a -> a -> Bool
--   max :: a -> a -> a
--   min :: a -> a -> a
--   {-# MINIMAL compare | (<=) #-}
--   	-- Defined in ‘GHC.Classes’
-- >>> llistB
-- Cons (Cons 1 (Cons 3 Nil)) Nil

class JSEq a where
  (===) :: a -> a -> Bool
  (===) x y = not (x =!= y)

  (=!=) :: a -> a -> Bool
  (=!=) x y = not (x === y)

data Bab = A | B

instance JSEq Bab where
  (===) A A = True
  (===) B B = True
  (===) _ _ = False


-- >>> listA =!= listA
-- False


-- >>> listA
-- Cons 1 (Cons 2 Nil)

data List a = Nil | Cons a (List a)
  deriving (Show)

-- listEq<A implements Eq>
listEq :: (Eq a, Show a) => List a -> List a -> Bool
listEq Nil         Nil         = True
listEq (Cons x xs) (Cons y ys) = x == y && listEq xs ys
listEq _           _           = False

-- instance Eq a => JSEq a where
--   (===) = (==)

-- instance (JSEq a) => JSEq (List a) where
--   (===) = listEq

-- instance Eq a => Eq (List a) where
--   (==) :: List a -> List a -> Bool
--   (==) = listEq

-- instance Show a => Show (List a) where
--   show :: List a -> String
--   show Nil         = "Nil"
--   show (Cons x xs) = "(Cons " ++ show x ++ " " ++ show xs ++ ")"

-- >>> llistA
-- (Cons (Cons 1 (Cons 2 Nil)) Nil)


myAdder :: Num a => a -> a -> a
myAdder x y = undefined

-- >>> :info Num
-- type Num :: * -> Constraint
-- class Num a where
--   (+) :: a -> a -> a
--   (-) :: a -> a -> a
--   (*) :: a -> a -> a
--   negate :: a -> a
--   abs :: a -> a
--   signum :: a -> a
--   fromInteger :: Integer -> a
--   {-# MINIMAL (+), (*), abs, signum, fromInteger, (negate | (-)) #-}
--   	-- Defined in ‘GHC.Internal.Num’
-- instance Num Double -- Defined in ‘GHC.Internal.Float’
-- instance Num Float -- Defined in ‘GHC.Internal.Float’
-- instance Num Int -- Defined in ‘GHC.Internal.Num’
-- instance Num Integer -- Defined in ‘GHC.Internal.Num’
-- instance Num Word -- Defined in ‘GHC.Internal.Num’

-- >>> 2 + 3
-- 5

-- >>> 3.4 + 5.6
-- 9.0

-- >>> 3.4 < 5.6
-- True

-- >>> "cat" < "dog"
-- True


inc :: Int -> Int
inc n = n + 1

blah = do
  str <- getLine
  putStrLn  ("hello" ++ str)

data Table k v = MkTable { def :: v, bindings :: [(k, v)] }
  deriving (Show)

table0 :: Table String Double
table0 = MkTable { def = 6.5, bindings = [
  ("cortado", 5.25),
  ("espresso", 4.50),
  ("matcha", 6.75)
  ] }

-- >>> get "affagato" table0
-- 6.5
-- >>> get "espresso" table0
-- 4.5

get :: (Ord k) => k -> Table k v -> v
get key (MkTable d binds) = loop binds
  where
    loop ((k,v):rest)
      | key == k  = v
      | key <  k  = d
      | otherwise = loop rest
    loop []       = d

set :: (Ord k) => k -> v -> Table k v -> Table k v
set key value (MkTable d bs) = MkTable d (loop bs)
  where
    loop []           = [(key, value)]
    loop ((k,v):rest)
      | key < k       = (key, value):(k,v):rest
      | key == k      = (key, value):rest
      | otherwise     = (k, v) : loop rest


-- >>> get "latte" (set "latte" 10.0 table0)
-- 10.0

-- >>> get "espresso" (set "latte" 10.0 table0)
-- 4.5
keys :: Table k v -> [k]
keys t = map fst (bindings t)
