{-# LANGUAGE FlexibleInstances    #-}
{-# LANGUAGE TypeSynonymInstances #-}
{-# LANGUAGE OverlappingInstances #-}

module Lec_5_6_20 where

{-
x = 10 
y = 20

x < y 

   x._less_than(y)

a = "ten"
b = "twenty"

a < 10

a._less_than(b)

"ten" < "twenty" 

-}

incr :: Int -> Int
incr x = x + 1


plus :: (Num a) => a -> a -> a
plus = undefined

-- tryIt = plus 3.0 5.6



-- (+) :: (Num a) => a -> a -> a

-- A plus<A implements Num>(x:A, y:A)

two :: Int
two = 2

three :: Int
three = 3

ok1  = two === three 

ok2  = "cat" === "dog"

-- fail = incr === incr 


class MyEq a where
    (===) :: a -> a -> Bool
    (===) x y = not (x =/= y)

    (=/=) :: a -> a -> Bool
    (=/=) x y = not (x === y)

instance MyEq Int where
    (===) x y = x == y

instance MyEq String where
    (=/=) x y = not (x == y)

-- >>> quiz
-- True
--

quiz = A /= B
{- 

*A* TRUE
*B* FALSE
*C* Type error
*D* Run-time "pattern match" error

-}
data Hidden = A | B | C deriving (Eq, Show)

-- >>> [Wrap A, Wrap B, Wrap C]
-- [Wrap A,Wrap B,Wrap C]
--

data Wrapper = Wrap Hidden deriving (Eq, Show)

instance MyEq Hidden where
    (===) A A = True
    (===) B B = True
    (===) C C = True
    (===) _ _ = False

data Showable = AA | BB deriving (Eq, Ord, Show)

quiz' = AA < BB

-- instance Show Hidden where
--     show A = "A"
--     show B = "B"
--     show C = "C"



data Table k v
  = Def  v                -- default value `v` to be used for "missing" keys
  | Bind k v (Table k v)  -- bind key `k` to the value `v`
  deriving (Show)

prices :: Table String Int
prices = Bind "switch"      500 
        (Bind "switch-lite" 200 
        (Bind "wii"         150 
        (Def 1000)
        )
        )  

keys (Def _)         = []
keys (Bind k _ rest) = k : keys rest

-- >>> get "wii" prices
-- 150 

-- >>> get "xbox" prices
-- 1000

get :: (Eq k) => k -> Table k v -> v
get key (Def v)         = v 
get key (Bind k v rest) = if key == k then v else get key rest 

getV :: (Eq k, Eq v) => v -> Table k v -> [k] 
getV val (Def _)         = []
getV val (Bind k v rest) = if val == v then k : ks else ks
  where ks               = getV val rest 







---------------------------------------------------------------------------------
data JVal
  = JStr  String
  | JNum  Double
  | JBool Bool
  | JObj  [(String, JVal)]
  | JArr  [JVal]
  deriving (Eq, Ord, Show)















---------------------------------------------------------------------------------
class JSON a where
  toJSON :: a -> JVal

instance JSON Double where
  toJSON = JNum

instance JSON Bool where
  toJSON = JBool

instance JSON String where
  toJSON = JStr

instance JSON a => JSON [a] where
  toJSON xs = JArr (map toJSON xs)

instance (JSON a) => JSON [(String, a)] where
  toJSON kvs = JObj (map (\(k, v) -> (k, toJSON v)) kvs) 

instance (JSON a, JSON b) => JSON ((String, a), (String, b)) where
  toJSON ((k1, v1), (k2, v2)) = JObj 
    [ (k1, toJSON v1)
    , (k2, toJSON v2)
    ]

instance (JSON a, JSON b, JSON c) => JSON ((String, a), (String, b), (String, c)) where
  toJSON ((k1, v1), (k2, v2), (k3, v3)) = JObj 
    [ (k1, toJSON v1)
    , (k2, toJSON v2)
    , (k3, toJSON v3)
    ]

instance (JSON a, JSON b, JSON c, JSON d) => JSON ((String, a), (String, b), (String, c), (String,d)) where
  toJSON ((k1, v1), (k2, v2), (k3, v3), (k4, v4)) = JObj 
    [ (k1, toJSON v1)
    , (k2, toJSON v2)
    , (k3, toJSON v3)
    , (k4, toJSON v4)
    ]

instance (JSON a, JSON b, JSON c, JSON d, JSON e) => JSON ((String, a), (String, b), (String, c), (String,d), (String, e)) where
  toJSON ((k1, v1), (k2, v2), (k3, v3), (k4, v4), (k5, v5)) = JObj 
    [ (k1, toJSON v1)
    , (k2, toJSON v2)
    , (k3, toJSON v3)
    , (k4, toJSON v4)
    , (k5, toJSON v5)
    ]

lunches = [ [("day", "monday"),    ("loc", "zanzibar")]
          , [("day", "tuesday"),   ("loc", "farmers market")]
          ]

hs = (("name"   , "Ranjit")
     ,("age"    , 41.0)
     ,("likes"  , ["guacamole", "coffee", "bacon"])
     ,("hates"  , ["waiting", "grapefruit"])
     ,("lunches", lunches)
     )


-- >>> toJSON lunches
-- JArr [JObj [("day",JStr "monday"),("loc",JStr "zanzibar")],JObj [("day",JStr "tuesday"),("loc",JStr "farmers market")]]
--
