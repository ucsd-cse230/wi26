{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE DeriveFunctor #-}
{-# LANGUAGE FlexibleContexts #-}

module Lec_11_16_21 where

import           Control.Monad.State
import qualified Text.Printf as Printf
import Control.Monad.Except
import GHC.Base (Applicative)
import GHC.IO.Handle.Internals (hClose_help)


type Profile a = State Int a

runProfile :: (Show a) => Profile a -> String 
runProfile st = showValCount (runState st 0)

showValCount :: (Show v) => (v, Int) -> String
showValCount (val, n) = Printf.printf "value: %s, ops: %d" (show val) n

-- count :: Profile ()
count :: (MonadState Int m) => m ()
count = do
  n <- get
  put (n + 1)



data Expr 
  = Number Int
  | Plus   Expr Expr
  | Div    Expr Expr
  deriving (Show)

exp0 :: Expr
exp0 = Div (Number 200) (Plus (Number 5) (Number (-5)))

-- >>> showProf (evalP exp0)



-- >>> (evalE exp0)
-- Right 20



eval :: Expr -> Int
eval (Number n)   = n
eval (Plus e1 e2) = eval e1 + eval e2 
eval (Div e1 e2)  = eval e1 `div` eval e2


{- 

@dec3
@dec2 
@dec1
def foo(x, y):
  return x + y


-}



showProf :: Show a => MyProf a -> String 
showProf p = Printf.printf "result = %s, count = %d" (show v) n 
  where 
    (v, n) = runState p 0

type MyProf a = State Int (Either Expr a)



{- 

-- add :: Int -> Int -> Int
add :: (Num a) => a -> a -> a
add x y = x + y

-- thump :: MyProf ()

class Monad m => MonadState s m where
  get :: m s
  put :: s -> m () 


class Monad m => MonadError e m where
  throwError :: e -> m ()
  catchError :: m a -> (e -> m a) -> m a
-}

thump :: (MonadState Int m) => m ()
thump = do
  n <- get
  put (n + 1)

showAndAdd :: (Show a, Num a) => a -> String
showAndAdd x = show (x + 1)

-- >>> evalPE exp0
-- Ambiguous type variable ‘m0’ arising from a use of ‘evalPrint’
-- prevents the constraint ‘(Show (m0 Int))’ from being solved.
-- Probable fix: use a type annotation to specify what ‘m0’ should be.
-- These potential instances exist:
--   instance Show a => Show (ZipList a)
--     -- Defined in ‘Control.Applicative’
--   instance Show a => Show (Complex a) -- Defined in ‘Data.Complex’
--   instance (Show a, Show b) => Show (Either a b)
--     -- Defined in ‘Data.Either’
--   ...plus 76 others
--   (use -fprint-potential-instances to see them all)

evalPE :: (MonadState Int m, MonadError Expr m) => Expr -> m Int
evalPE (Number n)   = return n
evalPE (Plus e1 e2) = do 
    n1 <- evalPE e1
    n2 <- evalPE e2
    thump
    return (n1 + n2) 
evalPE (Div e1 e2)  = do 
    n1 <- evalPE e1
    n2 <- evalPE e2
    thump
    if n2 == 0 then throwError e2 else return (div n1 n2) 








bump :: MyProf ()
bump = do
    n <- get 
    put (n + 1)
    return (Right ())


evalP :: Expr -> MyProf Int
evalP (Number n)   = return (Right n)
evalP (Plus e1 e2) = do 
  n1 <- evalP e1
  n2 <- evalP e2
  _  <- bump
  return (do {v1 <- n1; v2 <- n2; return (v1+v2) })

evalP (Div e1 e2) = do
  n1 <- evalP e1
  n2 <- evalP e2
  _  <- bump
  return (do {v1 <- n1; v2 <- n2; if v2 == 0 then throw e2 else return (div v1 v2) })

-- >>> showProf (evalP exp0)
-- "result = Left (Plus (Number 5) (Number (-5))), count = 2"

-- "result = Right 20, count = 2"






evalE :: Expr -> Either Expr Int
evalE (Number n)   = return n
evalE (Plus e1 e2) = do 
    n1 <- evalE e1
    n2 <- evalE e2
    return (n1+n2) 
evalE (Div e1 e2)  = do 
    n1 <- evalE e1
    n2 <- evalE e2
    if n2 == 0 then throw e2 else return (div n1 n2) 

throw :: a -> Either a b
throw = Left






evalProf :: Expr -> ExProf Int 
evalProf = eval 
  where
    eval (Number n)    = return n
    eval (Plus  e1 e2) = do n1 <- eval e1 
                            n2 <- eval e2
                            count
                            return (n1+n2)
    eval (Div   e1 e2) = do n1 <- eval e1 
                            n2 <- eval e2
                            count
                            if n2 == 0 then throwError e2 else return (n1 `div` n2) 
-- >>> runExProf (evalProf expr1)  
-- (Right 20,2)

runProfEx :: ProfEx a -> Either Expr (a, Int) 
runProfEx profex = res
  where
    Ident res = runExceptT (runStateT profex 0)

runExProf :: ExProf a -> (Either Expr a, Int)
runExProf exprof = foo 
    where 
        Ident foo = runStateT (runExceptT exprof) 0

foo = (runExceptT, runStateT)

expr1 :: Expr
expr1 = Div (Number 200) (Plus (Number 5) (Number 5))

expr2 :: Expr
expr2 = Div (Number 10) (Plus (Number 5) (Number (-5)))




type Prof = StateT Int Ident 

type Exn  = ExceptT Expr Ident

type ExProf = ExceptT Expr Prof

type ProfEx = StateT  Int Exn




newtype Ident a = Ident a 

instance Functor Ident where
    fmap f (Ident a) = Ident (f a)

instance Applicative Ident where
  pure x = Ident x
  (Ident f) <*> (Ident x) = Ident (f x)

instance Monad Ident where
  return        = pure
  Ident a >>= f = f a














newtype Identity a = Id { unId :: a }  deriving (Functor)











instance Monad Identity where
  return a     = Id a
  (Id a) >>= f = f a


type ProfExn = StateT Int Exn
type ExnProf = ExceptT Expr Prof

runExnProf :: (Show a) => ExnProf a -> Either Expr (a, Int)
runExnProf ep = undefined

runProfExn :: (Show a) => ProfExn a -> Either Expr (a, Int)
runProfExn ep = undefined 

-- runStateT :: StateT s m a -> s -> m (a, s)

-- runExceptT :: ExceptT e m a -> m (Either e a)

















instance Applicative Identity where
  pure x        = Id x 
  Id f <*> Id x = Id (f x)


-- runProfExn ep = unId (runExceptT (runStateT ep 0)) 
