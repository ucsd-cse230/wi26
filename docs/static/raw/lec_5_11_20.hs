{-# LANGUAGE FlexibleInstances    #-}
{-# LANGUAGE TypeSynonymInstances #-}
{-# LANGUAGE DeriveFunctor        #-}
{-# LANGUAGE DeriveFoldable       #-}


module Lec_5_11_20 where

-- >>> incr 5
-- 6
--

incr :: Int -> Int
incr x = x + 1

squares :: [Int] -> [Int]
-- squares []     = []
-- squares (x:xs) = x * x : squares xs
squares xs = map (\x -> x * x) xs 
        --   [x * x | x <- xs]
        --   [x * x for x in xs]


data Tree a 
  = Leaf  
  | Node a (Tree a) (Tree a)
  deriving (Eq, Show, Functor, Foldable)

-- >>> length tree1
-- 3

tree1 :: Tree Int
tree1 = Node 2 
            (Node 1 Leaf Leaf)
            (Node 3 Leaf Leaf)

tree2 :: Tree String 
tree2 = Node "to"
            (Node "a"   Leaf Leaf)
            (Node "dog" Leaf Leaf)

f_exercise :: String -> Int
f_exercise = length
-- f_exercise "to"  = 2
-- f_exercise "a"   = 1
-- f_exercise "dog" = 3

-- >>> (gmap f_exercise tree2) == tree1
-- True
--



-- >>> showTree (Node 2 (Node 1 Leaf Leaf) (Node 3 Leaf Leaf))
-- Node "2" (Node "1" Leaf Leaf) (Node "3" Leaf Leaf)
--

showTree :: Tree Int -> Tree String
showTree Leaf         = Leaf
showTree (Node v l r) = Node v' l' r'
  where
      v' = show v 
      l' = showTree l 
      r' = showTree r 
      
sqTree :: Tree Int -> Tree Int
sqTree Leaf         = Leaf
sqTree (Node v l r) = Node v' l' r'
  where
      v' = v * v 
      l' = sqTree l 
      r' = sqTree r 


-- >>> showTree' tree1
-- Node "2" (Node "1" Leaf Leaf) (Node "3" Leaf Leaf)
--
-- >>> sqTree' tree1
-- Node 4 (Node 1 Leaf Leaf) (Node 9 Leaf Leaf)
--

showTree' t = mapTree show t     
sqTree' t   = mapTree (\n -> n*n) t     

mapTree :: (a -> b) -> Tree a -> Tree b 
mapTree f Leaf         = Leaf
mapTree f (Node v l r) = Node v' l' r'
  where
      v' = f v 
      l' = mapTree f l 
      r' = mapTree f r 


-------

-- intToString :: Int -> String
-- doubleToString :: Double -> String

-- class ToString a where
--     toString :: a -> String

-- intToJSON :: Int -> JSON 
-- doubleToJSON :: Double -> JSON 

-- class ToJSON a where
--     toJSON :: a -> JSON 


class Mappable t where
  gmap :: (a -> b) -> t a -> t b

instance Mappable Tree where
    gmap = mapTree

instance Mappable [] where
    gmap = map





-- >>> gmap show [1,2,3,4]
-- ["1","2","3","4"]
--

-- >>> gmap show tree1 
-- Node "2" (Node "1" Leaf Leaf) (Node "3" Leaf Leaf)
--

-- silly :: ?? -> ?? -> ??
silly :: (Functor t) => (a -> b) -> t a -> t b
silly f thing = fmap f thing

-- billy :: Int -> Int -> Bool
billy :: (Eq a) => a -> a -> Bool
billy x y = x == y

{- 
  A. (a -> b) -> [a] -> [b]
  B. (a -> b) -> Tree a -> Tree b
  C. (a -> b) -> t a -> t b
  D. ???
 -}
data Expr
  = Number Int            -- ^ 0,1,2,3,4
  | Plus   Expr Expr      -- ^ e1 + e2
  | Minus  Expr Expr      -- ^ e1 - e2
  | Mult   Expr Expr      -- ^ e1 * e2
  | Div    Expr Expr      -- ^ e1 / e2
  deriving (Show)

e1 = Plus  (Number 2) (Number 3)    -- 2 + 3
e2 = Minus (Number 10) (Number 4)   -- 10 - 4
e3 = Mult e1 e2                     -- (2 + 3) * (10 - 4)
e4 = Div  e3 (Number 3)             -- ((2 + 3) * (10 - 4)) / 3 


data Result a
  = Ok a 
  | Error
  deriving (Eq, Show)

-- 1.
-- instance Functor Result where
--     fmap = ???

-- 2. 



-- eval :: Expr -> Result Int
-- -- eval :: Expr -> Int
-- eval (Number x)    = x
-- eval (Plus e1 e2)  = eval e1 + eval e2
-- eval (Minus e1 e2) = eval e1 - eval e2
-- eval (Mult e1 e2)  = eval e1 * eval e2
-- eval (Div e1 e2)   = eval e1 `div` eval e2 

-- >>> myHead []
-- *** Exception: /Users/rjhala/teaching/230-sp20/static/raw/lec_5_11_20.hs:169:1-16: Non-exhaustive patterns in function myHead
-- <BLANKLINE>
--

myHead :: [a] -> Result a
myHead (x:xs) = Ok x
myHead []     = Error


exQuiz :: Expr
exQuiz = (Div (Number 60) (Minus (Number 5) (Number 5)))

-- >>> eval exQuiz
-- *** Exception: divide by zero
--

-- >>> eval e1
-- 5 
-- >>> eval e2
-- 6
-- >>> eval e3
-- 30 
-- >>> eval e4
-- 10

-- >>> e4
-- Div (Mult (Plus (Number 2) (Number 3)) (Minus (Number 10) (Number 4))) (Number 3)
--


