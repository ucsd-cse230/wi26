module Lec_10_10_23 where
import Data.Time.Format.ISO8601 (yearFormat)

-- >>> 1 + 2
-- 3

-- >>> tails0 [1,2,3]


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
