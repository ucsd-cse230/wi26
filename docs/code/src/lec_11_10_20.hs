{-# LANGUAGE DeriveFunctor #-}
{-# LANGUAGE InstanceSigs #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE TypeSynonymInstances #-}
{-# LANGUAGE OverlappingInstances #-}

module Lec_11_5_20 where

import Debug.Trace

-- >>> 2.1 + 3.2
-- 5.300000000000001

data JVal
  = JStr  String
  | JNum  Double
  | JBool Bool
  | JObj  [(String, JVal)]
  | JArr  [JVal]
  deriving (Eq, Ord, Show)

js1 :: JVal
js1 =
  JObj [("name", JStr "Ranjit")
       ,("age",  JNum 41.0)
       ,("likes",   JArr [ JStr "guacamole", JStr "coffee", JStr "bacon"])
       ,("hates",   JArr [ JStr "waiting"  , JStr "grapefruit"])
       ,("lunches", JArr [ JObj [("day",  JStr "monday")
                                ,("loc",  JStr "zanzibar")]
                         , JObj [("day",  JStr "tuesday")
                                ,("loc",  JStr "farmers market")]
                         , JObj [("day",  JStr "wednesday")
                                ,("loc",  JStr "hare krishna")]
                         , JObj [("day",  JStr "thursday")
                                ,("loc",  JStr "faculty club")]
                         , JObj [("day",  JStr "friday")
                                ,("loc",  JStr "coffee cart")]
                         ])
       ]


{-
  Double -> JVal
  Bool  -> JVal
  String -> JVal

  class ToJVal a where
    toJVal :: a -> JVal


 -}



instance ToJVal Double where
  toJVal d = JNum d

instance ToJVal String where
  toJVal s = JStr s

instance ToJVal Bool where
  toJVal s = JBool s

instance (ToJVal a) => ToJVal [a] where
  toJVal xs = JArr (map toJVal xs)



class ToJVal a where
  toJVal :: a -> JVal 

instance ToJVal a => ToJVal [(String, a)] where
  toJVal kvs = JObj (map (\(k, v) -> (k, toJVal v)) kvs)

-- >>> toJVal [("mon", 0.0 :: Double), ("tue", 1)]
-- JObj [("mon",JNum 0.0),("tue",JNum 1.0)]


-- >>> toJVal ([1.0, 2.1, 3.2] :: [Double])
-- JArr [JNum 1.0,JNum 2.1,JNum 3.2]
-- >>> toJVal [["cat", "dog"], ["horse"], []]
-- JArr [JArr [JStr "cat",JStr "dog"],JArr [JStr "horse"],JArr []]





data Table k v 
  = Def v 
  | Bind k v (Table k v)
  deriving (Show, Functor)

instance ToJVal v => ToJVal (Table String v) where 
  toJVal :: Table String v -> JVal
  toJVal env = JObj (conv env)
  -- toJVal (Def v) = JObj [("def", toJVal v)]
  -- toJVal (Bind k v rest) = JObj [ (k, toJVal v) , ("rest", toJVal rest) ]

conv :: (ToJVal v) => Table String v -> [(String, JVal)]
conv env = case env of
  Def v         -> [("def", toJVal v)]
  Bind k v rest -> (k, toJVal v) : conv rest

table :: Table String Double
table = Bind "cat" 10.0 (Bind "dog" 20.0 (Def 0))

-- >>> fmap (\p -> p * 100) table
-- No instance for (Show (Table String Double))
--   arising from a use of ‘ghcideCustomShow’


-- >>> toJVal table 
-- JObj [("cat",JNum 10.0),("dog",JNum 20.0),("def",JNum 0.0)]

-- >>> toJVal table 
-- JObj [("cat",JNum 10.0),("rest",JObj [("dog",JNum 20.0),("rest",JObj [("def",JNum 0.0)])])]


-- JObj [ ("cat", JNum 10.0)
--      , ("dog", JNum 20.0)
--      , ("def", JNum 0.0)
--      ]


data Tree a = Leaf | Node a (Tree a) (Tree a)
  deriving (Eq, Ord, Show, Functor)

tr0 :: Tree Int
tr0 = Node 5 
        (Node 2 Leaf Leaf) 
        (Node 7 Leaf Leaf)

-- >>> fmap (\n -> n + 1) tr0
-- Node 6 (Node 3 Leaf Leaf) (Node 8 Leaf Leaf)


incTree :: Tree Int -> Tree Int
incTree Leaf = Leaf
incTree (Node n l r) = Node (n + 1) (incTree l) (incTree r)

sqrTree :: Tree Int -> Tree Int
sqrTree Leaf = Leaf
sqrTree (Node n l r) = Node (n * n) (sqrTree l) (sqrTree r)

instance Mappable [] where
  gmap f []     = []
  gmap f (x:xs) = f x : (gmap f xs)

instance Mappable Tree where
  gmap f Leaf         = Leaf
  gmap f (Node n l r) = Node (f n) (gmap f l) (gmap f r)

class Mappable t where
  gmap :: (a -> b) -> t a -> t b

incThings :: (Functor t) => t Int -> t Int
incThings = fmap (\n -> n + 1)

sqrThings :: (Functor t) => t Int -> t Int
sqrThings = fmap (\n -> n * n)

showThings :: (Functor t, Show a) => t a -> t String
showThings = fmap (\x -> show x)




-- >>> sqrThings [1,2,3,4]
-- [1,4,9,16]

{- 
    5 
  2   7
L L   L L

-}