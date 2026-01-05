{-# LANGUAGE FlexibleInstances #-}

module Lec_11_12_20 where

-- import Prelude hiding (return, (>>=))

inc :: Int -> Int 
inc x = x + 1

data Expr
  = Number Int            -- ^ 0,1,2,3,4
  | Plus   Expr Expr      -- ^ e1 + e2
  | Minus  Expr Expr      -- ^ e1 - e2
  | Mult   Expr Expr      -- ^ e1 * e2
  | Div    Expr Expr      -- ^ e1 / e2
  deriving (Show)

-- eval :: Expr -> Int
-- eval (Number v)    = v
-- eval (Plus e1 e2)  = eval e1 + eval e2
-- eval (Minus e1 e2) = eval e1 - eval e2
-- eval (Mult e1 e2)  = eval e1 * eval e2
-- eval (Div e1 e2)   = eval e1 `div` eval e2

data Result v 
  = Ok v                -- ^ v is a valid "result"
  | Error String        -- ^ oops an error occurred with message String
  deriving (Eq, Show) 

safeEval :: Expr -> Result Int
safeEval (Number n)    = Ok n
safeEval (Plus  e1 e2) = do { v1 <- safeEval e1;
                              v2 <- safeEval e2;
                              return (v1 + v2)
                            }
safeEval (Minus e1 e2) = do { v1 <- safeEval e1;
                              v2 <- safeEval e2;
                              return (v1 - v2)
                            }
safeEval (Mult e1 e2) = do { v1 <- safeEval e1;
                             v2 <- safeEval e2;
                             return (v1 * v2)
                           } 
safeEval (Div e1 e2)   = do { v1 <- safeEval e1; v2 <- safeEval e2; 
                              if v2 == 0 
                                then (Error ("Oops dbz in: " ++ show e2))
                                else (Ok (v1 `div` v2))
                            }  

foo :: Monad m => m a -> m b -> m (a, b)
foo m1 m2 = m1 >>= (\x1 -> 
            m2 >>= (\x2 -> 
            return (x1, x2)
            )) 

{- 

  (+) :: Int -> Int -> Int
  (+) :: Double -> Double -> Double 


-}


-- >>> foo getLine getLine  


-- >>> foo [10,20,30] [1000, 2000, 3000]
-- [(10,1000),(10,2000),(10,3000),(20,1000),(20,2000),(20,3000),(30,1000),(30,2000),(30,3000)]

{- 

instance Monad IO where
  return :: a -> IO a
  return v = "creates a recipe that does nothing but produce value v"

  (>>=) :: IO a -> (a -> IO b) -> IO b
  r1 >>= r2 = "new recipe that RUNS r1, gets its value v1, then runs recipe (r2 v1)"
-}

instance Monad Result where
  return v = Ok v

  -- (>>=) :: Result a -> (a -> Result b) -> Result b
  e >>= doStuff = case e of
                    Error msg -> Error msg
                    Ok v      -> doStuff v

instance Applicative Result where
instance Functor Result where
{- 
class Monad m where
    (>>=)  :: m a -> (a -> m b) -> m b
    return :: a -> m a
-}








-- >>> safeEval (Div (Number 50) (Number 0))
-- Error "Oops dbz in: Number 0"

-- >>> safeEval (Div (Number 60) (Minus (Number 5) (Number 5)))
-- Error "Oops dbz in: Minus (Number 5) (Number 5)"

-- A. Ok 0
-- B. Ok NaN
-- C. Error ...
-- D. runtime exception








-- >>> safeEval e0 
-- Ok 10

-- >>> safeEval e1 
-- Ok 26

-- >>> safeEval e2
-- Ok 36

-- >>> eval e3
-- 360

-- >>> eval e4
-- 36

e0 = Number 10

e1 = Number 26

-- 36 

e2 = Plus e0 e1

-- >>> eval e3
-- 260 

e3 = Mult e0 e2

e4 = Div e3 e0







data Tree a = Leaf | Node a (Tree a) (Tree a) deriving (Show)

instance Num (Tree Int) where
    t1 + t2 = plusTree t1 t2

plusTree :: Tree Int -> Tree Int -> Tree Int
plusTree = undefined 