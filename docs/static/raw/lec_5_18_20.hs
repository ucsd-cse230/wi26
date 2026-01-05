{-# LANGUAGE DeriveFunctor #-}

module Lec_5_18_20 where

import qualified Data.Map as M


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
-- Node (Node (Leaf ('a',0)) (Leaf ('a',1))) (Node (Leaf ('c',2)) (Leaf ('a',3)))
--

label :: Tree a -> Tree (a, Int)
label t = snd (helper t 0)

helper :: Tree a -> Int -> (Int, Tree (a, Int))
helper (Node l r) n = (n_r, Node l_new r_new)
  where 
    (n_l, l_new) = helper l n     
    (n_r, r_new) = helper r n_l   

helper (Leaf x) n = (n + 1, Leaf (x, n)) 












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


--------------------------------------------------------

type State = Int 

-- "ST0" means "State-Transformer" that returns 'a'
data ST0 a = ST0C (State -> (State, a)) 
  deriving (Functor)






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


--------------------------------------------------------

runState :: ST0 a -> State -> (State, a)
runState (ST0C f) s = f s

evalState :: ST0 a -> State -> a 
evalState st s      = val
  where 
    (newState, val) = runState st s

nextq :: ST0 Int
nextq = ST0C (\n -> (n+1, n * 1000))

wtf1 = do n <- nextq      -- n := 1
          return [n]      -- return [1000] 

-- >>> evalState wtf1 1
-- [1000]
--

nextS :: ST0 String
nextS = ST0C (\s -> (s+1, show s))

quizS = evalState (next >>= (\n -> return [n])) 1

wtf2 :: ST0 [Int]
wtf2 = nextq  >>= \n0 ->
         nextq >>= \n1 -> 
           nextq >>= \n2 -> 
             return [n0, n1, n2]


-- >>> evalState wtf2 1
-- [1000,2000,3000]
--

{- 
wtf2 = nextq >>= \n0 ->
          nextq >>= \n1 -> 
            nextq >>= \n2 -> 
                return [n0, n1, n2]

wtf = do 
  n0 <- nextq
  n1 <- nextq
  n2 <- nextq
  return [n0, n1, n2]


e1 >>= \x -> 
  e2

do x <- e1
   e2

-}


-- >>> quiz2
-- [1000,1001,666,1003,1004]
--

quiz2 = evalState wtf2 1000

{-  

A. [100]

B. [101]

C. [102]

D. [103]

D. [104]

-}





-- >>> quiz1 
-- (101, [100])
--



quiz1 = runState wtf1 100 














-- >>> quiz0
-- [100]

-- >>> runState nextq 100 
-- (101,[100])
--

quiz0 = evalState (returnST 0) 100 

{- 

evalState  100 

==> evalState (ST0C (\s -> (s, 0))) 100 

==> snd ((\s -> (s, 0)) 100)

==> snd (100, 0)

==> 0


A. 100          <<

B. 101

C. 0            << 

D. 1

E. (101, 100)   << 

-}



----------------------------------------------------------

returnST :: a -> ST0 a
returnST val = ST0C (\s -> (s, val)) 












-- (>>=) :: m a -> (a -> m b) -> m b
-- m := ST0


-- sta >>= f
bindST :: ST0 a -> (a -> ST0 b) -> ST0 b
bindST sta f = ST0C (\s -> 
                       let (s', va)  = runState sta s 
                           stb       = f va
                           (s'', vb) = runState stb s'
                       in 
                           (s'', vb)
                    )




instance Monad ST0 where
  return = returnST
  (>>=)  = bindST

----------------------------------------------------------

























-- >>> quiz
-- [100,101,102]
--

quiz = evalState st 100


-- >>> evalState (ST0C (\n -> (n+3, [n, (n+1), (n+2)]))) 100
-- (val) where (newState, val) = (103, [100, 101, 102])
-- ===> [100, 101, 102]




-------------------------------------------------------------------------------
-- >>> labelS charT
-- Node (Node (Leaf ('a',0)) (Leaf ('a',1))) (Node (Leaf ('c',2)) (Leaf ('a',3)))
--

labelS :: Tree a -> Tree (a, Int)
labelS t = case (helperS t) of
            ST0C st -> snd (st 0)

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
    m' = M.insert c (l+1) m
    l  = M.findWithDefault 0 c m

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

instance Applicative ST0 where
  -- pure  = undefined
  -- (<*>) = undefined

