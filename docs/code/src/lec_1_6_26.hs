module Lec_1_6_26 where

-- >>> 1 + 200
-- 201

-- >>> tails0 [1,2,3]

-- >>> that ++ this
-- "worldhello"

this :: String
this = "hello"

that :: String
that = "world"

other :: String
other = this ++ " " ++ that




myFirstFunction = \n -> n > 0 -- function(n) { return n > 0; }

-- myFirstFunction n = n > 0

mySecond :: Integer -> Integer -> Bool
mySecond n m  = n > m

-- mySecond n = \m -> n > m
-- mySecond = \n -> \m -> n > m

bab = mySecond 100


jib = bab 50

silly :: Int -> (Int, Int)
silly n = (n - 1, n + 1)

billy :: Int -> (Int, (String, Bool))
billy n = (n-1 , ("cat" , n + 1 > 100 ))

-- >>> myName == alsoMyName
-- True

myName :: String
myName = "Ranjit"

alsoMyName :: [Char]
alsoMyName = ['R','a','n','j','i','t']


nextThree :: Int -> [Int]
nextThree n = [n, n + 1, n + 2, n + 3]


nextK n 0 =                      [n]
nextK n 1 =               [n, n + 1]
nextK n 2 =        [n, n + 1, n + 2]
nextK n 3 = [n, n + 1, n + 2, n + 3]
nextK n _ = error "OH NO!!!!"

{-






jib
= bab 50
= (mySecond 100) 50
= mySecond 100 50
= 100 > 50
= True



patt a b c = a * (b + c)
patt a b   = \c -> a * (b + c)
patt a     = \b -> \c -> a * (b + c)

patt       = \a -> \b -> \c -> a * (b + c)
             Int -> Int -> Int -> Int



-}




isTenGt0 :: Bool
isTenGt0 = myFirstFunction 10

{-

isTenGt0
= myFirstFunction 10
= 10 > 0
= True

-}



funky = if 4 > 3 then this else "blah" -- thing2


thing2 :: Double
thing2 = 5.1 + 6.9

thing3 :: Bool
thing3 = True

thing4 :: Char
thing4 = 'c'

ex0 = 5 > 4

thing1 :: Integer
thing1 = 2 * (5 + 6)

-- quiz = if ex0 then thing1 else 20

--  Type_of_INPUT -> Type_of_OUTPUT

quiz :: Bool -> Integer
quiz mickeymouse = if mickeymouse then thing1 else 0


add3 :: Integer -> Integer -> Integer -> Integer
add3 x y z = x + y + z

bob :: (Integer, Bool)
bob = (10 + 12, True)

bob3 :: (Integer, Bool, Char)
bob3 = (10 + 12, True, 'd')
