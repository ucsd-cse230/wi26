{-# LANGUAGE DeriveFunctor #-}

module Lec_5_20_20 where

import qualified Data.Map as M

--------------------------------------------------------
--- type State = Int 

-- "ST0" means "State-Transformer" that returns 'a'
data ST s a = ST0C (s -> (s, a)) 
  deriving (Functor)

get :: ST s s
get = ST0C (\s -> (s, s))

put :: s -> ST s () 
put newState = ST0C (\_ -> (newState, ()))

type ST0 = ST Int

runState :: ST s a -> s -> (s, a)
runState (ST0C f) s = f s

evalState :: ST s a -> s -> a 
evalState st s      = val
  where 
    (newState, val) = runState st s

--------------------------------------------------------
instance Monad (ST s) where
  -- return :: a -> ST0 a
  return val = ST0C (\s -> (s, val)) 

  -- (>>=) :: ST0 a -> (a -> ST0 b) -> ST0 b
  (>>=) sta f = ST0C (\s -> 
                       let (s', va)  = runState sta s 
                           stb       = f va
                           (s'', vb) = runState stb s'
                       in 
                           (s'', vb)
                     )

--------------------------------------------------------

nextq :: ST0 Int
-- nextq = ST0C (\n -> (n+1, n * 1000))
nextq = do
  n <- get
  put (n + 1)
  return n



wtf1 = do 
  n <- nextq      -- n := 1
  return [n]      -- return [1000] 

-- >>> evalState wtf1 1
-- [1000]

wtf2 :: ST0 [Int]
wtf2 = nextq  >>= \n0 ->              -- n0 = 1000
         nextq >>= \n1 ->             -- n1 = 2000
           nextq >>= \n2 ->           -- n2 = 3000
             return [n0, n1, n2]      -- [1000, 2000, 3000]

-- >>> evalState wtf2 13
-- [13000,14000,15000]
--

wtf3 :: ST0 [Int]
wtf3 = do 
  n0 <- nextq               
  n1 <- nextq             
  n2 <- nextq             
  return [n0,n1,n2]

-- >>> runState wtf3 4
-- (4,[1000,2000,3000])

-------------------------------------------------------------------------------
wtf4 :: ST0 [Int]
wtf4 = do                 
                          -- s  := 1
  xs <- wtf3              -- xs := [1000, 2000, 3000]
                          -- s' := 4
  ys <- wtf3              -- ys := [4000,5000,6000]
                          -- s'' := 7 
  return (xs ++ ys)

-- >>> runState wtf4 1
-- (7,[1000,2000,3000,4000,5000,6000])
--

{- 
  A. [1000, 2000, 3000]
  B. [1000, 2000, 3000, 1000, 2000, 3000]
  C. [1000, 2000, 3000, 4000, 5000, 6000]
  D. [4000, 5000, 6000, 4000, 5000, 6000]
  E. [4000, 5000, 6000]
 -}















-------------------------------------------------------------------------------
data Tree a
    = Leaf a
    | Node (Tree a) (Tree a)
    deriving (Eq, Show)

charT :: Tree Char
charT = Node                    
            (Node 
                (Leaf 'a')      
                (Leaf 'a'))     

            (Node 
                (Leaf 'c') 
                (Leaf 'a'))


-------------------------------------------------------------------------------
-- >>> label charT
-- Node (Node (Leaf ('a',1)) (Leaf ('a',2))) (Node (Leaf ('c',3)) (Leaf ('a',4)))
--

label :: Tree a -> Tree (a, Int)
label t = evalState (helper t) 5000 

helper :: Tree a -> ST0 (Tree (a, Int))
helper (Leaf x)   = do { n <- next; return (Leaf (x, n)) }
helper (Node l r) = do { l' <- helper l; r' <- helper r; return (Node l' r') } 


-- next :: ST0 Int
-- next = ST0C (\n -> (n+1, n * 1000))









labelS :: Tree a -> Tree (a, Int)
labelS t = evalState (helperS t) 1

helperS :: Tree a -> ST0 (Tree (a, Int))
helperS (Leaf x) = do
  n <- next
  return (Leaf (x, n))

helperS (Node l r) = do
  l' <- helperS l
  r' <- helperS r
  return (Node l' r')

next :: ST0 Int
next = ST0C (\n -> (n+1, n))

-------------------------------------------------------------------------------
-- >>> keyLabel charT 
-- Node (Node (Leaf ('a',0)) (Leaf ('a',1))) (Node (Leaf ('c',0)) (Leaf ('a',2)))
--

keyLabel :: Tree Char -> Tree (Char, Int)
keyLabel t = snd (khelper M.empty t)

khelper :: M.Map Char Int -> Tree Char -> (M.Map Char Int, Tree (Char, Int))
khelper n (Node l r) = (n_r, Node l_new r_new)
  where 
    (n_l, l_new) = khelper n     l
    (n_r, r_new) = khelper n_l   r

khelper m (Leaf c)   = (m', Leaf (c, l)) 
  where
    (m', l)          = nextKey c m

nextKey :: Char -> M.Map Char Int -> (M.Map Char Int, Int) 
nextKey c m = (m', l)
  where
    m'      = M.insert c (l+1) m
    l       = M.findWithDefault 0 c m


-- >>> labelK charT
-- Node (Node (Leaf ('a',0)) (Leaf ('a',1))) (Node (Leaf ('c',0)) (Leaf ('a',2)))

-- >>> runState (helperK charT) M.empty
-- (fromList [('a',3),('c',1)],Node (Node (Leaf ('a',0)) (Leaf ('a',1))) (Node (Leaf ('c',0)) (Leaf ('a',2))))
--

-- Functor m => Applicative m => Monad m 
-- Eq a => Ord a

fMap :: (Monad m) => (a -> b) -> m a -> m b
fMap f ma = do
  x <- ma
  return (f x)

labelK t = evalState (helperK t) M.empty 

type STM = ST (M.Map Char Int)

helperK :: Tree Char -> STM (Tree (Char, Int))
helperK (Leaf c) = do
  n <- nextK c 
  return (Leaf (c, n))

helperK (Node l r) = do
  l' <- helperK l
  r' <- helperK r
  return (Node l' r')

nextK :: Char -> ST (M.Map Char Int) Int
-- nextK c = ST0C (\m -> 
--                   let 
--                     l  = M.findWithDefault 0 c m 
--                     m' = M.insert c (l+1) m
--                   in
--                     (m', l)
--                )  

nextK c = do
  m <- get
  let l = M.findWithDefault 0 c m 
  put (M.insert c (l+1) m)
  return l 

-- >>> keyLabel charT
-- Node (Node (Leaf ('a',0)) (Leaf ('a',1))) (Node (Leaf ('c',0)) (Leaf ('a',2)))
--




























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

instance Applicative (ST s) where
  -- pure  = undefined
  -- (<*>) = undefined

