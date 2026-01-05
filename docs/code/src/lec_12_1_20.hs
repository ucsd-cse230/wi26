{-# LANGUAGE DeriveFunctor #-}
{-# LANGUAGE FlexibleInstances #-}

module Lec_12_1_20 where

import Data.Char
-- import Prelude hiding (return, (>>=))
import qualified Data.Map as M

------------------------------------------------

data Parser a = P (String -> [(a, String)])

runParser :: Parser a -> String -> [(a, String)]
runParser (P fn) str = fn str

oneChar :: Parser Char
oneChar = P (\cs -> case cs of
                      [] -> [] 
                      (c:cs') -> [(c, cs')])

-- twoChar :: Parser (Char, Char)
-- twoChar = P (\cs -> case cs of 
--                      []      -> []
--                      [_]     -> [] 
--                      c1:c2:cs' -> [((c1, c2), cs')])

twoChar :: Parser (Char, Char)
twoChar = pairP oneChar oneChar


pairP :: Parser a -> Parser b -> Parser (a, b)
pairP aP bP = do 
  a <- aP
  b <- bP
  return (a, b)

-- >>> runParser twoChar "high"
-- [(('h','i'),"gh")]

returnP :: a -> Parser a
returnP a = P (\s -> [(a, s)])

bindP :: Parser a -> (a -> Parser b) -> Parser b
bindP aP f_bP = P (\cs -> forEach (runParser aP cs) (\(a, cs') -> 
                            forEach (runParser (f_bP a) cs') (\ (b, cs'') -> 
                              [(b, cs'')]
                            )
                          )
                  )
                
instance Monad Parser where
  return = returnP
  (>>=)  = bindP




forEach :: [a] -> (a -> [b]) -> [b]
forEach []     f = []
forEach (x:xs) f = f x ++ forEach xs f


-- >>> forEach [10, 20, 30] (\i -> [show i, show (i+1)])
-- ["10","11","20","21","30","31"]


quiz :: [(Integer, Integer, Integer)]
quiz = forEach [10, 20, 30] (\i -> 
         forEach [0, 1, 2] (\j -> 
           forEach [100, 200, 300] (\k -> 
             [(i, j, k)] 
           )
         )
       )

-- >>> quiz
-- [(10,0,100),(10,0,200),(10,0,300),(10,1,100),(10,1,200),(10,1,300),(10,2,100),(10,2,200),(10,2,300),(20,0,100),(20,0,200),(20,0,300),(20,1,100),(20,1,200),(20,1,300),(20,2,100),(20,2,200),(20,2,300),(30,0,100),(30,0,200),(30,0,300),(30,1,100),(30,1,200),(30,1,300),(30,2,100),(30,2,200),(30,2,300)]




-- >>> parseExpr "1975 + 2 * 7"
-- 24

failP :: Parser a
failP = P (\_ -> [])


satP :: (Char -> Bool) -> Parser Char
satP p = do
  c <- oneChar
  if p c then return c else failP


char :: Char -> Parser Char
char x = satP (\c -> c == x)

alphaP :: Parser Char
alphaP = satP isAlpha

digitP :: Parser Char
digitP = satP isDigit

-- >>> runParser (satP (\c -> c == 'h')) "yellow"
-- []

strP :: String -> Parser String 
strP []     = return "" -- parses EXACTLY the String s and nothing else
strP (c:cs) = do 
  char c
  strP cs
  return (c:cs)

-- >>> runParser (strP "doge") "dogedogeral"
-- [("doge","dogeral")]

orElse :: Parser a -> Parser a -> Parser a
orElse p1 p2 = P (\cs -> case runParser p1 cs of
                            [] -> runParser p2 cs 
                            res -> res
                 )

(<|>) :: Parser a -> Parser a -> Parser a
p1 <|> p2 = orElse p1 p2

alphaNumCharP :: Parser Char
alphaNumCharP = alphaP <|> digitP

-- >>> runParser  alphaNumCharP "9horse"
-- [('9',"horse")]

-- 1. First, parse the operator 
intOp      :: Parser (Int -> Int -> Int) 
intOp      = plus <|> minus <|> times <|> divide 

plus   = charConstP '+' (+) 
minus  = charConstP '-' (-) 
times  = charConstP '*' (*) 
divide = charConstP '/' div


charConstP :: Char -> a -> Parser a
charConstP c v = do { _ <- char c; return v }

-- constP :: String -> a -> Parser a





digitIntP :: Parser Int
digitIntP = do
  x <- digitP
  return (read [x])

-- 2. Now parse the expression!
calc :: Parser Int
calc = do 
  x  <- intP 
  op <- intOp
  y  <- intP 
  return (x `op` y)

-- >>> runParser calc "10+20+5"
-- [(30,"-5")]

intP :: Parser Int
intP = do 
  xs <- manyP digitP 
  return (read xs)



-- >>> runParser (manyP digitP) "123horse"
-- [("123","horse")]

manyP :: Parser a -> Parser [a]
manyP p = atLeastOne <|> return [] 
  where
    atLeastOne = do 
      x  <- p
      xs <- manyP p
      return (x:xs)

calc0 ::  Parser Int
calc0 = binExp <|> intP 


parensP :: Parser a -> Parser a
parensP p = do
  _ <- char '('
  x <- p
  _ <- char ')'
  return x

calc1 :: Parser Int
calc1 = parensP binExp <|> intP

binExp :: Parser Int
binExp = do 
  x  <- calc1
  op <- intOp
  y  <- calc1
  return (x `op` y)

-- >>> runParser calc1 "(2+2)"
-- [(4,"")]

-- >>> "(((n1+n2)+n3)+n4)" 

-- >>> runParser calc2 "2+2"
-- ProgressCancelledException

calc2 :: Parser Int
calc2 = sumP

sumP :: Parser Int 
sumP  = oneOrMore prodP (plus <|> minus)

prodP :: Parser Int 
prodP = oneOrMore baseP (times <|> divide)

baseP :: Parser Int
baseP = parensP calc2 <|> intP

-- x1 o x2 o x3 o x4 ===> (((x1 `o` x2) `o` x3) `o` x4) 

oneOrMore :: Parser a -> Parser (a -> a -> a) -> Parser a
oneOrMore p op = do { l <- p; continue l }
  where 
    continue l =  do {o <- op; r <- p; continue (l `o` r) } 
              <|> return l


-- >>> runParser calc2 "10*2+100" 
-- [(120,"")]































instance Functor Parser where
instance Applicative Parser where









