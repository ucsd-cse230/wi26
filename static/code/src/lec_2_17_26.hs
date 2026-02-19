{- HLINT ignore "Eta reduce" -}
{- HLINT ignore "Use uncurry" -}
{- HLINT ignore "Use :" -}
{- HLINT ignore "Use id" -}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE InstanceSigs #-}
{- HLINT ignore "Use <$>" -}
{- HLINT ignore "Use lambda-case" -}
{- HLINT ignore "Use const" -}
{- HLINT ignore "Use >>" -}
{- HLINT ignore "Use tuple-section" -}
{- HLINT ignore "Use newtype instead of data" -}
{- HLINT ignore "Use list comprehension" -}
{- HLINT ignore "Use >=>" -}
{- HLINT ignore "Redundant return" -}
{- HLINT ignore "Avoid lambda" -}
{- HLINT ignore "Use map" -}

module Lec_2_17_26  where
import Data.Map
import Data.Maybe (fromMaybe)
import Data.Char (isDigit)

{-

data Parser a = MkParser (String -> [(a, String)])
data ST s   a = MkST     (s -> (s , a))

-}

data Parser a = MkParser (String -> [(a, String)])

instance Functor Parser where
instance Applicative Parser where
instance Monad Parser where
    return :: a -> Parser a
    return = returnP
    (>>=) :: Parser a -> (a -> Parser b) -> Parser b
    (>>=) = bindP

returnP :: a -> Parser a
returnP x = MkParser (\str -> [(x, str)])

forEach :: [a] -> (a -> [b]) -> [b]
forEach xs f = concatMap f xs
--  foo >>= \x -> bar       IS      do {x <- foo; bar}

