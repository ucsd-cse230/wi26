module Lec_4_27_20 where

import Text.Printf

type Vertex = (Double, Double)

doTwice :: (a -> a) -> a -> a
doTwice f x = f (f x)




gt :: Int -> Int -> Bool
gt x y = x > y
-- gt x = \y -> x > y
-- gt   = \x y -> x > y

data MyBool = MyTrue | MyFalse

dubble x = x + x

-- doTwice dubble 100
-- ==> dubble (dubble 100)
-- ==> dubble (100 + 100)
-- ==> (100 + 100) + (100 + 100)
-- ==> 400

-- doTwice yum "cookie" 
-- ==> yum (yum "cookie")
-- ==> yum ("cookie yum! yum!")
-- ==> ("cookie yum! yum! yum! yum!")

-- gt 10 :: Int -> Bool
-- gt 10 = (\y -> 10 > y)


-- doTwice (gt 10) 0          -- 
-- ==> gt 10 (gt 10 (0))
-- ==> gt 10 (10 > 0)
-- ==> gt 10 True

apply :: a -> (a -> b) -> b
apply x f = f x 

(|>):: a -> (a -> b) -> b
(|>) x f = f x 

add x y = x + y

-- apply 100 (gt 10)
-- => (gt 10) 100
-- => (10 > 100)
-- => False 

(!+!) x y = x + y


-- ((((x |> f1)  |> f2) |> f3) |> f4)
-- (f4 (f3 (f2 (f1 x)))) 
-- 

sub x y = x - y

-- (sub 100 ((sub 10 5)) )

-- 




data Shape2D 
    = Rectangle Double Double 
    | Polygon [Vertex]  
    deriving (Show)



data IList
  = INil
  | ICons Int IList
  deriving (Show)


list_1_2_3 :: IList
list_1_2_3 = ICons 1 (ICons 2 (ICons 3 INil))   -- 1, 2, 3


-- >>> sumIlist list_1_2_3
-- 6

sumIlist :: IList -> Int
sumIlist (ICons x y) = x + sumIlist y
sumIlist INil        = 0



-- data List = Nil | Cons Int    List
-- data List = Nil | Cons Char   List
-- data List = Nil | Cons Double List

data List t = Nil | Cons t (List t)


type IL = List Int

ilist :: List Int
ilist = Cons 1 (Cons 2 (Cons 3 Nil))

type CharList = List Char
clist = Cons '1' (Cons '2' (Cons '3' Nil))

len :: List a -> Int
len Nil         = 0
len (Cons x xs) = 1 + len xs



{- 

doTwice doTwice => \f x ->  f (f (f (f x)))

doTwice f = \x -> f (f x)

doTwice doTwice = \x -> doTwice (doTwice x)

doTwice doTwice dubble

doTwice (doTwice dubble)


  ((doTwice doTwice) dubble) 10
  
  ==> ((\x -> doTwice (doTwice x)) dubble) 10
  ==> ((doTwice (doTwice dubble))) 10
  ==> (((doTwice dubble (doTwice dubble (10)))))
  ==> (((dubble (dubble (dubble (dubble (10)))))))

-}


