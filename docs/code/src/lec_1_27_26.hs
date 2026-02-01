{- HLINT ignore "Eta reduce" -}
{- HLINT ignore "Use uncurry" -}
{- HLINT ignore "Use :" -}
{- HLINT ignore "Use id" -}
{-# LANGUAGE InstanceSigs #-}
{-# LANGUAGE DeriveFunctor #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE UndecidableInstances #-}
{- HLINT ignore "Avoid lambda" -}
{- HLINT ignore "Use map" -}

module Lec_1_27_26  where

-- import Prelude hiding ((+))

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

  {-# MINIMAL (===) | (=!=) #-}

data Bab = A | B
-- stack overflow

-- >>> A === A


instance JSEq Bab where
  (===) A A = True
  (===) B B = True
  (===) _ _ = False


-- >>> listA =!= listA

-- >>> :i Eq
-- type Eq :: * -> Constraint
-- class Eq a where
--   (==) :: a -> a -> Bool
--   (/=) :: a -> a -> Bool
--   {-# MINIMAL (==) | (/=) #-}
--   	-- Defined in ‘GHC.Classes’



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


-- inc :: Int -> Int
-- inc n = n + 1

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

instance Num [a] where
  (+) xs ys = xs ++ ys

-- >>> [1,2,3] + [4,5,6]
-- [1,2,3,4,5,6]

-- Ambiguous occurrence `+'.
-- It could refer to
--    either `Prelude.+',
--           imported from `Prelude' at /Users/rjhala/teaching/230-wi26/static/code/src/lec_1_27_26.hs:9:8-18
--           (and originally defined in `GHC.Internal.Num'),
--        or `Lec_1_27_26.+',
--           defined at /Users/rjhala/teaching/230-wi26/static/code/src/lec_1_27_26.hs:208:1.

-- (+) :: [a] -> [a] -> [a]
-- (+) xs ys = xs ++ ys

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


----------

mapList :: (a -> b) -> [a] -> [b]
mapList _ []     = []
mapList f (x:xs) = f x : mapList f xs

data Tree a
  = Node (Tree a) (Tree a)
  | Leaf a
  deriving (Functor, Show)

-- >>> :i map

-- >>> fmap (\n -> n + 67) tree0
-- Node (Leaf 77) (Node (Leaf 87) (Leaf 97))

tree0 :: Tree Int
tree0 = Node (Leaf 10) (Node (Leaf 20) (Leaf 30))

class Mappable t where
   gmap :: (a -> b) -> t a -> t b

-- >>> :i Functor
-- class Functor f where
--   fmap :: (a -> b) -> f a -> f b


instance Mappable Tree where
  gmap f (Leaf x)   = Leaf (f x)
  gmap f (Node l r) = Node (gmap f l) (gmap f r)

instance Mappable [] where
  gmap f []   = []
  gmap f (x:xs) = f x : gmap f xs

-- >>> gmap show        tree0
-- >>> gmap (\n -> n*n) tree0
-- >>> gmap show        list0
-- >>> gmap (\n -> n*n) list0
-- Node (Leaf "10") (Node (Leaf "20") (Leaf "30"))
-- Node (Leaf 100) (Node (Leaf 400) (Leaf 900))
-- ["10","20","30","40","50"]
-- [100,400,900,1600,2500]

{-


mapList :: (a -> b) -> List a -> List b

mapTree :: (a -> b) -> Tree a -> Tree b

class Show t where
  show :: t -> String

showInt    :: Int -> String
showBool   :: Bool -> String
showString :: String -> String

-}

list0 :: [Integer]
list0 = [10, 20, 30, 40, 50]




-- Node (Leaf "10") (Node (Leaf "20") (Leaf "30"))
-- Node (Leaf 100) (Node (Leaf 400) (Leaf 900))

-- Node (Leaf "10") (Node (Leaf "20") (Leaf "30"))


-----

-- >>> (Add (Num 5) (Num 19))

expr0 :: Expr
expr0 = Bin Mul
          (Bin Add (Num 2) (Num 3))
          (Bin Div (Bin Sub (Num 5) (Num 4)) (Num 7))

expr1 :: Expr
expr1 = Bin Mul
          (Bin Add (Num 2) (Num 3))
          (Bin Div (Bin Add (Num 5) (Num 4))
                   (Bin Sub (Num 3) (Bin Add (Num 1) (Num 2))))


data Op
  = Add | Sub | Mul | Div
  deriving (Show)

data Expr
  = Num Int
  | Bin Op Expr Expr
  deriving (Show)

-- >>> eval expr1
-- divide by zero

-- >>> evalR expr1
-- Err "Uff, div by zero!"

res0 :: [Result Int]
res0 = [Ok 78, Err "aaarthgh", Err "dbz", Ok 9]

data Result a = Ok a | Err String
  deriving (Show)

eval :: Expr -> Int
eval (Num n)     = n
eval (Bin o e1 e2) = evalOp o (eval e1) (eval e2)

evalOp :: Op -> Int -> Int -> Int
evalOp Add n1 n2 = n1 +     n2
evalOp Sub n1 n2 = n1 -     n2
evalOp Mul n1 n2 = n1 *     n2
evalOp Div n1 n2 = n1 `div` n2


evalOpR :: Op -> Int -> Int -> Result Int
evalOpR Add n1 n2 = Ok (n1 +     n2)
evalOpR Sub n1 n2 = Ok (n1 -     n2)
evalOpR Mul n1 n2 = Ok (n1 *     n2)
evalOpR Div _  0  = Err "Uff, div by zero!"
evalOpR Div n1 n2 = Ok (n1 `div` n2)

-- >>> evalR expr1
-- Err "Uff, div by zero!"

evalR :: Expr -> Result Int
evalR (Num n)       = Ok n
evalR (Bin o e1 e2) = do
  n1 <- evalR e1
  n2 <- evalR e2
  evalOpR o n1 n2


instance Functor Result where

instance Applicative Result where
instance Monad Result where
  (>>=) = funkyOp

-- >>> :i Monad
-- class Applicative m => Monad m where
--   (>>=) :: m a -> (a -> m b) -> m b
--   return :: a -> m a

  -- funkyOp (evalR e1) (\n1 ->
  --   funkyOp (evalR e2) (\n2 ->
  --     evalOpR o n1 n2
  --   )
  -- )

-- combine :: Recipe t -> (t -> Recipe a) -> Recipe a
funkyOp :: Result t -> (t -> Result a) -> Result a
funkyOp r doStuff = case r of
  Err msg -> Err msg
  Ok n -> doStuff n



-- evalR (Add e1 e2) = case evalR e1 of
--                       Err msg -> Err msg
--                       Ok n1   -> case evalR e2 of
--                                    Err msg -> Err msg
--                                    Ok n2   -> Ok (n1 + n2)
-- evalR (Sub e1 e2) = case evalR e1 of
--                       Err msg -> Err msg
--                       Ok n1   -> case evalR e2 of
--                                    Err msg -> Err msg
--                                    Ok n2   -> Ok (n1 - n2)

-- evalR (Mul e1 e2) = case evalR e1 of
--                       Err msg -> Err msg
--                       Ok n1   -> case evalR e2 of
--                                    Err msg -> Err msg
--                                    Ok n2   -> Ok (n1 * n2)
-- evalR (Div e1 e2) = case evalR e1 of
--                       Err msg -> Err msg
--                       Ok n1   -> case evalR e2 of
--                                    Err msg -> Err msg
--                                    Ok 0    -> Err ("oh no DBZ because of:" ++ show e2)
--                                    Ok n2   -> Ok (n1 `div` n2)
