module Lec_4_20_20 where


-- >>> copy3 15
-- [15,15,15]
--

-- >>> copy3 "horse" 
-- ["horse","horse","horse"]
--


copy3 :: t -> [t]
copy3 x = [x, x, x]

-- List.hs from HW1


--  List<T> clone<T>(int n, thing T) {...}

clone :: Int -> a -> [a]
clone 0 x = []
clone n x = x:clone (n-1) x


-- >>> clone 4 (3.14, "horse")
-- [(3.14,"horse"),(3.14,"horse"),(3.14,"horse"),(3.14,"horse")]
--

range :: Int -> Int -> [Int]
range x y 
  | x > y = [] 
  | True   = x : range (x+1) y


-- range 0 3

-- ==> if 0 > 3 then [] else 0 : range 1 3

-- ==> 0 : range 1 3

-- ==> 0 : if 1 > 3 then [] else 1 : range 2 3
-- ==> 0 : 1 : range 2 3
-- ==> 0 : 1 : 2 : range 3 3
-- ==> 0 : 1 : 2 : 3: range 4 3
-- ==> 0 : 1 : 2 : 3: []

-- >>> range 4 3 
-- []
--


--
-- >>> range 3 3 
-- [3]
-- 
-- >>> range 2 3 
-- [2,3]
-- 
-- >>> range 1 3 
-- [1, 2, 3]
-- 
-- >>> range 0 3 
-- [0, 1, 2, 3]

firstElem' def []      = def 
firstElem' def (x : _) = x

{- 
firstElem xs = case xs of 
                 [] -> 0
                 (x:_) -> x
-}

secondElem d []      = d
secondElem d (_:[])  = d
secondElem d (_:x:_) = x


{- 
    foo : bar 

    x1 : x2 : x3 : x4 : x5 : x6 : rest
    
    x1 : (x2 : (x3 : (x4 : (x5 : (x6 : rest)))))


     _ : x : _ 

     _ : (x : _ )

     1 : (2 : ( 3 : (4 : (5 : []))))

    [1,2,3,4,5]



 -}
