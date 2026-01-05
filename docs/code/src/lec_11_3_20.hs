
import Prelude hiding (sequence)
import Data.IORef

type Recipe a = IO a

main :: Recipe () 
main = do 
  counter <- newIORef 0 
  hello counter

list_unit :: [()]               -- Recipe ()
list_unit = [(), (), (), ()]

list_int :: [Int]               -- Recipe a
list_int = [1,2,3,4]

hello :: IORef Int -> Recipe () 
hello counter = do 
  n <- readIORef counter
  putStrLn $ "(" ++ show n ++ ") What is your name?"
  yourName <- getLine
  if isEmpty yourName 
      then do { writeIORef counter (n+1) ; hello counter }                    -- :: Recipe ()
      else putStrLn ("Hello " ++ yourName)

-- return :: value -> Recipe value
myName :: Recipe String 
myName = return "Sean Connery"
{- 
  if cond
      then recipe1 
      else recipe2

 -}

isEmpty :: String -> Bool
isEmpty s = length s == 0






sequ [r] = r
sequ (r:rs) = do {r; sequ rs}

-- sequence :: [Recipe a] -> Recipe a
-- sequence rs = foldr1 seq2 rs 

seq2 :: Recipe a -> Recipe b -> Recipe (a, b)
seq2 ra rb = do 
  xa <- ra
  xb <- rb
  return (xa, xb)

sillyRecipe :: Recipe String
sillyRecipe = return "I am a silly String"

{- 
seq [r1, r2, r3]
==>  r1 `do` r2 `do` r3
==> do {r1 ; seq [r2, r3]}
==> do {r1 ; do {r2; seq [r3] } } 
==> do {r1 ; do {r2; r3 } } 
-}