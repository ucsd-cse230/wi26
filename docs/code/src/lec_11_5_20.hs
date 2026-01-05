module Lec_11_11_20 where

import Debug.Trace

-- >>> 2.1 + 3.2
-- 5.300000000000001

-- >>> True + True
-- No instance for (Num Bool) arising from a use of ‘+’


half :: Int -> Int
half x = x `div` 2


foo :: (Eq a) => a -> a -> Bool
foo x y = x == y

-- >>> :type (+)
-- (+) :: forall a. (Num a) => a -> a -> a

-- <A implements Num> A add(A x, A y)

-- >>> False / True
-- No instance for (Fractional Bool) arising from a use of ‘/’

instance Num Bool where
    (+) x y = x || y
    (*) x y = x && y
    negate x = not x
    fromInteger 0 = False
    fromInteger _ = True

-- True + False 

-- True.add(False)

-- >>> ("dab", 10) < ("cat", 2)
-- False

-- >>> "apple" < "app"
-- False


-- >>> show 2
-- "2"


-- >>> show (1,2,"cat")
-- "(1,2,\"cat\")"


-- >>> :t show
-- show :: forall a. Show a => a -> String


thingA :: Unshowable
thingA = A

thingB :: Unshowable
thingB = B

things :: [Unshowable]
things = [thingA, thingB]

-- >>> [[thingA, thingB], [C]]
-- [[A,B],[C]]


-- instance Show Unshowable where
--     show x  = showU x

-- showU :: Unshowable -> String
-- showU A = "A"
-- showU B = "B"
-- showU C = "C"

data Unshowable = A | B | C 
                  deriving (Eq, Ord, Show)

---------
data Hard = H Int deriving (Eq)
---------

-- >>> A <= A 
-- True


data Table k v
  = Def  v                -- default value `v` to be used for "missing" keys
  | Bind k v (Table k v)  -- bind key `k` to the value `v`
  deriving (Show)

data Day = Tue | Wed | Thu | Fri deriving (Eq) 

table2 :: Table Day Int
table2 = Bind Tue 4 
            (Bind Wed 5 
                (Bind Thu 6 
                    (Bind Fri 7 
                        (Def 0))))

-- >>> get Fri table2
-- 7

table1 :: Table String Int
table1 = Bind "Tue" 4 
            (Bind "Wed" 5 
                (Bind "Thu" 6 
                    (Bind "Fri" 7 
                        (Def 0))))

-- >>> table1
-- Bind "Tue" 4 (Bind "Wed" 5 (Bind "Thu" 6 (Bind "Fri" 7 (Def 0))))

set :: key -> value -> Table key value -> Table key value
set k v t = Bind k v t

-- >>> get "Thu" table1
-- 6

-- >>> get "Fri" table1
-- 7

-- >>> get "Sun" table1
-- 0


-- get :: key -> Table key value -> value

-- get :: Eq k => k -> Table k v -> v
get :: (Eq t, Show t, Show p) => t -> Table t p -> p
get key t@(Bind k v rest) 
  | key == k    = v 
  | otherwise   = trace ("t = " ++ show t) (get key rest)
get key (Def v) = v 

-- >>> :t trace
-- trace :: forall a. String -> a -> a

--------
-- get/set
-- 
--------









quiz = A <= A 



-- eqU :: Unshowable -> Unshowable -> Bool
-- eqU A A = True 
-- eqU B B = True 
-- eqU C C = True 
-- eqU _ _ = False


-- instance Eq Unshowable where
--     (==) = eqU



-- (A) True
-- (B) False 
-- (C) Run-time ERROR
-- (D) Compile Time ERROR
-- (E) 2









myCompare :: Ord a => a -> a -> Bool
myCompare x y = x < y

-- >>> A < B
