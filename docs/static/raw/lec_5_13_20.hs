{-# LANGUAGE DeriveFunctor #-}

module Lec_5_13_20 where

-- import Prelude hiding (Monad)

data Expr
  = Number Int            -- ^ 0,1,2,3,4
  | Plus   Expr Expr      -- ^ e1 + e2
  | Minus  Expr Expr      -- ^ e1 - e2
  | Mult   Expr Expr      -- ^ e1 * e2
  | Div    Expr Expr      -- ^ e1 / e2
  deriving (Show)

-------------------------------------------------------------------------------
e1 = Plus  (Number 2) (Number 3)    -- 2 + 3
e2 = Minus (Number 10) (Number 4)   -- 10 - 4
e3 = Mult e1 e2                     -- (2 + 3) * (10 - 4)
e4 = Div  e3 (Number 3)             -- ((2 + 3) * (10 - 4)) / 3
-------------------------------------------------------------------------------

eval :: Expr -> Int
eval (Number x)    = x
eval (Plus e1 e2)  = eval e1   +   eval e2
eval (Minus e1 e2) = eval e1   -   eval e2
eval (Mult e1 e2)  = eval e1   *   eval e2
eval (Div e1 e2)   = eval e1 `div` eval e2

-------------------------------------------------------------------------------
exQuiz :: Expr
exQuiz = (Div (Number 60) (Minus (Number 5) (Number 5)))
-------------------------------------------------------------------------------

-- >>> eval exQuiz
-- *** Exception: divide by zero
--


-------------------------------------------------------------------------------
{- 
data Maybe a 
  = Just a 
  | Nothing
-}


data Result a
  = Ok a
  | Error String
  deriving (Eq, Show, Functor)

-------------------------------------------------------------------------------

{- 
class Monad m where
  (>>=)  :: m a -> (a -> m b) -> m b
  return :: a -> m a 

foo1 >>= \x1  -> 
  foo2 >>= \x2 -> 
    foo3 >>= \x3 -> 
      bar

do x1 <- foo1
   x2 <- foo2
   x3 <- foo3
   bar 
-}

instance Monad Result where
-- (>>=) :: Result a -> (a -> Result b) -> Result b
  Error s  >>= _      = Error s
  (Ok v)  >>= process = process v

-- return :: a -> Result a
  return v = Ok v

evalR :: Expr -> Result Int
evalR (Number n)    = return n
evalR (Plus e1 e2)  = do v1 <- evalR e1
                         v2 <- evalR e2
                         return (v1 + v2)
evalR (Minus e1 e2) = do v1 <- evalR e1
                         v2 <- evalR e2
                         return (v1 - v2)
evalR (Mult e1 e2)  = do v1 <- evalR e1
                         v2 <- evalR e2
                         return (v1 * v2)
evalR (Div e1 e2)  = do v1 <- evalR e1
                        v2 <- evalR e2
                        if v2 == 0
                          then Error ("yikes dbz:" ++ show e2)
                          else return (v1 `div` v2)


-- >>> evalR exQuiz
-- Error "yikes dbz:Minus (Number 5) (Number 5)"
--

































instance Applicative Result where
  pure  = undefined
  (<*>) = undefined