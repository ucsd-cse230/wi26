module Lec_10_7_21 where

thing1 :: Integer
thing1 = 2

thing2 :: Double
thing2 = 5.1 + 6.9

thing3 :: Bool
thing3 = True 

thing4 = if True then thing1 else 1 + thing1 

-- Tin -> Tout 

foo :: Integer -> Bool
foo x = x > 0

bar x = x < 0

baz x = x == 0

l0 = []
l1 = 1:[]
l2 = 1:(2:[])
l3 = 1:(2:(3:(5:(6:(7:(7:[]))))))

{- 
 []

 :          

-}

funky :: [Integer -> Bool]
funky = [{- foo, bar, baz,-} bizarre] 

fShub = myHead funky

bizarre :: {- forall a. -} a -> Bool
bizarre x = False

-- >>> myHead funky "cat"
-- Couldn't match expected type ‘Integer’ with actual type ‘[Char]’


-- >>> bizarre "cat"
-- False


{- 
-}
checkFunny :: Int -> Int -> Bool
checkFunny x1 x2 = x1 >= x2 * 100


quiz :: Integer -> Integer -> Bool
quiz x y = x + y > 0 

quiz10 = quiz 10

-- >>> quiz10 1000

-- quiz10 1000  ==> 10 + 1000 > 0 ==> True

-- (A) CRASH    (B) TRUE    (C) FALSE       (D) OTHER VALUE (not-crash)

pat x y z = x * (y + z)


skipOne :: (a -> a) -> (Bool, a) -> (Bool, a)
skipOne f (b, x) = if b then (True, f x) else (True, x)


tup1 = (2, "cat")

tup3 :: ([Char], Double, Integer)
tup3 = ("this", 4.5, 6)


-- Tf -> Tx -> Tx
zero = \f x -> x


-- (Tx -> Tres) -> Tx -> Tres
one = \f x -> f x

three = \f x -> f (f (f x))

two = \f x -> f (f x)


{- 
(Tx -> Tx) -> Tx -> Tx

-}


-- >>> checkFunny 99 1 
-- >>> checkFunny 100 1 
-- >>> checkFunny 101 1 
-- >>> checkFunny 101 2 
-- >>> checkFunny 201 2 
-- False

-- True

-- True

-- False

-- True


-- >>> ((\x -> x > 10) (-10000))
-- False











-- >>> inc 15
-- 16

inc :: Int -> Int
inc x = x + 1


clone :: Int -> t -> [t]
clone 0 _ = [] 
clone n x = x : clone (n-1) x

append :: [a] -> [a] -> [a]
append []      l2 = l2 
append (h1:t1) l2 = h1 : append t1 l2 


myHead :: [a] -> a
myHead (h:t) = h
myHead [] = undefined

{- 
    append (1:2:[]) (3:4:[])
    ==> 1 : append (2:[]) (3:4:[]) 
    ==> 1 : 2 : append [] (3:4:[]) 
    ==> 1 : 2 : 3:4:[] 
-}

sumList :: [Int] -> Int
sumList (h:t) = h + sumList t
sumList []    = 0

-- sumList  [1,2,3,4] ==> 10



-- >>> ["cat", "mouse"]  ++ ["diggity", "dog"]
-- ["cat","mouse","diggity","dog"]

-- >>> clone 4 "dog"
-- ["dog","dog","dog","dog"]


-- clone 3 "cat" ==> ["cat", "cat", "cat"]
-- clone 2 "cat" ==> ["cat, "cat"]
-- clone 1 "cat" ==> ["cat"]
-- clone 0 "cat" ==> []

type Circle = (Double, Double, Double)

data CircleT = MkCircle Double Double Double


type Cuboid = (Double, Double, Double)

data CuboidT = MkCuboid Double Double Double


-- >>> ex1 == ex2
-- True


exCirc :: CircleT 
exCirc = MkCircle 1.1 2.2 3.3

exCuboid :: CuboidT
exCuboid = MkCuboid 1.1 2.2 3.3

area :: CircleT -> Double
area (MkCircle _ _ r) = pi * r * r

volume :: CuboidT -> Double
volume (MkCuboid l b h) = l * b * h


-- >>> area exCuboid
-- Couldn't match expected type ‘CircleT’ with actual type ‘CuboidT’




idk = pi

