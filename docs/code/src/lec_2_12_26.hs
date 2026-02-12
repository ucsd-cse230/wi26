{- HLINT ignore "Eta reduce" -}
{- HLINT ignore "Use uncurry" -}
{- HLINT ignore "Use :" -}
{- HLINT ignore "Use id" -}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE InstanceSigs #-}
{- HLINT ignore "Use lambda-case" -}
{- HLINT ignore "Use const" -}
{- HLINT ignore "Use >>" -}
{- HLINT ignore "Use tuple-section" -}
{- HLINT ignore "Use newtype instead of data" -}
{- HLINT ignore "Use list comprehension" -}
{- HLINT ignore "Use >=>" -}
{- HLINT ignore "Redundant return" -}
{- HLINT ignore "Avoid lambda" -}
{- HLINT ignore "Use map" -}

module Lec_2_12_26  where
import Data.Map
import Data.Maybe (fromMaybe)
import Data.Char (isDigit)

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
set newState = MkST (\oldState -> (newState, ()))

get :: ST s s
get = MkST (\s -> (s, s))

modify :: (s -> s) -> ST s s
modify f = do
    curr <- get
    set (f curr)
    return curr


newTick :: ST Int Int
newTick = modify (+ 1)





-- >>> evalST 0 (labelST charTree)
-- Node (Node (Leaf ('a',0)) (Leaf ('b',1))) (Node (Leaf ('c',2)) (Leaf ('a',3)))

labelST :: Tree a -> ST Int (Tree (a, Int))
labelST (Leaf x) = do
    n <- tick
    return (Leaf (x, n))

labelST (Node l r) = do
    l' <- labelST l
    r' <- labelST r
    return (Node l' r')

blab :: Map k v
blab = empty

-- >>> evalST empty (labelCST charTree)
-- Node (Node (Leaf ('a',0)) (Leaf ('b',0))) (Node (Leaf ('c',0)) (Leaf ('a',1)))

labelCST :: Tree Char -> ST (Map Char Int) (Tree (Char, Int))
labelCST (Leaf c) = do
    n <- tickChar c
    return (Leaf (c, n))

labelCST (Node l r) = do
    l' <- labelCST l
    r' <- labelCST r
    return (Node l' r')

tickChar :: Char -> ST (Map Char Int) Int
tickChar ch = do
    m <- get
    let curr = fromMaybe 0 (m !? ch)
    set (insert ch (curr + 1) m)
    return curr
    -- Map Char Int -> Char -> Int



{-

def foo(n:Int) -> Int :
  BODY

foo :: Int -> ST ... Int

ORM

LINQ / C# 2005

Dryad / LINQ    2010

MSR SVC obliterated --> Google 2013

Tensorflow    2014
-}

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

fluff :: ST Int String
fluff = next >>= (\n -> return n)


-- quiz'' :: ST Int [String]
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




evalST :: s -> ST s a -> a
evalST s (MkST f) = snd (f s)

st0 :: ST Int [Int]
st0 = MkST (\n -> (n + 3, [n, n + 1 , n + 2, n + 3]))

-- >>> evalST 67 st0
-- [67,68,69,70]

-- >>> evalST 607 next
-- "607"

st1 :: ST Int [Int]
st1 = MkST (\n -> (n + 3, [n, n + 1 , n + 2, n + 3] ))

blub :: Num a => a -> a -> a
blub x y = x + y


randomBlah :: (Monad m) => m String
randomBlah = do
    return "dog"

-- >>> evalST 0 randomBlah
-- "dog"

----------------------------------
{-

data Parser a = MkParser (String -> [(a, String)])
data ST s   a = MkST     (s -> (s , a))
-}

data Parser a = MkParser (String -> [(a, String)])

instance Functor Parser where
instance Applicative Parser where
instance Monad Parser where
    return = returnP
    (>>=) :: Parser a -> (a -> Parser b) -> Parser b
    (>>=) = bindP

returnP :: a -> Parser a
returnP x = MkParser (\str -> [(x, str)])


forEach :: [a] -> (a -> [b]) -> [b]
forEach xs f = concatMap f xs


bindP :: Parser a -> (a -> Parser b) -> Parser b
bindP (MkParser pa) f_pb = MkParser (\str ->
    forEach (pa str) (\(a, str') ->
        let MkParser pb = f_pb a in
        pb str'
        )
    )


runParser :: Parser a -> String -> [(a, String)]
runParser (MkParser f) s = f s

char1 :: Parser Char
char1 = MkParser (\str -> case str of
                            (c:cs) -> [(c, cs)]
                            _      -> []
                 )

-- char2 :: Parser (Char, Char)
-- char2 = MkParser (\str -> case str of
--                             (c1:c2:cs) -> [((c1, c2), cs)]
--                             _          -> []
--                  )

char2 :: Parser (Char, Char)
char2 = do
    c1 <- char1
    c2 <- char1
    return (c1, c2)


failP :: Parser a
failP = MkParser (\str -> [])

satP :: (Char -> Bool) -> Parser Char
satP validChar = do
    c <- char1
    if validChar c
        then return c
        else failP

bob :: Char -> Bool
bob = isDigit
-- >>> runParser (satP isDigit) "99horse"
-- [('9',"9horse")]


{-
   exprP :: Parser Exp

   numberP :: Parser Int
-}
-- horse

-- 101 + 2 + 3
-- Add (Add (Num 101) (Num 2)) (Num 3)
-- Add (Num 101) (Add (Num 2) (Num 3))

data Exp
    = Num Int
    | Add Exp Exp
    | Mul Exp Exp
