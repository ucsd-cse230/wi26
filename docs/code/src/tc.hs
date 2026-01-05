{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE OverloadedStrings #-}

module Tc where

import qualified Data.Text as T

----------------------------------------------------------------------------------------

data Eat = Eat
  { day :: T.Text
  , loc :: T.Text
  }

data Person = Person 
  { name  :: T.Text
  , age   :: Double
  , likes :: [T.Text]
  , hates :: [T.Text]
  , lunch :: [Eat]
  }

lunches :: [Eat]
lunches = 
  [ Eat "mon" "zanzibar"
  , Eat "tue" "farmers market"
  , Eat "wed" "lemongrass"
  , Eat "thu" "art of espresso"
  , Eat "fri" "faculty club"
  ]

hs :: Person
hs = Person 
      "Ranjit"
      41.0
      ["guacamole", "coffee", "bacon"]
      ["waiting", "grapefruit"]
      lunches

----------------------------------------------------------------------------------------

data JVal
  = JStr  T.Text
  | JNum  Double
  | JBool Bool
  | JObj  [(T.Text, JVal)]
  | JArr  [JVal]
  deriving (Eq, Ord, Show)

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

----------------------------------------------------------------------------------------

class JSON a where
  toJSON :: a -> JVal

instance JSON Double where
  toJSON = JNum

instance JSON Bool where
  toJSON = JBool

instance JSON T.Text where
  toJSON = JStr

instance JSON a => JSON [a] where
  toJSON xs = JArr (map toJSON xs)

instance (JSON a) => JSON [(T.Text, a)] where
  toJSON kvs = JObj (map (\(k, v) -> (k, toJSON v)) kvs) 

instance JSON Eat where
  toJSON = error "TODO" 

instance JSON Person where
  toJSON = error "TODO" 


js2 :: JVal
js2 = toJSON hs

-- >>> js2
-- JObj [("name",JStr "Ranjit"),("age",JNum 41.0),("likes",JArr [JStr "guacamole",JStr "coffee",JStr "bacon"]),("hates",JArr [JStr "waiting",JStr "grapefruit"]),("lunch",JArr [JObj [("day",JStr "mon"),("loc",JStr "zanzibar")],JObj [("day",JStr "tue"),("loc",JStr "farmers market")],JObj [("day",JStr "wed"),("loc",JStr "lemongrass")],JObj [("day",JStr "thu"),("loc",JStr "art of espresso")],JObj [("day",JStr "fri"),("loc",JStr "faculty club")]])]



























{-
instance JSON Eat where
  toJSON Eat {..} = JObj 
    [ ("day", toJSON day)
    , ("loc", toJSON loc) 
    ]

instance JSON Person where
  toJSON Person {..} = JObj
    [ ("name" , toJSON name) 
    , ("age"  , toJSON age)
    , ("likes", toJSON likes)
    , ("hates", toJSON hates)
    , ("lunch", toJSON lunch)
    ]

-} 