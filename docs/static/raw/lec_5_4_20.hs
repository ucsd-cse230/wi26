

type Recipe a = IO a

main :: IO ()
main = do
    x <- return (incr 5)
    -- let x = incr 5
    putStrLn (show x)
-- realFunction :: In -> Out

incr :: Int -> Int
incr x = x + 1

-- main = rapp 1

i :: Int
i = i + 1

list :: Int -> [Int] 
list n = n : list (n+1)

nats = list 0

squareNats = map (\n -> n * n) nats

app :: Int -> IO ()
app n = do {
    putStrLn (show n ++ ". What is your name?");
    name <- getLine;
    case strToInt name of
        Nothing -> app (n+1) -- do { re <- app (n+1) ; -- do stuff with re } 
        Just n  -> if 1 <= n && n < 150 
                    then putStrLn ("Your age is: " ++ show n) 
                    else app (n+1)
    -- name <- getLine;
    -- putStrLn ("Hello, again " ++ name ++ "!");
    -- s <- getLine;
    -- putStrLn s
}

strToInt :: String -> Maybe Int
strToInt s = read s

oldmain = mysequence 
    [ putStrLn "hello"
    , putStrLn "beautiful"
    , putStrLn "world!" 
    ] 



-- mysequence [r1,r2,r3,r4] ==> do {r1; r2; r3; r4}

mysequence :: [Recipe ()] -> Recipe ()
mysequence []     = return ()
-- mysequence [r]    = do {r}
mysequence (r:rs) = do {r; mysequence rs}

-- mysequence [r1,r2]       = do {r1; r2}
-- mysequence [r1,r2,r3]    = do {r1; r2; r3}
-- mysequence [r1,r2,r3,r4] = do {r1; r2; r3; r4}

foo = do { r1; putStrLn "Beautiful!"; r2}

quiz = [r1, r2]

r1 :: IO ()
r1 = putStrLn "Hello!"

r2 :: IO ()
r2 = putStrLn "World!"

hello :: IO ()
hello = putStrLn "hello, world!"