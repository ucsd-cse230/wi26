{- HLINT ignore "Eta reduce" -}
{- HLINT ignore "Use uncurry" -}
{- HLINT ignore "Use :" -}
{- HLINT ignore "Use id" -}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE UndecidableInstances #-}
{- HLINT ignore "Avoid lambda" -}
{- HLINT ignore "Use map" -}

module Lec_2_3_26  where

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
