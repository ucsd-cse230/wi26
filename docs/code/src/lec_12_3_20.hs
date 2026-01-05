{-# LANGUAGE DeriveFunctor #-}
{-# LANGUAGE FlexibleInstances #-}

module Lec_12_3_20 where

import Prelude hiding (Either (..))
import qualified Data.Map as M
import Control.Monad.State

data Expr
  = Number Int            -- ^ 0,1,2,3,4
  | Plus   Expr Expr      -- ^ e1 + e2
  | Div    Expr Expr      -- ^ e1 / e2
  | Def    Expr Int       -- ^ Def e n returns the result of e if defined else `n`
  deriving (Show)


-- data Result   a = Err String | Ok    a deriving (Show)
data Either e a = Left e     | Right a deriving (Show) 

type Result a = Either String a 
-- instance Monad Result where
--   return x      = Ok x
--   (Ok v)  >>= f = f v
--   (Err s) >>= _ = Err s

instance Monad (Either e) where
  return x        = Right x
  (Right v) >>= f = f v
  (Left s)  >>= _ = Left s


---eval :: Expr -> Either Expr Int 
eval (Number n)    = 
  return n
eval (Plus  e1 e2) = do 
  n1 <- eval e1
  n2 <- eval e2
  count "Add"
  return (n1 + n2)
eval (Div   e1 e2) = do 
  n1 <- eval e1 
  n2 <- eval e2 
  count "Div"
  if n2 /= 0 
    then return (n1 `div` n2) 
    else throwError e2
-- eval (Def e n) =
--   tryCatch (eval e) (\_ -> return n) 
  -- tryCatchDefault (eval e) n



tryCatchDefault :: Either e a -> a -> Either e a
tryCatchDefault (Left _)    def = Right def
tryCatchDefault (Right val) _   = Right val



eCrash = (Div (Number 10) (Plus (Number 5) (Number (-5))))

-- >>> eval (Def eCrash 99)
-- Right 99 

throwError :: e -> Either e a
throwError err = Left err

-- catchError :: m a ->     (e -> m a)        -> m a
catchError :: Either e a -> (e -> Either e a) -> Either e a
catchError expr handler = case expr of
  Right v  -> Right v
  Left exn -> handler exn





















instance Applicative (Either e) where 
instance Functor (Either e) where 

-- instance Applicative Result where 
-- instance Functor Result where 

-- Profile a = (Int -> (a, Int)

type Profile a = State Counter a

-- data Counter = Counter { numAdd :: Int, numDiv :: Int } deriving (Show)
type Counter = M.Map String Int


evalP :: Expr -> Profile Int 
evalP (Number n)    = 
  return n
evalP (Plus  e1 e2) = do 
  n1 <- evalP e1
  n2 <- evalP e2
  count "Add"
  return (n1 + n2)
evalP (Div   e1 e2) = do 
  n1 <- evalP e1 
  n2 <- evalP e2 
  count "Div"
  return (n1 `div` n2)

runProfile :: Profile a -> (a, Counter)
runProfile act = runState act M.empty

count :: String -> Profile ()
count op = do
  m <- get 
  let n = M.findWithDefault 0 op m
  put (M.insert op (n+1) m)



goodExpr = Plus (Div (Number 100) (Number 10)) (Plus (Number 20) (Plus (Number 30) (Number 40)))

-- >>> runProfile (evalP goodExpr)
-- (100,fromList [("Add",3),("Div",1)])

{- 

  A. 99
  B. (99, 0)
  C. (0, 99)
  D. (99, 99)
  E. 0

-}


-- eCrash = (Div (Number 10) (Plus (Number 5) (Number (-5))))
