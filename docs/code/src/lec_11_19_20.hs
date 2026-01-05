{-# LANGUAGE DeriveFunctor #-}
{-# LANGUAGE FlexibleInstances #-}

module Lec_11_19_20 where

-- import Prelude hiding (return, (>>=))
import qualified Data.Map as M

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
                (Leaf 'a') 
                (Leaf 'a'))

-- >>> labelT charT 
-- Node (Node (Leaf ('a',1000)) (Leaf ('b',1001))) (Node (Leaf ('a',1002)) (Leaf ('a',1003)))



labelT :: Tree a -> Tree (a, Int)
labelT t = evalState 1000 (helperT t)

helperT :: Tree a -> ST Int (Tree (a, Int))
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
-- Node (Node (Leaf ('a',0)) (Leaf ('b',0))) (Node (Leaf ('a',1)) (Leaf ('a',2)))


label :: Tree a -> Tree (a, Int)
label t = snd (helper 0 t)

keyLabel :: Tree Char -> Tree (Char, Int)
keyLabel t = evalState M.empty (keyHelperT t)

keyHelperT :: Tree Char -> STM (Tree (Char, Int))
keyHelperT (Leaf x) = do 
 n <- countLabel x 
 return (Leaf (x, n))

keyHelperT (Node l r) = do 
  l' <- keyHelperT l 
  r' <- keyHelperT r 
  return (Node l' r')

----
type State = Int

-- type State = M.Map Char Int

count :: ST Int Int
count = do 
  n <- get 
  set (n+1)
  return n

type STM = ST (M.Map Char Int)

countLabel ::  Char -> STM Int
countLabel x = do
  m <- get
  let n = M.findWithDefault 0 x m
  set (M.insert x (n + 1) m) 
  return n

type STMap = ST (M.Map Char Int)
data ST s a = STC (s -> (s, a))

type IntList = List Int
type BoolList = List Bool
data List a = Nil | Cons a (List a)

-----------------
get :: ST s s
get = STC (\s -> (s, s))

set :: s -> ST s ()
set s = STC (\_ -> (s, ()))




-----------------




returnST :: a -> ST s a
returnST v = STC (\s -> (s, v))

bindST :: ST s a -> (a -> ST s b) -> ST s b
bindST (STC sta) f_stb = STC (\s -> 
  let (s', va) = sta s
      STC stb  = f_stb va
      (s'', vb) = stb s'
  in
      (s'', vb)
  )

instance Monad (ST s) where
  return = returnST
  (>>=)  = bindST

evalState :: s -> ST s a -> a
evalState s (STC f) = snd (f s)


next :: ST Int String
next = STC (\s -> (s+1, show s))

wtf1 :: ST Int String
wtf1 = next >>= (\n -> return n) 

-- >>> evalState 100 wtf2
-- ["100","101","102"]

next3 :: ST Int [String]
next3 = next >>= (\n1 -> 
         next >>= (\n2 ->
           next >>= (\n3 -> 
            return [n1, n2, n3] 
           ) 
         )
       )

next3' = do
  n1 <- next
  n2 <- next
  n3 <- next
  return [n1, n2, n3]


-- >>> evalState 0 next6'
-- ["0","1","2","3","4","5"]

next6 :: ST Int [String]
next6 = next3 >>= \ns_1_2_3 -> 
          next3 >>= \ns_4_5_6 -> 
            return (ns_1_2_3 ++ ns_4_5_6)

next6' :: ST Int [String]
next6' = do
  ns_1_2_3 <- next3
  ns_4_5_6 <- next3
  return (ns_1_2_3 ++ ns_4_5_6)



wtf2' = do
  n1 <- next
  n2 <- next
  return [n1, n2]
-- >>> evalState 100 wtf2'
-- ["100","101"]




-- >>> evalState 100 wtf1
-- 5000


instance Functor (ST s) where
instance Applicative (ST s) where

------------------------------------------------

data Parser a = P (String -> [(a, String)])

runParser :: Parser a -> String -> [(a, String)]
runParser (P fn) str = fn str

oneChar :: Parser Char
oneChar = P (\cs -> case cs of
                      [] -> [] 
                      cs -> [(head cs, tail cs)])

-- >>> runParser oneChar ""
-- []
