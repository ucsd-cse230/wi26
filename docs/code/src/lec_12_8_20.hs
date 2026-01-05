{-# LANGUAGE ConstraintKinds #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE DeriveFunctor #-}
{-# LANGUAGE FlexibleInstances #-}

module Lec_12_8_20 where
import qualified Data.Map as M
import Control.Monad.State
import Control.Monad.Error

data Expr
  = Number Int            -- ^ 0,1,2,3,4
  | Plus   Expr Expr      -- ^ e1 + e2
  | Div    Expr Expr      -- ^ e1 / e2
  | Def    Expr Int       -- ^ Def e n (try to eval e with exn return n) 
  deriving (Show)


-- eval :: Expr -> Profile Int 
-- eval :: (MonadState Counter m) => Expr -> m Int

eval :: (MonadState Counter m, MonadError String m)=> Expr -> m Int
eval (Number n)    = 
  return n
eval (Plus  e1 e2) = do 
  n1 <- eval e1
  n2 <- eval e2
  count "add"
  return (n1 + n2)
eval (Div   e1 e2) = do 
  n1 <- eval e1 
  n2 <- eval e2 
  if n2 /= 0 
    then do count "div"
            return (n1 `div` n2) 
    else throwError (show e2)
eval (Def e n) =
   catchError (eval e) (\_ -> return n) 

-- count :: String -> Profile ()
count :: (MonadState Counter m) => String -> m ()
count op = do
  m <- get 
  let n = M.findWithDefault 0 op m
  put (M.insert op (n+1) m)            

-- type Profile a = State Counter a
type Profile = StateT Counter Basic 

type Exn = ErrorT Expr Basic 

type ExnProf = ErrorT String (StateT Counter Basic) 

type ProfExn = StateT Counter (ErrorT String Basic)

runExnProf :: (Show a) => ExnProf a -> String
runExnProf act = show thing3
  where
    thing1 = runErrorT act
    thing2 = runStateT thing1
    BasicWrapper thing3 = thing2 M.empty

runProfExn :: (Show a) => ProfExn a -> String
runProfExn = undefined

-- >>> runExnProf (eval eCrash)
-- "(Left \"Plus (Number 5) (Number (-5))\",fromList [(\"add\",1)])"

-- "Result = ... , Ops = { "add" = 2, "div" = 1 }
-- "Error  = ... , Ops = { ... }"


-- runStateT :: StateT s m a -> s -> m (a, s)
-- runErrorT :: ErrorT e m a -> m (Either e a) 



type Counter = M.Map String Int

--- runProfile :: Profile a -> (a, Counter)
-- runProfile act = undefined runStateT -- act M.empty


throw :: e -> Either e a
throw err = Left err



eCrash :: Expr
eCrash = Div (Number 10) (Plus (Number 5) (Number (-5)))

-- >>> eval (Def eCrash 99)
-- Right 99 

goodExpr :: Expr
goodExpr = Plus (Div (Number 100) (Number 10)) (Plus (Number 20) (Plus (Number 30) (Number 40)))

-- >>>  (eval eCrash)

-- >>> runExnProf (eval goodExpr)


data Basic a = BasicWrapper a

instance Monad Basic where
  -- return :: a -> Basic a
  return a = BasicWrapper a 

  -- (>>=)  :: Basic a -> (a -> Basic b) -> Basic b
  (>>=) (BasicWrapper a) f = f a



















instance Applicative Basic where

instance Functor Basic where