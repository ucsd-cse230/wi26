{- HLINT ignore "Eta reduce" -}
{- HLINT ignore "Use uncurry" -}
{- HLINT ignore "Use :" -}
{- HLINT ignore "Use id" -}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE InstanceSigs #-}
{- HLINT ignore "Use >>" -}
{- HLINT ignore "Use tuple-section" -}
{- HLINT ignore "Use newtype instead of data" -}
{- HLINT ignore "Use list comprehension" -}
{- HLINT ignore "Use >=>" -}
{- HLINT ignore "Redundant return" -}
{- HLINT ignore "Avoid lambda" -}
{- HLINT ignore "Use map" -}

module Lec_2_10_26  where

-- >>> inc 50
-- 51

inc :: Int -> Int
inc x = x + 1

data Tree a
    = Leaf a
    | Node (Tree a) (Tree a)
    deriving (Show)

charTree :: Tree Char
charTree = Node
                (Node (Leaf 'a') (Leaf 'b'))
                (Node (Leaf 'c') (Leaf 'a'))

-- >>> label charTree
-- Node (Node (Leaf ('a',0)) (Leaf ('b',1))) (Node (Leaf ('c',2)) (Leaf ('a',3)))

tick :: ST Int Int
tick = MkST (\n -> (n + 1, n))

reset :: s -> ST s ()
reset k = MkST (\_ -> (k, ()))

set :: s -> ST s ()
set k = MkST (\_ -> (k, ()))

get :: ST s s
get = MkST (\s -> (s, s))

newTick :: ST Int Int
newTick = do
    n <- get
    set (n + 1)
    return n

-- >>> evalST 0 (labelST charTree)
-- Node (Node (Leaf ('a',0)) (Leaf ('b',1))) (Node (Leaf ('c',2)) (Leaf ('a',3)))

labelST :: Tree a -> ST Int (Tree (a, Int))
labelST (Leaf x) = do
    n <- newTick
    return (Leaf (x, n))

labelST (Node l r) = do
    l' <- labelST l
    r' <- labelST r
    return (Node l' r')


label :: Tree a -> Tree (a, Int)
label t = snd (helper t 0 )


helper :: Tree a -> Int -> (Int , Tree (a, Int))
helper (Leaf x)   n = ( n + 1 , Leaf (x, n) )
helper (Node l r) n =  let (n', l') = helper l n
                           (n'', r') = helper r n'
                       in
                            ( n'', Node l' r')


data ST s a = MkST (s -> (s , a))

returnST :: a -> ST s a
returnST x = MkST (\s -> (s , x) )

bindST :: ST s a -> (a -> ST s b) -> ST s b
bindST (MkST fa) f_a_stb = MkST (\s ->
    let (s', a_val) = fa s
        MkST fb     = f_a_stb a_val
    in
        fb s'
  )

next :: ST Int String
next = MkST (\n -> (n + 1, show n))

quiz :: ST Int String
quiz = next >>= (\n -> return n)

-- >>> evalST 100 quiz'
-- ["0","1","99"]

quiz' :: ST Int [String]
quiz' = next >>= \n1 ->
            next >>= \n2 ->
                next >>= \_ ->
                    next >>= \_ ->
                        reset 99 >>= \_ ->
                            next >>= \n3 ->
                                return [n1, n2, n3]

{-
e1 >>= \x -> e2

do {x <- e1; e2}

-}

{-
    next >>= \n1 ->
        next >>= \n2 ->
            next >>= \n3 ->
                return [n1, n2, n3]

-}

quiz'' :: ST Int [String]
quiz'' = do
    n1 <- next
    n2 <- next
    n3 <- next
    return [n1, n2, n3]

-- >>> evalST 1000 quiz''
-- ["1000","1001","1002"]


{-
bindST :: (ST a) -> (a -> ST b) -> ST b
next :: ST String

quiz :: ST String
quiz = (bindST next)                -- (String -> ST b) -> ST b
         (\(n :: String) -> returnST n)

-}



instance Functor (ST s) where
instance Applicative (ST s) where

instance Monad (ST s) where
    (>>=) :: ST s a -> (a -> ST s b) -> ST s b
    (>>=) = bindST
    return :: a -> ST s a
    return = returnST


-- >>> :i Monad
-- type Monad :: (* -> *) -> Constraint
-- class Applicative m => Monad m where
--   (>>=) :: m a -> (a -> m b) -> m b
--   return :: a -> m a
--




evalST :: s -> ST s a -> a
evalST s (MkST f) = snd (f s)

st0 :: ST Int [Int]
st0 = MkST (\n -> (n + 3, [n, n + 1 , n + 2, n + 3]))

-- >>> evalST 67 st0
-- [67,68,69,70]

-- >>> evalST 607 next
-- "607"

st1 :: ST Int (Int, Int, Int, Int)
st1 = MkST (\n -> (n + 3, (n, n + 1 , n + 2, n + 3) ))



{-

def label(t):
  count = 0
  helper(count, t.l)
-}
