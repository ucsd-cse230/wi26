module Lec_5_1_20 where

-- >>> sumList [0,1,2,3,4]
-- 10
--

sumList :: [Int] -> Int
sumList []     = 0
sumList (x:xs) = x + sumList xs

-- >>> catList ["this", "is", "the", "end"]
-- "thisistheend"
--
catList :: [String] -> String
catList []     = "" 
catList (x:xs) = x ++ (catList xs)

-------------------------------------------------------------------
-- | Bottle that pattern!
-------------------------------------------------------------------

-- | Instantiate to get `sumList` --------------------------------- 
-- >>> sumList' [0,1,2,3,4]
-- 10
--
--
sumList' xs = myfoldr (\n m -> n + m)  0  xs 

-- | Instantiate to get `catList` --------------------------------- 
-- >>> catList ["this", "is", "the", "end"]
-- "thisistheend"
--
catList' xs = myfoldr (\x y -> x ++ y) "" xs 

len xs       = myfoldr op 0 xs
  where
      op x r = 1 + r

myfoldr op b []     = b
myfoldr op b (x:xs) = op x (myfoldr op b xs)

myfoldr op b   = loop 
  where 
     loop[]    = b
     loop(x:xs) = op x (xs)



{- 

foldr :: (a -> b -> b) -> b -> [a] -> b



foldr op b (a1 : (a2 : (a3 :    [])))
               ^op   ^op   ^op  ^b 
== op a1 (foldr op b (a2:a3:[]))
== op a1 (op a2 (foldr op b (a3:[]))
== op a1 (op a2 (op a3 (foldr op b [])))

== a1 `op` (a2 `op` (a3 `op` b)))

foldr (+) 0 (1:2:3:4:5:[])
== (1+2+3+4+5+0)
-}

{- What kinds of values are a 
HW-Exercise

funkyTree :: Tree Int Bool
funkyTree = ???

data Tree a b 
  = Leaf 
  | Node a (Tree a b) (Tree b a)
  deriving(Show)

-}

data Tree a 
  = Leaf 
  | Node a (Tree a) (Tree a)
  deriving(Show)

height :: Tree a -> Int 
height Leaf = 0  
height (Node x l r) = 1 + max (height l) (height r)

-- >>> height tree123
-- 2
--

-- >>> sumTree tree123
-- 6
--

sumTree :: Tree Int -> Int
sumTree Leaf         = 0 
sumTree (Node x l r) = x + (sumTree l) + (sumTree r) 

-- >>> toList tree123
-- [1,2,3]

toList :: Tree a -> [a] 
toList Leaf         = [] 
toList (Node x l r) = x : (toList l) ++ (toList r)


tFold :: (a -> b -> b -> b) -> b -> Tree a -> b
tFold op b Leaf         = b
tFold op b (Node x l r) = op x (tFold op b l) (tFold op b r)


-- >>> tFold (\x bl br -> bl + br) 1 tree123 
-- 4
-- >>> tree123
-- Node 1 (Node 2 Leaf Leaf) (Node 3 Leaf Leaf)
--

tree2 :: Tree Int
tree2 = Node 2 Leaf Leaf

tree3 :: Tree Int
tree3 = Node 3 Leaf Leaf

tree123 :: Tree Int
tree123 = Node 1 tree2 tree3 

-- >>> treeMax tree123
-- 3
--
treeMax :: Tree Int -> Int
treeMax t = tFold f b t 
  where 
     f    = \x bl br -> max x (max bl br)
     b    = 0 


countFiles :: Dir FilePath -> Int
countFiles dir = foldDir f 0 dir
  where
      f _ n (Fil _) = n + 1 
      f _ n (_)     = n 

foldDir :: ([a] -> r -> DirElem a -> r) -> r -> Dir a -> r
foldDir f r0 dir = helper [] r0 dir  
  where
      helper stk r (Fil a)    = f stk r (File a)  
      helper stk r (Sub a ds) = L.foldl' (helper stk') r' ds                          
        where 
            r'   = f stk r (SubDir a)  
            stk' = a:stk