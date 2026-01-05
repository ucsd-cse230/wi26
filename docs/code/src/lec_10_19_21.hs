-- TODAY
module Lec_10_19_21 where

import Text.Printf (printf)
main :: IO ()
main = do
    return () -- putStrLn "Hello!" 
    return () -- putStrLn "World!" 

-- return :: a -> Recipe a

app = loop 1

loop :: Int -> IO ()
loop n = do {
    putStrLn (printf "(%d) What is your name?" n); 

    name <- getLine;
    -- 
    if null name 
        then loop (n + 1) 
        else putStrLn ("Hello, " ++ name)
    -- 
}

range :: Int -> Int -> [Int]
range i j = if i <= j then i : range (i+1) j else []


plus :: Num a => a -> a -> a
plus x y = x + y

leq :: Ord a => a -> a -> Bool
leq x y = x <= y

{- 

class Monad m where
  (>>=)  :: m a -> (a -> m b) -> m b
  return :: a -> m a
-}

-- >>> leq ['9'.1" "10"
-- False

quiz = 
  range 1 3 >>= \i ->
    range i 3 >>= \j -> 
      return (i, j)

foo = (+)

-- >>> quiz
-- [(1,1),(1,2),(1,3),(2,2),(2,3),(3,3)]

{- -}

-- [ i * i for i in range(1, 10) ]
-- >>> [ i * i | i <- [1..10] ]
-- [1,4,9,16,25,36,49,64,81,100]




silly :: IO ()
silly =
    putStrLn "What is your name?" >> 
      getLine >>= \name -> 
          putStrLn ("Hello, " ++ name)

drain = runEach 
  [ putStrLn "Yello"
  , putStrLn "Fello"
  , putStrLn "Jello"
  , putStrLn "Hello"
  , putStrLn "World!" 
  ]
 
blob = do {
    putStrLn "Hello";
    putStrLn "Hello";
    putStrLn "Hello";
    putStrLn "Hello";
    putStrLn "World!" 
  } 
    
-- runEach [putStrLn "Hello", putStrLn "World"]
runEach :: [IO ()] -> IO ()
runEach = foldr (>>) (return ())
-- runEach []     = return () 
-- runEach (r:rs) = r >> runEach rs


-- runEach [r1,r2,r3,r4,r5] = r1 >> r2 >> r3 >> r4 >> r5
-- runEach [] = error "need_recipe_that_does_nothing"


{- 
r            :: IO ()
runEach rs   :: IO ()
r >> runEach :: IO ()

(>>) :: IO () -> IO () -> IO ()

r >> runEach rs 

(>>=) :: IO a -> (a -> IO b) -> IO b


1. putStrLn "What is your name?"    :: IO ()
2. getLine                          :: IO String 
3. >>= \name -> putStrLn ("Hello " ++ name)


-}