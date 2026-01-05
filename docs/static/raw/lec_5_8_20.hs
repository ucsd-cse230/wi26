{-# LANGUAGE FlexibleInstances    #-}
{-# LANGUAGE TypeSynonymInstances #-}
{-# LANGUAGE OverlappingInstances #-}



module Lec_5_8_20 where





data Table k v
  = Def  v                -- default value `v` to be used for "missing" keys
  | Bind k v (Table k v)  -- bind key `k` to the value `v`
  deriving (Read, Show)

prices :: Table String Double
prices = Bind "switch"      500 
       $ Bind "switch-lite" 200 
       $ Bind "wii"         150 
       $ Def 1000

peopleLikes :: Table String [String]
peopleLikes 
       = Bind "ranjit" ("kale" :likes) 
       $ Bind "nalini" likes 
       $ Def ["chocolate"]

-- >>> likes
-- ["guacamole","coffee","tacos"]
--



-- >>> toJSON peopleLikes
-- ["guacamole","coffee","tacos"]
-- JArr [JObj [("ranjit",JArr [JStr "kale",JStr "guacamole",JStr "coffee",JStr "tacos"])],JObj [("nalini",JArr [JStr "guacamole",JStr "coffee",JStr "tacos"])],JArr [JStr "chocolate"]]
--

-- ($) f x = f x
-- foo (bar (baz  (qoo (mar (faz x)))))
-- foo $ bar $ baz $ qoo $ mar $ faz x 


keys (Def _)         = []
keys (Bind k _ rest) = k : keys rest

-- >>> get "wii" prices
-- 150 

-- >>> get "xbox" prices
-- 1000

get :: (Eq k) => k -> Table k v -> v
get key (Def v)         = v 
get key (Bind k v rest) = if key == k then v else get key rest 

getByV :: (Eq v) => v -> Table k v -> [k] 
getByV val (Def _)         = []
getByV val (Bind k v rest) = if val == v then k : ks else ks
  where ks                 = getByV val rest 


quiz = read two :: String 

two :: String
two = "\"2\""

-- set :: (Ord k) => k -> v -> Table k v -> Table k v 
-- get :: (Ord k) => k -> Table k v -> v









---------------------------------------------------------------------------------
data JVal
  = JStr  String
  | JNum  Double
  | JBool Bool
  | JObj  [(String, JVal)]
  | JArr  [JVal]
  deriving (Eq, Ord, Show)


-- >>> dubToJSON 42.0
-- JNum 42.0
--

-- >>> toJSON "guacamole"
-- JStr "guacamole"
-- >>> toJSON likes
-- JArr [JStr "guacamole",JStr "coffee",JStr "tacos"]
-- >>> toJSON scores
-- JArr [JNum 10.0,JNum 20.0,JNum 30.0,JNum 41.0]
--

likes :: [String]
likes = ["guacamole", "coffee", "tacos"]

scores :: [Double]
scores = [10, 20, 30, 41]

-- stringsToJson :: [String] -> JVal
-- stringsToJson xs = JArr (map toJSON xs)

-- dubsToJson :: [Double] -> JVal
-- dubsToJson xs = JArr (map toJSON xs)

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



-- >>> stringsToJson likes
-- JArr [JStr "guacamole",JStr "coffee",JStr "tacos"]
-- >>> dubsToJson scores
-- JArr [JNum 10.0,JNum 20.0,JNum 30.0,JNum 41.0]
--





-- >>> toJSON (("monday", 31.1), ("tuesday", 42.5))
-- JObj [("monday",JNum 31.1),("tuesday",JNum 42.5)]
--


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
-- >>> toJSON prices
-- JArr [JObj [("\"switch\"",JNum 500.0)],JObj [("\"switch-lite\"",JNum 200.0)],JObj [("\"wii\"",JNum 150.0)],JNum 1000.0]
--

instance (Show k, JSON val) => JSON (Table k val) where
  toJSON (Def v)         = toJSON v -- convert v into JSON?
  toJSON t = JArr (kvs ++ [toJSON def])  
    where 
      kvs = (map (\(key,val) -> JObj [(show key, toJSON val)]) (keyVals t))
      def = getDef t 

getDef (Def v) = v
getDef (Bind _ _ rest) = getDef rest

keyVals :: Table k v -> [(k, v)]
keyVals (Def v) = []
keyVals (Bind k v rest) = (k, v) : keyVals rest

