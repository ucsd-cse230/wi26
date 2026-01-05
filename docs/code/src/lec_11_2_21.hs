{-# LANGUAGE DeriveFunctor #-}

module Lec_11_2_21 where

import Data.Map
data Tree a = Leaf a | Node (Tree a) (Tree a)
  deriving (Show, Functor)

tree0 :: Tree Char
tree0 = 
  Node 
    (Node 
      (Leaf 'a') 
      (Leaf 'b')) 
    (Node 
      (Leaf 'c') 
      (Leaf 'a'))

treeLabelled :: Tree (Char, Int)
treeLabelled = 
  Node 
    (Node 
      (Leaf ('a',0)) 
      (Leaf ('b',0))) 
    (Node 
      (Leaf ('b',1)) 
      (Leaf ('a',1)))

-- >>> label tree0


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
-- Node (Node (Leaf ('a',10000)) (Leaf ('b',10001))) (Node (Leaf ('c',10002)) (Leaf ('a',10003)))

-- >>> evalstate empty (workerChar tree0)
-- (Node (Node (Leaf ('a',0)) (Leaf ('b',0))) (Node (Leaf ('c',0)) (Leaf ('a',1))),fromList [('a',2),('b',1),('c',1)])

-- No instance for (Show (STMap (Tree (Char, Int))))
--   arising from a use of ‘ghcideCustomShow’
-- There are instances for similar types:
--   instance Show (ST s a) -- Defined in ‘GHC.ST’

labelM :: Tree a -> Tree (a, Int)
labelM t = fst (evalstate 10000 (workerM t))

{- What is the type of `tickInt` 
(A) Int
(B) String -> Int
(C) String -> ST Int
(D) ST Int
(E) ST String
-}

-- e1 >>= \x -> e2              do {x <- e1; e2 }
workerM :: Tree a -> ST Int (Tree (a, Int))
workerM (Leaf v) = do 
  n <- tickInt
  return (Leaf (v, n))

workerM (Node l r) = do 
  l' <- workerM l
  r' <- workerM r
  return (Node l' r')

type STMap a = ST (Map Char Int) a

workerChar :: Tree Char -> STMap (Tree (Char, Int))
workerChar (Leaf c) = do 
  n <- tickChar c
  return (Leaf (c, n))

workerChar (Node l r) = do 
  l' <- workerChar l
  r' <- workerChar r
  return (Node l' r')

tickChar :: Char -> STMap Int
tickChar c = do
  mapp <- get
  let n = findWithDefault 0 c mapp 
  put  (insert c (n+1) mapp)
  return n

-- | Like the synonyms described above
get :: ST s s 
get = STC (\s -> (s, s)) 

put :: s -> ST s () 
put s = STC (\_ -> ((), s)) 

runState  :: ST s a -> s -> (a, s)
runState (STC sta) s = sta s

evalState' :: ST s a -> s -> a
evalState' st s = fst (runState st s)


type State = Int

newtype ST s a = STC (s -> (a, s))

instance Functor (ST s) where
  fmap = fmapST 

fmapST :: (a -> b) -> ST s a -> ST s b
fmapST f (STC sta) = STC (\s -> let (a, s') = sta s in (f a, s')) 


instance Monad (ST s) where
    (>>=) = awesomeST
    return = returnST

type STi = ST Int

tick :: STi String
tick = fmap show tickInt

tickInt :: STi Int
tickInt = do
  n <- get
  put (n+1)
  return n



-- evalstate :: State -> ST a -> (a, State) 
evalstate :: s -> ST s a -> (a, s)
evalstate s0 (STC sta) = sta s0

-- returnST :: a -> ST a
returnST :: a -> ST s a
returnST a = STC (\s -> (a, s)) 

-- awesomeST :: ST a -> (a -> ST b) -> ST b
awesomeST :: ST s a -> (a -> ST s b) -> ST s b 
awesomeST (STC sta) a_to_stb = STC 
  (\s -> 
    let (a, s')  = sta s 
        STC stb  = a_to_stb a
        (b, s'') = stb s' 
    in
       (b, s'')
  )

-- >>> evalstate 10 st
-- ([1000,1001,1002],1003)

st :: ST Int [Int]
st = STC (\n -> ([n, n+1, n+2], n+3))



{- 

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



-}







--myMap :: (Monad t) => (a -> b) -> t a -> t b
-- myMap f ta = ta >>= \a -> return (f a)

myMap :: (t -> b) -> [t] -> [b]
myMap f ta = forEach ta (\a -> [f a])


-- myMap f [a1, a2, a3] ==> [f a1, f a2, f a3]

-- (>>=) :: m a -> (a -> m b) -> m b

-- (>>=) :: [a] -> (a -> [b]) -> [b]

forEach :: [a] -> (a -> [b]) -> [b]
forEach []     f = []
forEach (a:as) f = (f a) ++ (forEach as f)

-- >>> myMap (\n -> n * 10) [1,2,3,4,5]
-- [10,20,30,40,50]

{- 
  <$> ::    a -> b  -> t a -> t b

  <*> :: t (a -> b) -> t a -> t b

  >>= :: t a -> (a -> t b) -> t b

  1. Both INPUT   `t a`
  2. Both also INPUT `t ?`
  2. Both OUTPUT  `t b` 
  3. Both INPUT function-ish from a-ish -> b-ish 

-}




instance Applicative (ST s) where
  pure = undefined
  (<*>) = undefined

{- 


  "34 + 56"

  "34, 56, 90"

  "lakshdaskdf"

  "10 $ 6 # 9"

      (10 $ 6) # 9
      
      10 $ (6 # 9)
-}

data Parser a = MkParser (String -> [(a, String)]) 