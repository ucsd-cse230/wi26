{-# LANGUAGE DeriveFunctor #-}
module Lec_10_26_21 where

import Text.Printf (printf)

incr :: Int -> Int
incr x = x + 1

data Expr
  = Con Integer        -- ^ 0,1,2,3,4
  | Add Expr Expr      -- ^ e1 + e2
  | Sub Expr Expr      -- ^ e1 - e2
  | Mul Expr Expr      -- ^ e1 * e2
  | Div Expr Expr      -- ^ e1 / e2
  | Ite Expr Expr Expr -- ^ if e1 /= 0 then e2 else e3
  deriving (Show)

expr0 :: Expr
expr0 = (1 + 1)

expr1 :: Expr
expr1 = Div expr0' expr0 

data Result a 
  = Nul  
  | Val a
  deriving (Show, Functor)

-- >>> evalR expr1
-- Val 3

-- Div (Sub (Add (Con 4) (Con 5)) (Con 2)) (Add (Con 1) (Con 1))

eval :: Expr -> Integer 
eval (Con n)     = n 
eval (Add e1 e2) = eval e1 + eval e2
eval (Sub e1 e2) = eval e1 - eval e2
eval (Mul e1 e2) = eval e1 * eval e2 
eval (Div e1 e2) = eval e1 `div` eval e2 
eval (Ite e1 e2 e3) = if eval e1 /= 0 then eval e2 else eval e3

evalR :: Expr -> Result Integer 
evalR (Con n)        = pure n 
evalR (Add e1 e2)    = (+) <$> evalR e1 <*> evalR e2 
evalR (Sub e1 e2)    = (-) <$> evalR e1 <*> evalR e2 
evalR (Mul e1 e2)    = (*) <$> evalR e1 <*> evalR e2 
evalR (Div e1 e2)    = div <$> evalR e1 <*> evalR e2 
evalR (Ite e1 e2 e3) = ite <$> evalR e1 <*> evalR e2 <*> evalR e3 

evalM :: Expr -> Result Integer 
evalM (Con n)        = pure n 
evalM (Add e1 e2)    = do { n1 <- evalM e1; n2 <- evalM e2; return (n1 + n2) }
evalM (Sub e1 e2)    = do { n1 <- evalM e1; n2 <- evalM e2; return (n1 - n2) }
evalM (Mul e1 e2)    = do { n1 <- evalM e1; n2 <- evalM e2; return (n1 * n2) }
evalM (Div e1 e2)    = do { n1 <- evalM e1; n2 <- evalM e2; return (n1 `div` n2) }
evalM (Ite e1 e2 e3) = ite <$> evalR e1 <*> evalR e2 <*> evalR e3 






{- 

  pure f <*> x      === fmap f x

        f            :: a -> b
        pure f       :: Result (a -> b)
        x            :: Result a
        pure f <*> x :: Result b


        fmap :: (a -> b) -> Result a -> Result b
        f            :: a -> b
        x            :: Result a
        fmap f x    :: Result b 

 fmap :: (a -> b) -> Result a -> Result b

 pure :: a -> Result a

 <*>  :: Result (a -> b) -> Result a -> Result b



-}



ite n1 n2 n3 = if n1 /= 0 then n2 else n3

check0 :: Result Integer -> Result Integer
check0 (Val 0) = Nul
check0 r       = r 

{- 
  class Functor f => Applicative f where
    pure :: a -> f a
    (<*>) :: f (a -> b) -> f a -> f b

  class Applicative r where
      apply :: r (a -> b) -> r a -> r b

      apply :: Result (a -> b) -> Result a -> Result b 
-}



-- >>> evalR expr0
-- Val 0



magic3 :: (a1 -> a2 -> a3 -> b) -> Result a1 -> Result a2 -> Result a3 -> Result b
magic3 op r1 r2 r3 = 
    case r1 of
        Nul    -> Nul
        Val n1 -> case r2 of 
            Nul -> Nul 
            Val n2 -> case r3 of 
                Nul -> Nul 
                Val n3 -> Val (op n1 n2 n3)


instance Applicative Result where
  (<*>) = apply
  pure  = Val

apply :: Result (a -> b) -> Result a -> Result b
apply fR aR = 
    case fR of
        Nul   -> Nul
        Val f -> case aR of 
            Nul -> Nul 
            Val a -> Val (f a) 

inc :: Integer -> Integer 
inc x = x + 1

-- >>> apply (Val inc) Nul
-- Nul

-- >>> inc 8

-- >>> apply (Val inc) (Val 8)
-- Val 9

mystery :: Result (Integer -> Integer)
mystery = apply (Val plus) (Val 10)

-- >>> ((Val plus) `apply` (Val 10)) `apply` (Val 20)
-- Val 30


plus :: Integer -> Integer -> Integer
plus x y = x + y 


magic2 :: (a1 -> a2 -> b) -> Result a1 -> Result a2 -> Result b
magic2 op r1 r2 = do 
    { n1 <- r1; 
      n2 <- r2;
     pure (n1 `op` n2)
    }
    -- (>>=) r1 (\n1 -> 
    --     (>>=) r2 (\n2 -> 
    --         pure (n1 `op` n2)
    --     )
    -- )

{-

do {
    x1 <- e1;
    x2 <- e2;
    e3
}

e1 >>= \x1 -> 
    e2 >>= \x2 ->
        e3


      (a -> b) -> t a -> t b
    
    t (a -> b) -> t a -> t b
    
    t a -> (a -> t b) -> t b



class Monad m where
    (>>=) :: m a -> (a -> m b) -> m b
-}
instance Monad Result where
    (>>=) = awesome

awesome :: Result a -> (a -> Result b) -> Result b
awesome r doStuff = case r of 
    Nul -> Nul
    Val n -> doStuff n

{- 
    case r1 of
        Nul    -> Nul
        Val n1 -> ... -- do_stuff_with n1
            
            case r2 of 
                Nul -> Nul 
                Val n2 -> -- do_stuff_with n2 ...
                
                
                
                Val (n1 `op` n2)
-}



            












expr0' :: Expr
expr0' = Sub (Add (Con 4) (Con 5)) (Con 2)

-- e0 = (Num 2) `Add` ((Num 3) `Mul` (Num 7)) `Sub` (Num 4)

instance Num Expr where
    fromInteger = Con
    (+)         = Add 
    (-)         = Sub
    (*)         = Mul 







data Tree a = Leaf | Node a (Tree a) (Tree a)
  deriving (Functor)

class Mappable t where
  gmap :: (a -> b) -> t a -> t b 

{- 

class Show a where
  show :: a -> String
instance Show Tree where
    show Leaf = "leaf"
    show (Node x l r) = "node"


-}

instance Mappable Tree where
    gmap = mapTree 





instance Mappable [] where
    gmap = map


-- >>> fmap (\x -> x * x) (Node 10 Leaf Leaf)
-- Node 100 Leaf Leaf

mapTree f Leaf = Leaf
mapTree f (Node x l r) = Node (f x) (mapTree f l) (mapTree f r)



















data List a = Nil | Cons a (List a)
  deriving (Show)





















instance Functor List where

instance Applicative List where

instance Monad List where
    return x          = Cons x Nil
    Nil >>= k         = Nil
    (Cons x xs) >>= k = k x `append` (xs >>= k)

boo :: List (Integer, Bool)
boo = do
    x <- Cons 1 (Cons 2 Nil)
    y <- Cons True (Cons False Nil)
    return (x, y)

-- >>> boo
-- Cons (1,True) (Cons (1,False) (Cons (2,True) (Cons (2,False) Nil)))

append :: List a -> List a -> List a
append Nil ys         = ys
append (Cons x xs) ys = Cons x (append xs ys)