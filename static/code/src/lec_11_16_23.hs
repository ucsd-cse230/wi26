{-# LANGUAGE InstanceSigs #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE UndecidableInstances #-}
{-# OPTIONS_GHC -Wno-unrecognised-pragmas #-}
{-# HLINT ignore "Use camelCase" #-}
{-# HLINT ignore "Replace case with maybe" #-}
{-# HLINT ignore "Use list comprehension" #-}
{-# HLINT ignore "Use newtype instead of data" #-}
{-# HLINT ignore "Use foldr" #-}
{-# OPTIONS_GHC -Wno-noncanonical-monad-instances #-}
{-# HLINT ignore "Use tuple-section" #-}
{-# HLINT ignore "Redundant return" #-}
{-# HLINT ignore "Use const" #-}
{-# HLINT ignore "Eta reduce" #-}
{-# HLINT ignore "Use lambda-case" #-}
{-# HLINT ignore "Avoid lambda" #-}

module Lec_11_16_23 where

import Prelude hiding (sum, getLine)
import Data.Char (isAlpha, isDigit)
import Test.QuickCheck
-- import Lec_10_17_23 (CircleT(xLoc))

default (Int, Float)

foo :: IO Char
foo = getChar

getLine :: IO String
getLine = do
    c <- getChar
    if c == '\n'
        then return ""
        else do cs <- getLine
                return (c:cs)








data Parser a = MkParser (String -> [(a, String)])

runParser :: Parser a -> String -> [(a, String)]
runParser (MkParser f) s = f s

-- >>> runParser twoChar'' "123"
-- [(('1','2'),"3")]



oneChar :: Parser Char
oneChar = MkParser (\cs -> case cs of
                             [] -> []
                             (c:cs') -> [(c, cs')]
                   )

twoChar :: Parser (Char, Char)
twoChar = MkParser (\cs -> case cs of
                             (c1:c2:cs') -> [((c1, c2), cs')]
                             _ -> []
                   )

twoChar' :: Parser (Char, Char)
twoChar' = pairP oneChar oneChar

twoChar'' :: Parser (Char, Char)
twoChar'' = do
    x <- oneChar
    y <- oneChar
    return (x, y)



forEach :: [a] -> (a -> [b]) -> [b]
forEach []     _ = []
forEach (x:xs) f = f x ++ forEach xs f

pairP :: Parser a -> Parser b -> Parser (a, b)
pairP (MkParser aP) (MkParser bP) = MkParser (\cs ->
    forEach (aP cs) (\(a, cs') ->
        forEach (bP cs') (\(b, cs'') ->
                [((a, b), cs'')]
            )
        )
    )

instance Monad Parser where
    return :: a -> Parser a
    return = returnP
    (>>=) :: Parser a -> (a -> Parser b) -> Parser b
    (>>=)  = bindP

returnP :: a -> Parser a
returnP x = MkParser (\str -> [(x, str)])

bindP :: Parser a -> (a -> Parser b) -> Parser b
bindP (MkParser aP) fB = MkParser (\cs ->
    forEach (aP cs) (\(a, cs') ->
        let MkParser bP = fB a in
        forEach (bP cs') (\(b, cs'') ->
                [(b, cs'')]
            )
        )
    )


failP :: Parser a
failP = MkParser (\_ -> [])

instance Functor Parser where
    fmap = undefined

instance Applicative Parser where
    pure = undefined
    (<*>) = undefined

satP :: (Char -> Bool) -> Parser Char
satP p = do
    c <- oneChar
    if p c then return c else failP


satP' :: (Char -> Maybe a) -> Parser a
satP' p = do
    c <- oneChar
    case p c of
        Just v -> return v
        Nothing -> failP


-- >>> runParser alphaCharP "cat"

-- >>> runParser digitCharP "cat"


-- >>> runParser digitCharP "67cat"
-- [('6',"7cat")]

-- >>> runParser digitIntP "62567cat"
-- []

char :: Char -> Parser Char
char c = satP (\c' -> c == c')

alphaCharP :: Parser Char
alphaCharP = satP isAlpha

digitCharP :: Parser Char
digitCharP = satP isDigit

-- >>> runParser

-- >>> runParser alphaDigitCharP "8q9w8c98"
-- [('8',"q9w8c98")]

-- >>> runParser calc "3+4sldfnas"
-- [(7,"sldfnas")]

-- >>> runParser calc "510-212"
-- [(3,"")]

-- >>> runParser calc "52*23"
-- [(10,"")]

-- >>> runParser calc "500/2"
opP :: Parser (Int -> Int -> Int)
opP = plusP <|> minusP <|> timesP <|> divP
  where
    plusP = do {_ <- char '+'; return (+) }
    minusP = do {_ <- char '-'; return (-) }
    timesP = do {_ <- char '*'; return (*) }
    divP = do {_ <- char '/'; return div }

{-
do {x <- e1 ; e2 }          IS THE SAME AS e1 >>= (\x -> e2)

do {_ <- e1 ; e2 }          IS THE SAME AS e1 >> e2

do { e1 ; e2 }              IS THE SAME AS e1 >> e2

-}

calc :: Parser Int
calc = do
    x <- intP
    o <- opP
    y <- intP
    return (x `o` y)




alphaDigitCharP :: Parser Char
alphaDigitCharP = alphaCharP <|> digitCharP


(<|>) :: Parser a -> Parser a -> Parser a
(<|>) = orElse

orElse :: Parser a -> Parser a -> Parser a
orElse p1 p2 = MkParser (\cs ->
    case runParser p1 cs of
        [] -> runParser p2 cs
        rs -> rs
    )

digitIntP :: Parser Int
digitIntP = do
    c <- satP isDigit
    return (read [c])

-- >>> runParser intP "123,45,6"
-- [(123,",45,6")]

manyP :: Parser a -> Parser [a]
manyP aP = many1P aP <|> return []

-- many1P tries to parse a NON-EMPTY list of [a]
many1P :: Parser a -> Parser [a]
many1P aP = do
    x <- aP
    xs <- manyP aP
    return (x:xs)

-- >>> runParser (manyP digitCharP) "84839lksflasjfl923849234"
-- [("84839","lksflasjfl923849234")]




-- >>> runParser intP "cat"
-- []

intP :: Parser Int
intP = do
    cs <- many1P digitCharP
    return (read cs)

-- >>> runParser calc0 "10 - 5 - 5"
-- [(10,"")]

intP' :: Parser Int
intP' = do
    _ <- spaces
    x <- intP
    _ <- spaces
    return x

spaces :: Parser [Char]
spaces = manyP (char ' ')

calc0 :: Parser Int
calc0 = binExp <|> intP'

binExp :: Parser Int
binExp = do
    x <- intP'
    o <- opP
    y <- calc0
    return (x `o` y)

-- >>> runParser calc1 "((100*10)+2"
-- []

calc1 :: Parser Int
calc1 = binExp1 <|> intP'

parens :: Parser a -> Parser a
parens aP = do
    _ <- char '('
    a <- aP
    _ <- char ')'
    return a

binExp1 :: Parser Int
binExp1 = parens (do
    x <- calc1
    o <- opP
    y <- calc1
    return (x `o` y)
    )

-- >>> runParser calc2 "10-2-2"

-- calc2 :: Parser Int
-- calc2 = binExp2 <|> intP'

-- binExp2 :: Parser Int
-- binExp2 = do
--     x <- calc2
--     o <- opP
--     y <- intP'
--     return (x `o` y)

-- >>> runParser calc2 "10-2-2"
-- [(6,"")]
calc2 :: Parser Int
calc2 = sum

sum :: Parser Int
sum = chainl prod addP

prod :: Parser Int
prod = chainl base mulP

base :: Parser Int
base = intP <|> parens calc2




chainl :: Parser b -> Parser (b -> b -> b) -> Parser b
chainl bP oP = do {x <- bP; continue x}
  where
    continue n = do { o <- oP; y <- bP; continue (n `o` y) } <|> return n


{-
prod = do {x <- base; continue x}
  where
    continue n = do { o <- mulP; y <- base; continue (n `o` y) } <|> return n

sum = do {x <- prod; continue x}
  where
    continue n = do { o <- addP; y <- prod; continue (n `o` y) } <|> return n

-}


-- >>> runParser calc2 "100+2*2"
-- [(104,"")]

-- n1 * n2 * n3 * n4

mulP :: Parser (Int -> Int -> Int)
mulP = timesP <|> divP
  where
    timesP = do {_ <- char '*'; return (*) }
    divP = do {_ <- char '/'; return div }

addP :: Parser (Int -> Int -> Int)
addP = plusP <|> minusP
  where
    plusP = do {_ <- char '+'; return (+) }
    minusP = do {_ <- char '-'; return (-) }






-- >>> quickCheck prop_revapp
prop_revapp :: [Int] -> [Int] -> Bool
prop_revapp xs ys =
    reverse (xs ++ ys) == reverse ys ++ reverse xs
-- [x1,x2,x3, y1,y2,y3]

quickCheckN :: Testable prop => Int -> prop -> IO ()
quickCheckN n = quickCheckWith (stdArgs {maxSuccess = n})

-- >>> qs [3,1,2,7,4]
-- getLinkDeps: Home module not loaded Lec_10_17_23 cse230-code-0.1.0.0-inplace

qs :: Ord a => [a] -> [a]
qs [] = []
qs (x:xs) = qs ls ++ [x] ++ qs rs
  where
    ls = [y | y <- xs, y <= x]
    rs = [y | y <- xs, x < y]

prop_qs_num_elems :: [Int] -> Bool
prop_qs_num_elems xs = length xs == length (qs xs)


randomThings :: (Arbitrary a) => IO [a]
randomThings = sample' arbitrary
