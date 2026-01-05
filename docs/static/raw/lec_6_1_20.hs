{-# LANGUAGE DeriveFunctor        #-}
{-# LANGUAGE TypeSynonymInstances #-}
{-# LANGUAGE FlexibleInstances    #-}
{-# LANGUAGE FlexibleContexts     #-}
{-# LANGUAGE ConstraintKinds      #-}


module Lec_6_1_20 where

import Control.Monad.Except
import Control.Monad.State
import Control.Monad.Identity




--------------------------------------------------------------------------------
-- 1. Computations that can fail
--------------------------------------------------------------------------------

-- | An Expression Datatype ---------------------------------------------------- 
data Expr
  = Number Int            -- ^ 0,1,2,3,4
  | Plus   Expr Expr      -- ^ e1 + e2
  | Div    Expr Expr      -- ^ e1 / e2
  | Def    Expr Int       -- ^ Def e n  
  deriving (Show)

e1 :: Expr
e1 = Div (Number 10) (Plus (Number 5) (Number 5))

e2 :: Expr
e2 = Div (Number 10) (Plus (Number 5) (Number (-5)))

e1' = Def e1 100 

e2' = Def e2 100 





-- | A Simple (but crashing) evaluator ----------------------------------------- 

eval :: Expr -> Int
eval (Number n)    = n
eval (Plus  e1 e2) = eval e1   +   eval e2
eval (Div   e1 e2) = eval e1 `div` eval e2

-- >>> eval e1
-- 1
--

-- >>> eval e2
-- *** Exception: divide by zero
--


--------------------------------------------------------------------------------
-- | 2. Representing Possible Failure with a `Result` datatype -----------------
--------------------------------------------------------------------------------

data Result a 
  = Ok  a 
  | Err String
  deriving (Show, Functor)

instance Monad Result where
  return x      = Ok x
  (Ok v)  >>= f = f v
  (Err s) >>= _ = Err s

-- | An evaluator that returns a Result instead of crashing evaluator ----------

evalResult :: Expr -> Result Int
evalResult = eval
  where
    eval (Number n)    = return n
    eval (Plus  e1 e2) = do n1 <- evalResult e1 
                            n2 <- evalResult e2 
                            return (n1 + n2)
    eval (Div   e1 e2) = do n1 <- evalResult e1 
                            n2 <- evalResult e2 
                            if n2 /= 0 
                              then return (n1 `div` n2) 
                              else Err ("DBZ: " ++ show e2)


-- >>> evalResult e1
-- Ok 1
--

-- >>> evalResult e2
-- Err "DBZ: Plus (Number 5) (Number (-5))"
--
-- >>> e2
-- Div (Number 10) (Plus (Number 5) (Number (-5)))
--

--------------------------------------------------------------------------------
-- | 3. `Result` aka `Either` in the standard library --------------------------
--------------------------------------------------------------------------------

-- data Either e a = Left e | Right a

evalEither :: Expr -> Either Expr Int
evalEither = eval
  where
    eval (Number n)    = return n
    eval (Plus  e1 e2) = do n1 <- eval e1 
                            n2 <- eval e2
                            return (n1 + n2)
    eval (Div   e1 e2) = do n1 <- eval e1 
                            n2 <- eval e2
                            if n2 /= 0 
                              then return (n1 `div` n2) 
                              else throwAnError e2
    eval (Def   e n)   = tryCatchError                -- try  
                           (eval e)                   --   { e }
                           (\exn -> return n)         -- (exn) { ...}


throwAnError = Left

tryCatchError :: Either e a -> (e -> Either e a) -> Either e a
tryCatchError (Right val) handler = Right val
tryCatchError (Left exn)  handler = handler exn


q1  = Div (Number 10) (Plus (Number 5) (Number (-5)))

-- >>> evalEither (Def q1 7)
-- Right 7
--

{- 
   evalEither (Def q1 7)
==> tryCatchError (eval q1) (\_ -> return 7)
==> tryCatchError (Left e2) (\_ -> return 7)
==> (\_ -> return 7) e2
==> return 7
==> Right 7
-}

-- >>> evalEither (Div (Number 10) (Plus (Number 5) (Number (-5))))
-- Left (Plus (Number 5) (Number (-5)))
--

-- >>> evalEither (Def e1 100)
-- Right 1
--

-- >>> evalEither (Def e2 100000)
-- Right 100000
--




-- >>> evalEither e1
-- Right 1
--

-- >>> (evalEither e2)
-- Left (Plus (Number 5) (Number (-5)))
--



--------------------------------------------------------------------------------
-- | 4. `Either` (or `Result`) is an Exception-Handling Monad! -----------------
--------------------------------------------------------------------------------

-- | `throw` an exception `e` --------------------------------------------------
throw :: e -> Either e a
throw exn = Left exn





evalThrow :: Expr -> Either Expr Int
evalThrow = eval
  where
    eval (Number n)    = return n
    eval (Plus  e1 e2) = do n1 <- eval e1 
                            n2 <- eval e2
                            return (n1 + n2)
    eval (Div   e1 e2) = do n1 <- eval e1 
                            n2 <- eval e2
                            if n2 /= 0 
                              then return (n1 `div` n2) 
                              else throw e2

-- >>> evalThrow e1
-- Right 1
--

-- >>> evalThrow e2 
-- Left (Plus (Number 5) (Number (-5)))
--


-- | `catch` an exception `e` --------------------------------------------------

catch :: Either e a -> (e -> Either e a) -> Either e a
catch (Right v) handler = Right v 
catch (Left  e) handler = handler e

-- tryCatch :: Either e a -> a -> Either e a  
tryCatch m def = catchError m (\_ -> return def)

evalThrowCatch :: Expr -> Exn Int
evalThrowCatch = eval 
  where
    eval (Number n)    = return n
    eval (Plus  e1 e2) = do n1 <- eval e1 
                            n2 <- eval e2
                            return (n1+n2)
    eval (Div   e1 e2) = do n1 <- eval e1 
                            n2 <- eval e2
                            if n2 /= 0 
                              then return (n1 `div` n2) 
                              else throwError e2
--    eval (Try e n)     = tryCatch (eval e) n


-- | `throw` and `catch` are in the standard library --------------------------

-- throwError :: e -> Either e a

-- catchError :: Either e a -> (e -> Either e a) -> Either e a

-- >>> evalThrowCatch (Try e1 7)
-- Right 1
--

-- >>> evalThrowCatch (Try e2 7)
-- Right 7
--

-------------------------------------------------------------------------------
-- | 5. A Profiling Monad 
-------------------------------------------------------------------------------

-- | A State-Transformer with a "global" `Int` counter ------------------------
type Profile a = State Int a



runProfile :: (Show a) => Profile a -> String 
runProfile st = showValCount thing  
  where thing = (runState st 0)



showValCount :: (Show a, Show c) => (a, c) -> String
showValCount (val, count) = "value: " ++ show val ++ ", count: " ++ show count 

-- | A "global" `count` operator ----------------------------------------------- 
-- count :: Profile ()
count = do
  n <- get
  put (n+1)


-- | Eval with PROFILING ------------------------------------------------------ 
evalProf :: Expr -> Profile Int 
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
                            return (n1 `div` n2)
    -- eval (Def e n)     = tryCatch (eval e) (\_ -> return n)

-- >>> e1
-- Div (Number 500) (Plus (Number 5) (Number 5))
--

-- >>> runProfile (evalProf (Div (Number 500) ((Plus (Number 10) (Plus (Number 5) (Number 5))))))
-- "value: 25, count: 3"
--

-- >>> e2
-- Div (Number 10) (Plus (Number 5) (Number (-5)))
--

-- >>> runProfile (evalProf e2)
-- *** Exception: divide by zero
-- "value: 
--

-------------------------------------------------------------------------------
-- How to get PROFILING **AND** EXCEPTIONS ???
-------------------------------------------------------------------------------





-------------------------------------------------------------------------------
-- | 6. SPECIFYING Monads with Extra Features --------------------------------- 
-------------------------------------------------------------------------------

{- | `(MonadState s m)` means `m` is ANY "State-Transformer" monad over state `s`

      * Supports `>>=` and `return`    

      * Supports `get :: m s`, `put :: s -> m ()` 

 -}

-- Refactor `count` specification to USE `MonadState Int` ------------------------ 

count :: (MonadState Int m) => m ()
-- count = do
--   n <- get
--   put (n+1)


{- | `MonadError e m` means `m` is ANY "Exception" monad where the exception has type `e`

      * Supports `>>=` and `return`    

      * Supports `throwError :: e -> m a `, `catchError :: m a -> (e -> m a) -> m a`

  -} 

-- Refactor `tryCatch` specification to USE `MonadState Int` ------------------- 

tryCatch :: (MonadError Expr m) => m a -> a -> m a  
-- tryCatch m def = catchError m (\_ -> return def)

-- | Refactor `eval` specification to a monad `m` that implements BOTH of 
-- `MonadState Int` AND `MonadError Expr`

evalMix :: (MonadState Int m, MonadError Expr m) => Expr -> m Int 
evalMix = eval 
  where 
    eval (Number n)    = return n
    eval (Plus  e1 e2) = do n1 <- eval e1 
                            n2 <- eval e2
                            count
                            return (n1 + n2)
    eval (Div   e1 e2) = do n1 <- eval e1 
                            n2 <- eval e2
                            count
                            if (n2 /= 0) 
                              then return (n1 `div` n2) 
                              else throwError e2
--    eval (Try e n)     = tryCatch (eval e) n

-- >>> evalMix e1 

-- >>> evalMix e2

-------------------------------------------------------------------------------
-- GHC: "Sure, but WHAT is this MAGIC MONAD that implements BOTH features?"
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- | 7. IMPLEMENTING Monads with Extra Features -------------------------------
-------------------------------------------------------------------------------

{- | `Identity a`  is a BASIC monad with NO features

      data Identity a = Id a

      instance Monad Identity where
        return a     = Id a
        (Id a) >>= f = f a

     `StateT s m` takes a monad `m` and TRANSFORMS it into a NEW monad m' with

      - whatever `m` implements
      - PLUS adds State-transformer capabilities (MonadState s m')

     `ExceptT e m` takes a monad `m` and TRANSFORMS it into a NEW monad m' with 

      - whatever `m` implements
      - PLUS adds Exception-handling capabilities (MonadError e m')

 -}

-- The following implements "State-transformer over `Int` states"
type Prof = StateT Int Identity 

-- We can go back and give `evalProf` the type

--   evalProf :: Expr -> Prof Int


-- The following implements "Exception-handling over `Expr` exceptions"
type Exn = ExceptT Expr Identity 

-- We can go back and give `evalThrowCatch` the type

--   evalThrowCatch :: Expr -> Exn Int

-- TRANSFORMERS COMPOSE! We can "layer" the transformers to get BOTH powers! 

-- The following implements a "State-transformer-over Int" AND "Exception-handling-over-`Expr`-Expressions"

type ProfExn a = StateT Int Exn a       -- StateT ( ExceptT ( Identity ) )


runProfExn :: (Show a) => ProfExn a -> String
runProfExn st = case (runIdentity (runExceptT (runStateT st 0))) of
  Right vc -> showValCount vc
  e        -> show e


-- >>> runProfExn (evalMix e1) 
-- "value: 1, count: 2"
--
-- >>> runProfExn (evalMix e2) 
-- "Left (Plus (Number 5) (Number (-5)))"
--

type ExnProf a = ExceptT Expr Prof a    -- ExceptT (StateT (Identity))

runExnProf :: (Show a) => ExnProf a -> String
runExnProf m = case (runIdentity (runStateT (runExceptT m) 0)) of
                 (Right v, c) -> showValCount (v, c)
                 (Left e, c)  -> show e ++ " after " ++ show c ++ " operations"


-- >>> runExnProf (evalMix e1) 
-- "value: 1, count: 2"
--

-- >>> runExnProf (evalMix e2) 
-- "Plus (Number 5) (Number (-5)) after 2 operations"
--

























instance Applicative Result where
  pure  = undefined
  (<*>) = undefined
