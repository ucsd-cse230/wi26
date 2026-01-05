{-# LANGUAGE DeriveFunctor #-}
module Lec_10_28_21 where

import Text.Printf (printf)

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
evalM (Mul e1 e2)    = do { 
  n1 <- evalM e1; 
  n2 <- evalM e2; 
  return (n1 * n2) 
  }
evalM (Div e1 e2)    = do { 
  n1 <- evalM e1; 
  n2 <- evalM e2;
  if n2 == 0 
    then throw ("Oops dbz: " ++ show e2)
    else return (n1 `div` n2) 
  }
evalM (Ite e1 e2 e3) = ite <$> evalR e1 <*> evalR e2 <*> evalR e3 

defaultResult :: Integer
defaultResult = 999

silly :: Expr -> Integer
silly e = case evalM e of
  Val n -> n
  _     -> defaultResult



throw = Err

-- >>> silly (Div (2 + 4) (2 + 1))
-- 2
{- 

do {
  x1 <- e1;
  x2 <- e2;
  x3 <- e3;
  e
}

e1 >>= \x1 -> 
  e2 >>= \x2 ->
    e3 >>= \x3 -> 
      e
 

-}




ite n1 n2 n3 = if n1 /= 0 then n2 else n3

instance Applicative Result where
  (<*>) = apply
  pure  = Val

apply :: Result (a -> b) -> Result a -> Result b
apply fR aR = 
    case fR of
        Err msg -> Err msg
        Val f -> case aR of 
            Err msg -> Err msg
            Val a -> Val (f a) 


data Result a 
  = Err String 
  | Val a
  deriving (Show, Functor)


data List a = Nil | Cons a (List a) deriving (Show, Functor)

instance Monad List where
  -- (>>=)  :: List a -> (a -> List b) -> List b
  xs >>= f = awesomeList xs f

  -- return :: a -> List a
  return x = Cons x Nil





awesomeList :: List a -> (a -> List b) -> List b
awesomeList Nil         _ = Nil
awesomeList (Cons a as) f = append (f a) (awesomeList as f)

append :: List b -> List b -> List b
append Nil         ys = ys
append (Cons x xs) ys = Cons x (append xs ys) 


-- fmap  f [a1, a2, a3] ==> [b11, b12, b13, b21, b22, b31]

instance Applicative List where

{-
class Monad m where
    (>>=)  :: m a -> (a -> m b) -> m b
    return :: a -> m a 
-}

instance Monad Result where
    (>>=) = awesome
    return x = Val x

awesome :: Result a -> (a -> Result b) -> Result b
awesome (Err msg) _ = Err msg 
awesome (Val v)   f = f v

{- 
    case r1 of
        Nul    -> Nul
        Val n1 -> ... -- do_stuff_with n1
            
            case r2 of 
                Nul -> Nul 
                Val n2 -> -- do_stuff_with n2 ...
                
                
                
                Val (n1 `op` n2)
-}

foo :: List (Integer, Bool)
foo = do
  x <- Cons 1 (Cons 2 (Cons 3 Nil))
  y <- Cons True (Cons False Nil) 
  return (x, y)

{- 
   for x in (range 1 3):
     for y in (range ...):
       yield (x, y)

-}


-- >>> foo
-- Cons (1,True) (Cons (1,False) (Cons (2,True) (Cons (2,False) (Cons (3,True) (Cons (3,False) Nil)))))












expr0' :: Expr
expr0' = Sub (Add (Con 4) (Con 5)) (Con 2)

-- e0 = (Num 2) `Add` ((Num 3) `Mul` (Num 7)) `Sub` (Num 4)

instance Num Expr where
    fromInteger = Con
    (+)         = Add 
    (-)         = Sub
    (*)         = Mul 







tree0' = fmap (\c -> (c, 0)) tree0

treeLabelled :: Tree (Char, Int)
treeLabelled = Node (Node (Leaf ('a',0)) (Leaf ('b',1))) (Node (Leaf ('c',2)) (Leaf ('a',3)))

-- >>> label tree0
-- Node (Node (Leaf ('a',0)) (Leaf ('b',1))) (Node (Leaf ('c',2)) (Leaf ('a',3)))

type State = Int

label :: Tree a -> Tree (a, Int)
label t = fst (worker t 0)

worker :: Tree a -> State -> (Tree (a, Int), State)
worker (Leaf v)   n = (Leaf (v, n),  n')
  where
    n' = n + 1 

worker (Node l r) n = (Node l' r', n'')
  where
    (l', n')  = worker l n
    (r', n'') = worker r n'

-- >>> labelM tree0
-- Node (Node (Leaf ('a',"0")) (Leaf ('b',"1"))) (Node (Leaf ('c',"2")) (Leaf ('a',"3")))

labelM :: Tree a -> Tree (a, String)
labelM t = fst (evalstate 0 (workerM t))

workerM :: Tree a -> ST (Tree (a, String))
workerM (Leaf v) = do 
  n <- tick
  return (Leaf (v, n))

workerM (Node l r) = do 
  l' <- workerM l
  r' <- workerM r
  return (Node l' r')

newtype ST a = STC (State -> (a, State))

instance Functor ST where
  fmap = fmapST 

{- 

  sta :: State -> (a, State)  
  s   :: State
  f   :: a -> b

  sta s :: (a, State)


-}




instance Applicative ST where

instance Monad ST where
    -- (>>=)  :: ST a -> (a -> ST b) -> ST b
    (>>=) = awesomeST
    -- return :: a -> ST a 
    return = returnST



st :: ST [Int]
st = STC (\n -> ([n, n+1, n+2], n+3))

-- >>> evalstate 1000 st
-- ([1000,1001,1002],1003)

-- >>> evalstate 100 tick
-- ("100",101)

-- >>> evalstate 100 (tick >>= \_ -> return "mugatu")
-- ("mugatu",101)

-- >>> evalstate 100 (do { n0 <- tick; n1 <- tick; n2 <- tick; return [n0,n1,n2] })
-- (["100","101","102"],103)

--(A) z = "100"
--(B) z = "101"
--(C) z = "102"


-- >>> evalstate 100 (tick >>= \z1 -> return [z1])

-- >>> evalstate 0 (do { z0 <- tick; _ <- tick; z2 <- tick; return (z0 ++ z2) })
-- ("02",3)
-- ("100102",103)

tick :: ST String
tick = STC (\n -> (show n, n+1))


evalstate :: State -> ST a -> (a, State) 
evalstate s0 (STC sta) = sta s0

returnST :: a -> ST a
returnST a = STC (\s -> (a, s)) 

awesomeST :: ST a -> (a -> ST b) -> ST b
awesomeST (STC sta) a_to_stb = STC 
  (\s -> 
    let (a, s')  = sta s 
        STC stb  = a_to_stb a
        (b, s'') = stb s' 
    in
       (b, s'')
  )

fmapST :: (a -> b) -> ST a -> ST b
fmapST f (STC sta) = STC (\s -> let (a, s') = sta s in (f a, s')) 



tree0 :: Tree Char
tree0 = Node 
          (Node 
              (Leaf 'a') 
              (Leaf 'b')) 
          (Node 
              (Leaf 'c') 
              (Leaf 'a'))


data Tree a = Leaf a | Node (Tree a) (Tree a)
  deriving (Show, Functor)

class Mappable t where
  gmap :: (a -> b) -> t a -> t b 

{- 

class Show a where
  show :: a -> String
instance Show Tree where
    show Leaf = "leaf"
    show (Node x l r) = "node"


-}