bindP :: Parser a -> (a -> Parser b) -> Parser b
bindP (MkParser pa) f_pb = MkParser (\str ->
       do (a, str') <- pa str
          let MkParser pb = f_pb a
          pb str'
    )

-- bindP (MkParser pa) f_pb = MkParser (\str ->
--     forEach (pa str) (\(a, str') ->
--         let MkParser pb = f_pb a in
--         pb str'
--         )
--     )

-- >>> runParser char2 "bobberington"
-- [(('b','o'),"bberington")]


runParser :: Parser a -> String -> [(a, String)]
runParser (MkParser f) s = f s

char1 :: Parser Char
char1 = MkParser (\str -> case str of
                            (c:cs) -> [(c, cs)]
                            _      -> []
                 )

---------

char2 :: Parser (Char, Char)
char2 = do
    c1 <- char1
    c2 <- char1
    return (c1, c2)

---------

failP :: Parser a
failP = MkParser (\_ -> [])

satP :: (Char -> Bool) -> Parser Char
satP validChar = do
    c <- char1
    if validChar c
        then return c
        else failP

-- >>> :i mapM
--   mapM :: Monad m => (a -> m b) -> [a] -> m [b]
--   ...
--   	-- Defined in ‘GHC.Internal.Data.Traversable’


-- ['c', 'a', 't', 'e', 'r', 'p']
exactlyThis :: String -> Parser String
exactlyThis []     = return ""
exactlyThis (c:cs) = do
    c1 <- char1
    if c1 == c
        then do { res <- exactlyThis cs; return (c:res) }
        else failP

-- ['c', 'a', 't'] ----> [ Parser 'c', Parser 'a', Parser 't' ]
-- [Char] -> [Parser Char]      map (\c -> satP (== c)) cs
-- [Parser Char] -> Parser [Char]

-- >>> runParser (exactlyThis "cat") "caterpillar"
-- [("cat","erpillar")]

-- ProgressCancelledException
-- (a) [("", "erpillar")]
-- (b) [("", "caterpillar")]
-- (c) [(('c', 'a', 't'), "erpillar")]
-- (d) []
-- (e) [("t", "erpillar")]


-- >>> runParser (str "cat") "caterpillar"
-- [("cat", "erpillar")]
-- >>> runParser (str "cat") "coterpillar"
-- []



bob :: Char -> Bool
bob = isDigit

-- >>> runParser ego "BobRanjit1231231"
-- []

ego :: Parser String
ego = orElse (exactlyThis "Ranjit") (exactlyThis "Jhala")

orElse :: Parser a -> Parser a -> Parser a
orElse p1 p2 = MkParser (\str ->
  case runParser p1 str of
    [] -> runParser p2 str
    r1s -> r1s
  )


-- do { _ <- e1; e2 }
-- e1 >> e2


myDigit :: Parser Char
myDigit = satP isDigit

-- >>> runParser (menny myDigit) "123876,ahskdhfoasdf5"
-- [("123876", ",ahskdhfoasdf5")]

-- >>> runParser (menny myDigit) "xyz123876,ahskdhfoasdf5"
-- [("", "xyz123876,ahskdhfoasdf5")]

-- menny :: Parser a -> Parser [a]

mennyP :: Parser a -> Parser [a]
mennyP p = m1 `orElse` m0
  where
    m0  = return []
    m1  = do { x <- p; xs <- manyP p; return (x:xs) }

-- >>> runParser (mennyP myDigit) "123horse"
-- [("123","horse")]

myInt :: Parser Int
myInt = do
  cs <- mennyP myDigit
  return (read cs)

-- runParser expP "10+20+30dog"
-- [(60, "dog")]

exactChar :: Char -> Parser Char
exactChar c = satP (== c)

operator :: Parser (Int -> Int -> Int)
operator =
  do { _ <- exactChar '+'; return (+) }
  `orElse`
  do { _ <- exactChar '-'; return (-) }
  `orElse`
  do { _ <- exactChar '*'; return (*) }

-- >>> runParser toddlerExpr "(10+20)*30"
-- Prelude.read: no parse

-- (((n1 o1 n2) o2 n3) o3 n4)

myParenP :: Parser a -> Parser a
myParenP p = do
  _ <- exactChar '('
  x <- p
  _ <- exactChar ')'
  return x

babyExpr :: Parser Int
babyExpr = do
  n1 <- myInt
  op <- operator
  n2 <- myInt
  return (op n1 n2)

toddlerExpr :: Parser Int
toddlerExpr = do
  n <- baseExpr
  opNums <- mennyP opNum
  return (combine n opNums)

baseExpr :: Parser Int
baseExpr = myParenP toddlerExpr `orElse` myInt

combine :: Int -> [(Op, Int)] -> Int
combine n [] = n
combine n ((op, n1):rest) = combine (op n n1) rest

type Op = (Int -> Int -> Int)
opNum :: Parser (Op, Int)
opNum = do
  o <- operator
  n <- baseExpr
  return (o, n)

pair :: Parser a -> Parser b -> Parser (a, b)
pair p1 p2 = do
  x1 <- p1
  x2 <- p2
  return (x1, x2)

--------------------------------------------------------------------
sumP :: Parser Int
sumP = do
  e1    <- prodP
  prods <- mennyP (pair sumOp prodP) -- sumProd
  return (combine e1 prods)

prodP :: Parser Int
prodP = do
  e1 <- atomP
  facts <- mennyP (pair prodOp atomP)
  return (combine e1 facts)

atomP :: Parser Int
atomP = myParenP sumP `orElse` myInt

sumOp :: Parser (Int -> Int -> Int)
sumOp = (char '+' >> return (+)) `orElse` (char '-' >> return (-))

prodOp :: Parser (Int -> Int -> Int)
prodOp = (char '*' >> return (*)) `orElse` (char '/' >> return div)

-- >>> runParser sumP "10+2*3"
-- [(23,"")]
--------------------------------------------------------------------


-- >>> runParser digitP "99horse"
-- [(9,"9horse")]

digitP :: Parser Int
digitP = do
  c <- satP isDigit
  return (read [c])

char :: Char -> Parser Char
char c = satP (== c)












(<|>) :: Parser a -> Parser a -> Parser a
(<|>) (MkParser p1) (MkParser p2) = MkParser
    (\s -> case p1 s of
       [] -> p2 s
       rs -> rs
    )



-- 1. First, parse the operator
intOp      :: Parser (Int -> Int -> Int)
intOp      = plus <|> minus <|> times <|> divide
  where
    plus   = do { _ <- char '+'; return (+) }
    minus  = do { _ <- char '-'; return (-) }
    times  = do { _ <- char '*'; return (*) }
    divide = do { _ <- char '/'; return div }

-- 2. Now parse the expression!
calc :: Parser Int
calc = do
  x  <- digitP
  op <- intOp
  y  <- digitP
  return (x `op` y)

-- >>> runParser calc "92dog"
-- []


manyP  :: Parser a -> Parser [a]
manyP p = m1 <|> m0
  where
    m0  = return []
    m1  = do { x <- p; xs <- manyP p; return (x:xs) }

int :: Parser Int
int = do
  xs <- manyP (satP isDigit)
  return (read xs)

--------------------------------------------------------------------------------------------------------

-- >>> runParser (manyP digitP) "92824dog"
-- [([9,2,8,2,4],"dog")]

calc0 ::  Parser Int
calc0 = binExp0 <|> int

binExp0 :: Parser Int
binExp0 = do
  x <- int
  o <- intOp
  y <- calc0
  return (x `o` y)

--------------------------------------------------------------------------------------------------------

parens :: Parser a -> Parser a
parens p = do
    _ <- char '('
    x <- p
    _ <- char ')'
    return x

calc1 :: Parser Int
calc1 = parens binExp1 <|> int

binExp1 :: Parser Int
binExp1 = do
  x <- calc1
  o <- intOp
  y <- calc1
  return (x `o` y)

-- >>> runParser calc1 "(10-(5-5))"
-- [(10,"")]

--------------------------------------------------------------------------------------------------------
