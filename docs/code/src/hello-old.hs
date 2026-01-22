module Main where
import System.Posix.Internals (puts)
import Text.Printf

type Recipe a = IO a

-- Recipe Int

main :: IO ()
main = do
    name <- mustGetLine 1
    putStrLn ("Hello, " ++ name ++ "!")

mustGetLine :: Int -> Recipe String
mustGetLine i = do
    putStrLn (printf "(%d) What is your name?" i)
    str <- getLine
    if str == ""
        then mustGetLine (i+1)
        else return str

-- >>> (10,"banana") < (10,"apple")
-- False


main0 = seqMany [putStrLn "This", putStrLn "That", putStrLn "Hello, world"]

rec12 = do { rec1 ; rec2 }

seqMany :: [Recipe ()] -> Recipe ()
seqMany = foldr1 (>>)

-- >>> foldr1 (+) []
-- Prelude.foldr1: empty list



foo z = z + 1
bob = foo
-- seqMany [r]    = r
-- seqMany (r:rs) = r >> seqMany rs


{-
main = combine rec1 rec2

combine ::  Recipe a -> Recipe b -> Recipe b

recs = [Recipe ()]
recs = [ rec1 , rec2 ]

sequenceManyRecipes    [r2,r3] =       r2 >> r3
sequenceManyRecipes [r1,r2,r3] = r1 >> r2 >> r3

foldr op b (x1:x2:x3:Nil)
==>

(x1 `op` x2 `op` x3 `op` b)

(>>)
 -}

-- putStrLn :: String -> Recipe ()
rec1 :: Recipe ()
rec1 = putStrLn "hello, world"

rec2 :: Recipe ()
rec2 = putStrLn "this is also great"
