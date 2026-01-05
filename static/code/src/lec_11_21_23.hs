{-# LANGUAGE InstanceSigs #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE UndecidableInstances #-}
{-# OPTIONS_GHC -Wno-unrecognised-pragmas #-}
{-# HLINT ignore "Use camelCase" #-}
{-# HLINT ignore "Replace case with maybe" #-}
{-# HLINT ignore "Use list comprehension" #-}
{-# HLINT ignore "Use newtype instead of data" #-}
{-# HLINT ignore "Use foldr" #-}
{-# OPTIONS_GHC -Wno-noncanonical-monad-instances #-}
{-# HLINT ignore "Use tuple-section" #-}
{-# HLINT ignore "Redundant return" #-}
{-# HLINT ignore "Use const" #-}
{-# HLINT ignore "Eta reduce" #-}
{-# HLINT ignore "Use lambda-case" #-}
{-# HLINT ignore "Avoid lambda" #-}
{-# HLINT ignore "Use <$>" #-}

module Lec_11_21_23 where

import Prelude hiding (sum, getLine)
import Test.QuickCheck
-- import Lec_10_17_23 (CircleT(xLoc))
import qualified Data.Set as S
import qualified Data.Map as M

default (Int, Float)

-- 03-transformers

-- >>> quickCheck prop_revapp
prop_revapp :: [Int] -> [Int] -> Bool
prop_revapp xs ys =
    reverse (xs ++ ys) == reverse ys ++ reverse xs
-- [x1,x2,x3, y1,y2,y3]

quickCheckN :: Testable prop => Int -> prop -> IO ()
quickCheckN n = quickCheckWith (stdArgs {maxSuccess = n})

-- >>> qs [3,1,2,7,4]
-- getLinkDeps: Home module not loaded Lec_10_17_23 cse230-code-0.1.0.0-inplace

quick_sort :: Ord a => [a] -> [a]
quick_sort [] = []
quick_sort (x:xs) = quick_sort ls ++ [x] ++ quick_sort rs
  where
    ls = [y | y <- xs, y < x]
    rs = [y | y <- xs, x < y]


insert_sort :: Ord a => [a] -> [a]
insert_sort []     = []
insert_sort (x:xs) = insert x (insert_sort xs)

insert :: Ord a => a -> [a] -> [a]
insert x []     = [x]
insert x (y:ys)
  | x <= y      = x : y : ys
  | otherwise   = y : insert x ys

-- prop_insert_is_sorted :: Ord a => a -> [a] -> Bool
prop_insert_is_sorted :: Int -> [Int] -> Bool
prop_insert_is_sorted x ys = is_sorted (insert x (quick_sort ys))



-- >>> isSorted [1,2,3]

is_sorted :: (Ord a) => [a] -> Bool
is_sorted (x1:x2:xs) = x1 <= x2 && is_sorted (x2:xs)
is_sorted _          = True

-- 1. CHANGE the code of quick_sort so that it does not remove duplicates!
-- 2. CHANGE property to "remove duplicates" from output of insert_sort
-- 3. CHANGE property to "check that xs has distinct elements"

prop_qs_eq_isort :: [Int] -> Bool
prop_qs_eq_isort xs = {- not (is_distinct xs) || -}  quick_sort xs == insert_sort xs

prop_qs_eq_isort' :: [Int] -> Property
prop_qs_eq_isort' xs = is_distinct xs ==> quick_sort xs == insert_sort xs

-- if A then B              A => B       "means the same"    (!A) || B

data Silly = MkSilly Int deriving (Eq, Ord, Show)

instance Arbitrary Silly where
    arbitrary :: Gen Silly
    arbitrary = do
        i <- arbitrary
        return (MkSilly i)

prop_qsort_is_sorted :: [Silly] -> Bool
prop_qsort_is_sorted xs = is_sorted (quick_sort xs)





is_distinct :: (Ord a) => [a] -> Bool
is_distinct zs = go S.empty zs
  where
    go _       []       = True
    go seen (x:xs)
      | S.member x seen = False
      | otherwise       = go (S.insert x seen) xs


prop_qs_is_distinct :: [Int] -> Bool
prop_qs_is_distinct xs = is_distinct (quick_sort xs)

prop_isort_is_sorted :: [Int] -> Bool
prop_isort_is_sorted xs = is_sorted (insert_sort xs)


---  [x1,x2,x3,x4]


prop_qs_num_elems :: [Int] -> Bool
prop_qs_num_elems xs = length xs == length (quick_sort xs)




zero_to_ten :: Gen Int
zero_to_ten = choose (0, 10)

-- instance Monad Gen where
--   ...

genCombine :: Gen a -> Gen b -> Gen (a, b)
genCombine gA gB = do
    a <- gA
    b <- gB
    return (a, b)

elems :: [a] -> Gen a
elems xs = do
    i <- choose (0, length xs - 1)
    return (xs !! i)

-- [x0,x1,x2,x3,x4,x5,x6,x7]

-- sample' (elems ["cat", "dog", "mouse"])


oneOf :: [Gen a] -> Gen a
oneOf gs = do
    -- choose one of g1...gn
    g <- elems gs

    -- sample from g
    x <- g
    return x


mostlyCats :: Gen String
mostlyCats = frequency [(2, return "cat"), (1, return "dog")]


randomThings :: (Arbitrary a) => IO [a]
randomThings = sample' arbitrary



--    randomly selects one of g0,…gn
--     randomly generates a value from the chosen generator



data Variable = V String
  deriving (Eq, Ord, Show)

data Value = IntVal Int | BoolVal Bool
  deriving (Eq, Ord, Show)

data Expression = Var   Variable | Val   Value
                | Plus  Expression Expression
                | Minus Expression Expression
  deriving (Eq, Ord, Show)

data Statement
  = Assign   Variable   Expression
  | If       Expression Statement  Statement
  | While    Expression Statement
  | Sequence Statement  Statement
  | Skip
  deriving (Eq, Ord, Show)

instance Arbitrary Variable where
  arbitrary = do
    x <- elements ['A'..'Z']
    return (V [x])

instance Arbitrary Value where
  arbitrary = oneOf [ do {n <- arbitrary; return (IntVal n) }
                    , do {b <- arbitrary; return (BoolVal b)}
                    ]

instance Arbitrary Expression where
  arbitrary = expr

expr, binE, baseE :: Gen Expression
expr     = oneof [baseE, binE]

binE  = do { o  <- elements [Plus, Minus];
             e1 <- expr;
             e2 <- expr;
             return (o e1 e2) }

baseE = oneOf [ do {x <- arbitrary; return (Var x) }
              , do {v <- arbitrary; return (Val v)} ]


type WState = M.Map Variable Value