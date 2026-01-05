{-# LANGUAGE InstanceSigs #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE UndecidableInstances #-}
{-# OPTIONS_GHC -Wno-unrecognised-pragmas #-}
{-# HLINT ignore "Use camelCase" #-}
{-# HLINT ignore "Replace case with maybe" #-}
{-# HLINT ignore "Use list comprehension" #-}
{-# HLINT ignore "Use newtype instead of data" #-}
{-# HLINT ignore "Use foldr" #-}
{-# OPTIONS_GHC -Wno-noncanonical-monad-instances #-}
{-# HLINT ignore "Use tuple-section" #-}
{-# HLINT ignore "Redundant return" #-}
{-# HLINT ignore "Use const" #-}
module Lec_11_7_23 where
import qualified Data.Map as M

data Expr
  = Nbr Int            -- ^ 0,1,2,3,4
  | Add Expr Expr      -- ^ e1 + e2
  | Sub Expr Expr      -- ^ e1 - e2
  | Div Expr Expr      -- ^ e1 / e2
  | Neg Expr           -- ^ - e
  | Ite Expr Expr Expr -- ^ if e1 != 0 then e2 else e3
  deriving (Show)

-- >>> eval (Nbr 100)
-- Ok 100

-- >>>  eval (Div (Nbr 100) (Sub (Add (Nbr 2) (Nbr 3)) (Nbr 5)))
-- Err "Sub (Add (Nbr 2) (Nbr 3)) (Nbr 5)"

eval0 :: Expr -> Int
eval0 = go
  where
   go (Nbr n)     = n
   go (Neg e)     = - (go e)
   go (Add e1 e2) = go e1 + go e2
   go (Sub e1 e2) = go e1 - go e2
   go (Div e1 e2) = go e1 `div` go e2
   go (Ite e1 e2 e3) = if go e1 /= 0 then go e2 else go e3

data Option v   = None | Some v deriving (Show {- , Functor -})

data Result e v = Err e | Ok v deriving (Show )

instance Functor (Result e) where
    fmap _ (Err e) = Err e
    fmap f (Ok x)  = Ok (f x)

instance Applicative (Result e) where

instance Monad (Result e) where
  (>>=) = bindResult

  return :: a -> Result e a
  return x = Ok x


bindResult :: Result e a -> (a -> Result e b) -> Result e b
bindResult arg1 doStuff =
    case arg1 of
        Err e ->  Err e
        Ok v1 -> doStuff v1

bindMaybe :: Maybe a -> (a -> Maybe b) -> Maybe b
bindMaybe arg1 doStuff =
    case arg1 of
        Nothing -> Nothing
        Just v1 -> doStuff v1



bindOption :: Option a -> (a -> Option b) -> Option b
bindOption arg1 doStuff =
    case arg1 of
        None -> None
        Some v1 -> doStuff v1


instance Functor Option where
    fmap _ None     = None
    fmap f (Some x) = Some (f x)

map2 :: (a1 -> a2 -> b) -> Option a1 -> Option a2 -> Option b
map2 f (Some v1) (Some v2) = Some (f v1 v2)
map2 _ _         _         = None

instance Applicative Option where

instance Monad Option where
    (>>=) = bindOption

    return :: a -> Option a
    return x = Some x
{-

    e1 >>= \x ->
        e2


IS THE SAME AS ...

    do x <- e1
       e2



class Monad m where
    (>>=) :: m a -> (a -> m b) -> m b
    return :: a -> m a

do { x <- e1; e2 }

e1 >>= \x -> e2

-}

evalE :: Expr -> Result String Int
evalE = go
  where
   go (Nbr n)     = return n
   go (Neg e)     = do { v <- go e; return (negate v) }
   go (Add e1 e2) = do { v1 <- go e1; v2 <- go e2 ; return(v1 + v2) }
   go (Sub e1 e2) = do { v1 <- go e1; v2 <- go e2 ; return (v1 - v2) }
   go (Div e1 e2) = do { v1 <- go e1; v2 <- go e2 ;  if v2 == 0 then Err (show e2) else return (v1 `div` v2) }
   go (Ite e1 e2 e3) = do { v1 <- go e1; if v1 /= 0 then go e2 else go e3 }


eval1 :: Expr -> Option Int
eval1 = go
  where
   go (Nbr n)     = return n
   go (Neg e)     = do { v <- go e; return (negate v) }
   go (Add e1 e2) = do { v1 <- go e1; v2 <- go e2 ; return(v1 + v2) }
   go (Sub e1 e2) = do { v1 <- go e1; v2 <- go e2 ; return (v1 - v2) }
   go (Div e1 e2) = do { v1 <- go e1; v2 <- go e2 ;  if v2 == 0 then None else return (v1 `div` v2) }
   go (Ite e1 e2 e3) = do { v1 <- go e1; if v1 /= 0 then go e2 else go e3 }

-- eval :: Expr -> Result String Int

eval :: Expr -> Result String Int
eval = go
  where
   go (Nbr n)     = return n
   go (Neg e)     = do { v <- go e; return (negate v) }
   go (Add e1 e2) = do { v1 <- go e1; v2 <- go e2 ; return(v1 + v2) }
   go (Sub e1 e2) = do { v1 <- go e1; v2 <- go e2 ; return (v1 - v2) }
   go (Div e1 e2) = do { v1 <- go e1; v2 <- go e2 ;  if v2 == 0 then throw (show e2) else return (v1 `div` v2) }
   go (Ite e1 e2 e3) = do { v1 <- go e1; if v1 /= 0 then go e2 else go e3 }

throw :: e -> Result e v
throw e = Err e



ex0 :: Expr
ex0 = Nbr 0


{-

data Option   a = None    | Some a
data Maybe    a = Nothing | Just a
data Result e a = Err e   | Ok a
data List     a = Nil     | Cons a (List a)
-}

returnList :: a -> [a]
returnList x = [x]

bindList :: [a] -> (a -> [b]) -> [b]
bindList     [] _ = []
bindList (x:xs) f = f x ++ bindList xs f

{-
instance Monad [] where
   return = returnList
   (>>=) = bindList

[x1,x2,x3] >>= f    ===>    f x1 ++ f x2 ++ f x3


-}


quiz1 :: [(String, Integer)]
quiz1 = do
    x <- ["cat", "dog"]
    y <- [0, 1]
    return (x, y)

quiz1' :: [(String, Integer)]
quiz1' = ["cat", "dog"] >>= \x ->
            [0, 1] >>= \y -> return (x, y)

{-
[0, 1] >>= (\y -> return (x, y))
    ==> (\y -> return (x, y)) 0 ++ (\y -> return (x, y)) 1
    ==> (return (x, 0))  ++ (return (x, 1))
    ==> [(x, 0)]  ++ [(x, 1)]
    ==> [(x, 0), (x, 1)]

["cat", "dog"] >>= \x ->
            [0, 1] >>= \y -> return (x, y)
===>

["cat", "dog"] >>= (\x -> [(x, 0), (x, 1)])
===> \x -> [(x, 0), (x, 1)]) "cat" ++ (\x -> [(x, 0), (x, 1)]) "dog"
===> [("cat", 0), ("cat", 1)]) ++ ( [("dog", 0), ("dog", 1)])
===> [("cat", 0), ("cat", 1), ("dog", 0), ("dog", 1)]



[0, 1] >>= f ==> f 0 ++ f 1
["cat", "dog"] >>= f    ==> f "cat" ++ f "dog"
-}


foo :: Monad m => (t -> b) -> m t -> m b
foo f xs = do
    x <- xs
    return (f x)

-- >>> foo (\n -> n * n) (Ok 10)
-- Ok 100

-- >>> triples
-- [[],[],[],[],[],[],[],[]]

-- >>> [0..5]
-- [0,1,2,3,4,5]

-- >>> pyTriples 100
-- [(3,4,5),(5,12,13),(6,8,10),(7,24,25),(8,15,17),(9,12,15),(9,40,41),(10,24,26),(11,60,61),(12,16,20),(12,35,37),(13,84,85),(14,48,50),(15,20,25),(15,36,39),(16,30,34),(16,63,65),(18,24,30),(18,80,82),(20,21,29),(20,48,52),(21,28,35),(21,72,75),(24,32,40),(24,45,51),(24,70,74),(25,60,65),(27,36,45),(28,45,53),(28,96,100),(30,40,50),(30,72,78),(32,60,68),(33,44,55),(33,56,65),(35,84,91),(36,48,60),(36,77,85),(39,52,65),(39,80,89),(40,42,58),(40,75,85),(42,56,70),(45,60,75),(48,55,73),(48,64,80),(51,68,85),(54,72,90),(57,76,95),(60,63,87),(60,80,100),(65,72,97)]

pyTriples :: Int -> [(Int, Int, Int)]
pyTriples n = do
    x <- [1..n]
    y <- [x+1..n]
    z <- [y+1..n]
    if x*x + y*y == z * z
        then [(x, y, z)]
        else []


triples :: [[a]]
triples = do
    x <- [0, 1]
    y <- [10, 11]
    z <- [100, 101]
    return []

-- >>> bits 1
-- []

bits :: Int -> [String]
bits 0 = [""]
bits n = do
    str <- bits (n-1)
    x   <- ['0', '1']
    return (x : str)

{-
bits 0
==> [""]

bits 1
==> do
      str <-  [""]
      x   <- ['0', '1']
      [x : str]

==> [""] >>= \str ->
        (['0', '1'] >>= \x -> [x:str])

==> [""] >>= \str -> (['0':str, '1':str])


==> []

do {z <- [] ; e }

==> [] >>= \z -> e

==> []

(['0', '1'] >>= \x -> [x:str])  ===>  ['0':str, '1':str]

-}








data Tree a
  = Leaf a
  | Node (Tree a) (Tree a)
  deriving (Show)

charT :: Tree Char
charT = Node
            (Node (Leaf 'a') (Leaf 'b'))
            (Node (Leaf 'b') (Leaf 'a'))


-- >>> labelm charT
-- Node (Node (Leaf ('a',0)) (Leaf ('b',1))) (Node (Leaf ('b',1)) (Leaf ('a',0)))

label ::  Tree a -> Tree (a, Int)
label t = t'
  where
   (_, t') = helper t 0
   helper :: Tree a -> Int -> (Int, Tree (a, Int))
   helper (Leaf x)   n = (n+1, Leaf (x, n))
   helper (Node l r) n = (n'', Node l' r')
     where
       (n', l')  = helper l n
       (n'', r') = helper r n'

{-
data Map k v

    empty :: Map k v
    insert :: k -> v -> Map k v -> Map k v
    findWithDefault :: v -> k -> Map k v -> v

-}

-- >>> labelm charT
-- Node (Node (Leaf ('a',0)) (Leaf ('b',1))) (Node (Leaf ('b',1)) (Leaf ('a',0)))


labelm :: (Ord a) => Tree a -> Tree (a, Int)
labelm t = evalST M.empty (helper t)
  where
   helper (Leaf x)   = do n <- nextLabel x
                          return (Leaf (x, n))
   helper (Node l r) = do l' <- helper l
                          r' <- helper r
                          return (Node l' r')



nextLabel :: Ord p => p -> ST (M.Map p Int) Int
nextLabel x = do
  m <- get
  let v = M.findWithDefault (M.size m) x m
  put (M.insert x v m)
  return v





{-
        Int -> (Int, thingIcareAbout)
        Map Char Int -> (Map Char Int, thingIcareAbout)

-}

type State = Int -- can change to other stuff

data ST s a = MkST (s -> (s, a))

instance Functor (ST s) where
  fmap :: (a -> b) -> ST s a -> ST s b
  fmap f (MkST st) = MkST (\inputState ->
    let (outputState, aVal) = st inputState in
    (outputState, f aVal)
    )


-- >>> evalST 100 next
-- "100"

{-
aVal where (_, aval) = f 100
           f = (\n -> (n + 1, show n))

==>

aVal where (_, aval) = (\n -> (n + 1, show n) 100

==>

aVal where (_, aval) = (101, show 100)

==>

"100"


-}









instance Applicative (ST s) where

instance Monad (ST s) where
  return :: a -> ST s a
  return aVal = MkST (\inputState -> (inputState, aVal))

  (>>=) :: ST s a -> (a -> ST s b) -> ST s b
  (>>=) (MkST sta) doStuff = MkST (\inputState ->
    let (someState, aVal)  = sta inputState
        MkST blob          = doStuff aVal
        (outputState, bVal) = blob someState
    in
        (outputState, bVal))


-- >>> evalST 100 next
-- "100"

-- >>> evalST 100 wtf1
-- "100"

-- >>> evalST 0 wtf2
-- "3"

wtf2 = do _ <- next
          _ <- next
          _ <- next
          v4 <- next
          return v4

{-
        e >>= \x -> return x          THE SAME AS       e

        e1 >>= \x -> e2

IS THE SAME AS

        do  x <- e1
            e2

e1 >>= \x1 ->
    e2 >>= \x2 ->
        e3 >>= \x3 ->
            BLAH

do x1 <- e1
   x2 <- e2
   x3 <- e3
   BLAH



 -}

get :: ST s s
get = MkST (\inputState -> (inputState, inputState))

put :: s -> ST s ()
put newState = MkST (\_ -> (newState, ()))


evalST :: s -> ST s a -> a
evalST s (MkST f) = aVal where (_, aVal) = f s

type STI = ST Int

next :: STI String
-- next = MkST (\n -> (n + 1, show n))
next = do
    n <- get
    put (n+1)
    return (show n)

nextInt :: STI Int
nextInt = MkST (\n -> (n + 1, n))

wtf1 :: STI String
wtf1 = next >>= \n -> return n
{-


-}
    {-
        sta    :: State -> (State, a)
        aToSTb :: a -> ST b
        inputState :: State


        bVal :: b
        outputState :: State
    -}



--     -- return :: a -> ST a
--     -- (>>=)  :: ST a -> (a -> ST b) -> ST b

-- >>> label' charT
-- Node (Node (Leaf ('a',0)) (Leaf ('b',1))) (Node (Leaf ('b',2)) (Leaf ('a',3)))

label' ::  Tree a -> Tree (a, Int)
label' t = evalST 0 (helper t)
  where
   helper (Leaf x)   = do n <- nextInt
                          return (Leaf (x, n))
   helper (Node l r) = do l' <- helper l
                          r' <- helper r
                          return (Node l' r')




-- >>> take 40 (funny 0)
-- [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39]

myfoldl :: (a -> b -> a) -> a -> [b] -> a
myfoldl _ b []     = b
myfoldl f b (x:xs) = myfoldl f (f b x) xs

{-

my (+) 0 [x1,x2,x3,x4]
==> my (+) (0 + x1) [x2, x3, x4]
==> my (+) ((0 + x1)+x2) [x3, x4]
==> my (+) (((0 + x1) + x2) + x3) [x4]
==> my (+) ((((0 + x1) + x2) + x3) + x4) []


my (+) 0 [x1,x2,x3,x4]
==> my (+) (x1) [x2, x3, x4]
==> my (+) ((0 + x1)+x2) [x3, x4]
==> my (+) (((0 + x1) + x2) + x3) [x4]
==> my (+) ((((0 + x1) + x2) + x3) + x4) []

my (+) 0 [x1,x2,x3,x4]
==> x1 + (my (+) 0 [x2, x3, x4])
==> x1 + (x2 + my (+) 0 [x3, x4])
==> x1 + (x2 + (x3 + my (+) 0 [x4])
==> x1 + (x2 + (x3 + (x4 + my (+) 0 [])))
==> x1 + (x2 + (x3 + (x4 + 0)))



-}

myfoldr :: (a -> b -> b) -> b -> [a] -> b
myfoldr _ b []     = b
myfoldr f b (x:xs) = f x (myfoldr f b xs)


funny n = n : funny (n+1)

{-

myFoldl (+) 0 [x1,x2,x3,x4,x5]

-}
