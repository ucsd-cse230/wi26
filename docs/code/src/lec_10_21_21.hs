{-# LANGUAGE DeriveFunctor #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE FlexibleInstances #-}
-- TODAY

{-# LANGUAGE OverloadedStrings #-}

module Lec_10_21_21 where

import qualified Data.Text as T
import qualified Data.Char as Char

data Breakfast = Egg | Smoothie
  deriving (Eq, Ord, Show)

data Lunch = Sandwich | Soup | Salad
  deriving (Eq, Ord, Show)

data Food = B Breakfast |  L Lunch
  deriving (Eq, Ord, Show)

-- instance Eq Lunch where
--   (==) = eqLunch

-- instance Show Lunch where
--   show Soup = "Soup"
--   show Sandwich = "Sand-wich"




eqLunch :: Lunch -> Lunch -> Bool
eqLunch Sandwich Sandwich = True
eqLunch Soup     Soup = True
eqLunch _        _  = False

{- 

class Num a where 
  (+) :: a -> a -> a

class Eq a where
  (==) :: a -> a -> Bool
  
class Ord a where
  compare :: a -> a -> Ordering 

-}

-- TYPECLASSES

-- FUNCTOR 

-- MONAD




data JVal
  = JStr  T.Text
  | JNum  Double
  | JBool Bool
  | JObj  [(T.Text, JVal)]
  | JArr  [JVal]
  deriving (Eq, Ord, Show)




-- >>> textJVal "ranjit"
-- JStr "ranjit"

js1 :: JVal
js1 =
  JObj [("name", JStr "Ranjit")
       ,("age",  JNum 44.0)
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

data Day = Mon | Tue | Wed | Thu | Fri deriving (Eq, Ord, Show)

data Eat = MkEat { day :: Day , loc :: T.Text }

instance ToJVal Day where
  jval d = JStr (T.pack (show d))

instance ToJVal Eat where
  jval (MkEat d l) = JObj [ ("day", jval d), ("loc", jval l) ]

instance ToJVal T.Text where
  jval s = JStr s

instance ToJVal Int where
  jval i = JNum (fromIntegral i)

instance ToJVal a => ToJVal [a] where
  jval xs = JArr (map jval xs)

class ToJVal a where
  jval :: a -> JVal

lunches :: [Eat]
lunches =
  [ MkEat Mon "zanzibar"
  , MkEat Tue "farmers market"
  , MkEat Wed "lemongrass"
  , MkEat Thu "art of espresso"
  , MkEat Fri "faculty club"
  ]



-- >>> jval [lunches]
-- JArr [JArr [JObj [("day",JStr "Mon"),("loc",JStr "zanzibar")],JObj [("day",JStr "Tue"),("loc",JStr "farmers market")],JObj [("day",JStr "Wed"),("loc",JStr "lemongrass")],JObj [("day",JStr "Thu"),("loc",JStr "art of espresso")],JObj [("day",JStr "Fri"),("loc",JStr "faculty club")]]]


data Table key val
  = Emp
  | Ent key val (Table key val)
  deriving (Show, Functor)


-- >>> jval lunches' 
-- JObj [("Mon",JStr "zanzibar"),("Tue",JStr "farmers market"),("Wed",JStr "lemongrass"),("Thu",JStr "art of espresso"),("Fri",JStr "faculty club")]

-- >>> angry "zanzibar"
-- "ZANZIBAR"

angry :: [Char] -> [Char]
angry str = map (Char.toUpper) str

-- >>> map (Char.toUpper) ['z', 'a', 'n']
-- 
-- >>> tableMap angry lunches' 

tableMap :: (a -> b) -> Table key a -> Table key b 
tableMap f Emp = Emp
tableMap f (Ent k v rest) = Ent k (f v) (tableMap f rest)

class Mappable thing where
  genMap :: (a -> b) -> thing a -> thing b 

instance Mappable [] where 
  genMap = map

-- Functor

instance Mappable (Table k) where 
  genMap = tableMap

-- >>> fmap angry ["cat", "dog"]
-- ["CAT","DOG"]
-- >>> fmap (angry . T.unpack) lunches'
-- Ent Mon "ZANZIBAR" (Ent Tue "FARMERS MARKET" (Ent Wed "LEMONGRASS" (Ent Thu "ART OF ESPRESSO" Emp)))

{- 

tableMap :: (a -> b) -> Table key a -> Table key b 
map      :: (a -> b) -> List a      -> List      b

map f [] = []
map f (x:xs) = f x : map f xs

-}

lunches' :: Table Day T.Text
lunches' =
  Ent Mon "zanzibar"
    (Ent Tue "farmers market"
      (Ent Wed "lemongrass"
        (Ent Thu "art of espresso"
          Emp)))

instance (Show key, ToJVal val) => ToJVal (Table key val) where
  jval t = JObj [ (T.pack (show k), jval v) | (k, v) <- toList t]

toList :: Table k v -> [(k, v)]
toList Emp = []
toList (Ent k v rest) = (k, v) : toList rest


-- >>> get "hungry" Fri lunches'
-- "hungry"

get :: Eq k => v -> k -> Table k v -> v
get def key Emp = def
get def key (Ent k v rest) = if key == k then v else get def key rest


{- 

        Mon Tue __ Thu Fri

  Wed
-}

-- >>> set Tue "rubios" lunches'
-- Ent Mon "zanzibar" (Ent Tue "farmers market" (Ent Wed "lemongrass" (Ent Thu "art of espresso" (Ent Fri "rubios" Emp))))

set :: Ord key => key -> val -> Table key val -> Table key val
set key val Emp            = Ent key val Emp
set key val (Ent k v rest)
  | k == key = Ent k val rest
  | k < key  = Ent k v  (set key val rest)
  | otherwise {- k > key -} = Ent key val (Ent k v rest)

-----
