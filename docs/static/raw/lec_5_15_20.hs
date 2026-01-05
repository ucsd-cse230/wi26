{-# LANGUAGE DeriveFunctor #-}

module Lec_5_15_20 where

import qualified Data.Map as M



data Tree a
    = Leaf a
    | Node (Tree a) (Tree a)
    deriving (Eq, Show)



charT :: Tree Char
charT = Node                    -- 0
            (Node 
                (Leaf 'a')      -- 0  
                (Leaf 'a'))     -- 1

            (Node 
                (Leaf 'c') 
                (Leaf 'a'))


label :: Tree a -> Tree (a, Int)
label t = case (helper t) of
            ST0C st -> snd (st 0)

helper (Leaf x) = do
  n <- next
  return (Leaf (x, n))

helper (Node l r) = do
  l' <- helper l
  r' <- helper r
  return (Node l' r')

-- >>> label charT
-- Node (Node (Leaf ('a',0)) (Leaf ('a',1))) (Node (Leaf ('c',2)) (Leaf ('a',3)))
--

{-
helper :: Int -> Tree a -> (Int, Tree (a, Int))
helper n (Node l r) = (n_r, Node l_new r_new)
  where 
    (n_l, l_new) = helper n     l
    (n_r, r_new) = helper n_l   r

helper n (Leaf x)   = (n + 1, Leaf (x, n)) 
-}

next :: ST0 Int
next = ST0C (\n -> (n+1, n))



keyLabel :: Tree Char -> Tree (Char, Int)
keyLabel t = snd (khelper M.empty t)

khelper :: M.Map Char Int -> Tree Char -> (M.Map Char Int, Tree (Char, Int))
khelper n (Node l r) = (n_r, Node l_new r_new)
  where 
    (n_l, l_new) = khelper n     l
    (n_r, r_new) = khelper n_l   r

khelper m (Leaf c)   = (m', Leaf (c, l)) 
  where
    m' = M.insert c (l+1) m
    l  = M.findWithDefault 0 c m

-- >>> keyLabel charT
-- Node (Node (Leaf ('a',0)) (Leaf ('a',1))) (Node (Leaf ('c',0)) (Leaf ('a',2)))
--










-- >>> charT
-- Node (Node (Leaf 'a') (Leaf 'b')) (Node (Leaf 'c') (Leaf 'a'))
--

-- >>> helper 0 (Node (Leaf 'a') (Leaf 'b'))
-- (2, Node (Leaf ('a',0)) (Leaf ('b',1)))
-- >>> helper 2 (Node (Leaf 'c') (Leaf 'a'))
-- (4,Node (Leaf ('c',2)) (Leaf ('a',3)))
--
-- >>> helper 0 charT
-- (4,Node (Node (Leaf ('a',0)) (Leaf ('b',1))) (Node (Leaf ('c',2)) (Leaf ('a',3))))
--


-- >>> label charT 
-- Node 
--   (Node (Leaf ('a',0)) (Leaf ('b',1))) 
--   (Node (Leaf ('c',2)) (Leaf ('a',3)))
--

type State = Int 

data ST0 a = ST0C (State -> (State, a)) 
  deriving (Functor)

evalState :: ST0 a -> State -> a 
evalState (ST0C f) s = val
  where 
    (newState, val) = (f s)

returnST :: a -> ST0 a
returnST v = ST0C (\s -> (s, v)) 

bindST :: ST0 a -> (a -> ST0 b) -> ST0 b
bindST sta f 
  = ST0C (\s -> let (s1, a)  = runState sta s 
                    stb      = f a 
                    (s2, b)  = runState stb s1  
                in
                    (s2, b)
         )

runState :: ST0 a -> State -> (State, a)
runState (ST0C f) s = f s

instance Monad ST0 where
  return = returnST
  (>>=)  = bindST


st :: ST0 [Int]
st = ST0C (\n -> (n+3, [n, (n+1), (n+2)]))
             -- n   = old-state :: Int
             -- n+3 = new-state :: Int
             -- [...] = value-being-returned :: [Int]


st1 :: ST0 [String]
st1 = ST0C (\n -> (n+3, [show n, show (n+1), show (n+2)]))
             -- n   = old-state :: Int
             -- n+3 = new-state :: Int
             -- [show...] = value-being-returned :: [String]

-- >>> quiz
-- [100,101,102]
--

quiz = evalState st 100


-- >>> evalState (ST0C (\n -> (n+3, [n, (n+1), (n+2)]))) 100
-- (val) where (newState, val) = (103, [100, 101, 102])
-- ===> [100, 101, 102]





























-- >>> charT
-- Node (Node (Leaf 'a') (Leaf 'b')) (Node (Leaf 'c') (Leaf 'a'))
--
{- 


data ST s a = STC (s -> (s, a)) 
  deriving (Functor)

get :: ST s s
get = STC (\s -> (s, s))

put :: s -> ST s ()
put s = STC (\_ -> (s, ()))

instance Monad (ST s) where
  return x = STC (\s -> (s, x))
  st >>= f = STC (\s -> let (s', x) = runState st s 
                        in runState (f x) s')

runState :: ST s a -> s -> (s, a)
runState (STC f) s = f s

evalState :: ST s a -> s -> a
evalState st s = snd (runState st s) 

charNext :: Char -> ST (M.Map Char Int) Int
charNext c = do
  m    <- get                     -- get current freq-map
  let n = M.findWithDefault 0 c m  -- current freq for c (or 0)
  put (M.insert c (n+1) m)        -- update freq for c
  return n                        -- return current as valu

type MapST a = ST (M.Map Char Int)  a 

keyHelperS :: Tree Char -> MapST (Tree (Char, Int))
keyHelperS (Leaf c) = do 
    n <- charNext c
    return (Leaf (c, n))

keyHelperS (Node l r) = do
    l' <- keyHelperS l
    r' <- keyHelperS r
    return (Node l' r')

keyLabelS :: Tree Char -> Tree (Char, Int)
keyLabelS t = evalState (keyHelperS t) M.empty 

instance Applicative (ST s) where
  pure  = undefined
  (<*>) = undefined
-}

instance Applicative ST0 where
  -- pure  = undefined
  -- (<*>) = undefined

