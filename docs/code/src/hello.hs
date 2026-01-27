{- HLINT ignore "Use const" -}
{- HLINT ignore "Redundant lambda" -}
module Main where

type Recipe a = IO a

type Int2 = (Int, Int)
type Int3 = (Int, Int, Int)
type Int0 = ()

-- >>> 12 ++@++ 98
-- 110

(++@++) :: Int -> Int -> Int
(++@++) x y = x + y

-- >>> mousify "Ranjit"
-- "Ranjit Mouse"

mousify :: String -> String
mousify name = name ++ " Mouse"

main :: Recipe Int
main = do
    name <- pure "Mickey"
    let fullName = mousify name
    putStrLn ("hello, " ++ fullName)
    pure 7
-- main = queryLoop 0

queryLoop :: Int -> Recipe ()
queryLoop counter = do
    putStrLn (show counter ++ " who are youuu???")
    n <- getLine
    if n == "exit"
        then pure () -- putStrLn "Goodbye!!!"
        else do { putStrLn ("hello " ++ n); queryLoop (counter + 1) }

-- (>>=) e1 (\x -> e2)
--
-- do { x <- e1; e2 }


vanillaHello = combineListRecipes [r1, r2, r1, r2]
  where
    r1 = putStrLn "Hello, world!"
    r2 = putStrLn "Today is thu"

combineTwoRecipes :: Recipe a -> Recipe a -> Recipe a
combineTwoRecipes r1 r2 = do { r1 ; r2 }

combineListRecipes :: [Recipe a] -> Recipe a
combineListRecipes [r]    = r
combineListRecipes (r:rs) = do { r ; combineListRecipes rs }
combineListRecipes _      = error "DEATHU"

-- You can use `_` whenever you "don't care" about
-- the value being "defined" or "named" at a definition site,
-- e.g. pattern match, function argument, `let` etc.
getFst :: (a, b) -> a
getFst tup = case tup of
                (x1, _ ) -> x1

silly1 = \_ -> 0

silly2 _ = 0

{-

crack    :: Recipe Yolk
mkBatter :: Yolk -> Recipe Batter

bbb :: Recipe Batter
bbb = combine crack mkBatter

   Recipe Yolk -> (Yolk -> Recipe Batter) -> Recipe Batter

   (>>=) :: Recipe a -> (a -> Recipe b) -> Recipe b

   Recipe String -> (                 ) -> Recipe <that prints out the string...>

putStrLn "What is your name?"


getLine :: Recipe String
putStrLn ("Hello " ++ name ++ "!!!")

-}



-- >>> ffilter (\n -> n > 10) [11, 20, 5, 12 , 7]
-- [11,20,12]

------ [11, 20, 12]

ffilter :: (a -> Bool) -> [a] -> [a]
ffilter p []     = []
ffilter p (x:xs)
    | p x        = x : rest
    | otherwise  = rest
    where
        rest     = ffilter p xs


{-




foldr op b []     = b
foldr op b (x:xs) = op x (foldr op b xs)

foldr op b [x1,x2,x3,x4]
==>
x1 `op` (x2 `op` (x3 `op` (x4 `op` b)))

foldl op b []     = b
foldl op b (x:xs) = foldl op (b `op` x) xs

foldl'

foldl op b [x1, x2, x3, x4]
==>
foldl op (b `op` x1) [x2, x3, x4]
==>
foldl op ((b `op` x1) `op` x2) [x3, x4]
==>
foldl op (((b `op` x1) `op` x2) `op` x3) [x4]
==>
foldl op ((((b `op` x1) `op` x2) `op` x3) `op` x4) []
==>
((((b `op` x1) `op` x2) `op` x3) `op` x4)




-}
