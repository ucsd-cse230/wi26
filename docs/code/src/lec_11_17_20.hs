{-# LANGUAGE DeriveFunctor #-}
{-# LANGUAGE FlexibleInstances #-}

module Lec_11_17_20 where

-- import Prelude hiding (return, (>>=))
import qualified Data.Map as M

inc :: Int -> Int 
inc x = x + 1

data Expr
  = Number Int            -- ^ 0,1,2,3,4
  | Plus   Expr Expr      -- ^ e1 + e2
  | Minus  Expr Expr      -- ^ e1 - e2
  | Mult   Expr Expr      -- ^ e1 * e2
  | Div    Expr Expr      -- ^ e1 / e2
  deriving (Show)

eval :: Expr -> Int
eval (Number v)    = v
eval (Plus e1 e2)  = eval e1 + eval e2
eval (Minus e1 e2) = eval e1 - eval e2
eval (Mult e1 e2)  = eval e1 * eval e2
eval (Div e1 e2)   = eval e1 `div` eval e2

data Result v 
  = Ok v                -- ^ v is a valid "result"
  | Error String        -- ^ oops an error occurred with message String
  deriving (Eq, Show) 


instance Monad Result where
  -- return  :: a -> Result a
  return v = Ok v

  -- (>>=) :: Result a -> (a -> Result b) -> Result b
  e >>= doStuff = case e of
                    Error msg -> Error msg
                    Ok v      -> doStuff v

{- 
class Monad m where
    (>>=)  :: m a -> (a -> m b) -> m b
    return :: a -> m a
-}


foo :: Monad m => m a -> m b -> m (a, b)
foo m1 m2 = m1 >>= (\x1 -> 
              m2 >>= (\x2 -> 
                return (x1, x2)
            )) 

foo' :: Monad m => m a -> m b -> m (a, b)
foo' m1 m2 = do
  x1 <- m1
  x2 <- m2
  return (x1, x2)


e10 = Plus (Number 32) (Div (Number 20) (Number 0)) 

-- >>> safeEval e10
-- Error "Oops dbz in: Number 0"
-- Error "Oops dbz in: Number 0"
safeEval :: Expr -> Result Int
safeEval (Number n)    = return n
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
safeEval (Div e1 e2)   = do { v1 <- safeEval e1; 
                              v2 <- safeEval e2; 
                              if v2 == 0 
                                then (Error ("Oops dbz in: " ++ show e2))
                                else (Ok (v1 `div` v2))
                            }  

instance Applicative Result where
instance Functor Result where



data Tree a
    = Leaf a
    | Node (Tree a) (Tree a)
    deriving (Eq, Show, Functor)


charT :: Tree Char
charT = Node 
            (Node 
                (Leaf 'a') 
                (Leaf 'b')) 
            (Node 
                (Leaf 'c') 
                (Leaf 'a'))

test :: (a -> b) -> Tree a -> Tree b
test f t = fmap f t


-- >>> label charT 
-- Node (Node (Leaf ('a',0)) (Leaf ('b',1))) (Node (Leaf ('c',2)) (Leaf ('a',3)))

-- >>> labelT charT
-- Node (Node (Leaf ('a',1000)) (Leaf ('b',1001))) (Node (Leaf ('c',1002)) (Leaf ('a',1003)))

labelT t = evalState 1000 (helperT t)

helperT :: Tree a -> ST (Tree (a, Int))

helperT (Leaf x) = do
  n <- count
  return (Leaf (x, n))

helperT (Node l r) = do
  l' <- helperT l
  r' <- helperT r
  return (Node l' r')

helper :: Int -> Tree a -> (Int, Tree (a, Int))
helper n (Leaf x)   = (n + 1, Leaf (x, n))

helper n (Node l r) = let (n', l')  = helper n  l 
                          (n'', r') = helper n' r
                      in
                          (n'', Node l' r')


-- >>> keyLabel charT 
-- Node (Node (Leaf ('a',0)) (Leaf ('b',0))) (Node (Leaf ('c',0)) (Leaf ('a',1)))


label :: Tree a -> Tree (a, Int)
label t = snd (helper 0 t)

keyLabel :: Tree Char -> Tree (Char, Int)
keyLabel t = snd (keyHelper M.empty t)

keyHelper :: M.Map Char Int -> Tree Char -> (M.Map Char Int, Tree (Char, Int))
keyHelper m (Leaf x)   = let (m', n) = nextLabel m x 
                         in 
                             (m', Leaf (x, n))

keyHelper m (Node l r) = let (m', l')  = keyHelper m  l 
                             (m'', r') = keyHelper m' r
                         in
                             (m'', Node l' r')

nextLabel :: M.Map Char Int -> Char -> (M.Map Char Int, Int)
nextLabel m x = (M.insert x (n+1) m, n)                           
  where     
    n         = M.findWithDefault 0 x m


----
type State = Int

data ST a = STC (State -> (State, a))

returnST :: a -> ST a
returnST v = STC (\s -> (s, v))


bindST :: ST a -> (a -> ST b) -> ST b
bindST (STC sta) f_stb = STC (\s -> 
  let (s', va) = sta s
      STC stb  = f_stb va
      (s'', vb) = stb s'
  in
      (s'', vb)
  )

instance Monad ST where
  return = returnST
  (>>=)  = bindST

evalState :: State -> ST a -> a
evalState s (STC f) = snd (f s)

count :: ST Int
count = STC (\s -> (s+1, s))


next :: ST String
next = STC (\s -> (s+1, show s))

wtf1 :: ST String
wtf1 = next >>= (\n -> return n) 

wtf2 :: ST [String]
wtf2 = next >>= (\n1 -> 
         next >>= (\n2 -> 
           return [n1, n2] 
         )
       )

wtf2' = do
  n1 <- next
  n2 <- next
  return [n1, n2]
-- >>> evalState 100 wtf2'
-- ["100","101"]




-- >>> evalState 100 wtf1
-- 5000


instance Functor ST where
instance Applicative ST where