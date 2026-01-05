{-# LANGUAGE DeriveFunctor #-}

module Parsers where

import Data.Char

data Parser a = P (String -> [(a, String)])
  deriving (Functor) 

runParser :: Parser a -> String -> [(a, String)]
runParser (P f) s = f s








oneChar :: Parser Char
oneChar = P (\cs -> case cs of 
                      c:cs' -> [(c, cs')]
                      _     -> [])

-- >>> runParser oneChar "foo"
-- [('f',"oo")]
--
                    
twoChars :: Parser (Char, Char)
twoChars = P (\cs -> case cs of 
                      c1:c2:cs' -> [((c1, c2), cs')]
                      _         -> []
             )
-- >>> runParser twoChars "foo"
-- [(('f','o'),"o")]

forEach xs f = concatMap f xs 

instance Monad Parser where
    return x = P (\s -> [(x, s)])
    p >>= f  = P (\s -> forEach (runParser p s) (\(a, s') ->
                          forEach (runParser (f a) s') (\(b, s'') ->
                              [(b, s'')]
                 ))) 


(<|>) :: Parser a -> Parser a -> Parser a
p1 <|> p2 = P (\s -> case runParser p1 s of
                            []  -> runParser p2 s
                            r1s -> r1s)


satP :: (Char -> Bool) -> Parser Char
satP p = do 
  c <- oneChar
  if p c then return c else failP

failP :: Parser a
failP = P (\_ -> [])

char :: Char -> Parser Char
char c = satP (c ==) 

digitChar :: Parser Char 
digitChar = satP isDigit


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
calc = do x  <- int 
          op <- intOp
          y  <- int 
          return (x `op` y)

-- >>> runParser digitInt "1"
-- [(1,"")]
--

string s = mapM char s

parens p = do 
    string "("
    x <- p
    string ")"
    return x

-- | `manyP p` repeatedly runs `p` to return a list of [a]
manyP  :: Parser a -> Parser [a]
manyP p = m1 <|> m0
  where
    m0  = return [] 
    m1  = do { x <- p; xs <- manyP p; return (x:xs) } 

int :: Parser Int
int = do { xs <- manyP digitChar; return (read xs) }

-- >>> runParser int "123horse"
-- [(123,"horse")]


expr = oneOrMore prod addOp
prod = oneOrMore base mulOp 
base = parens expr <|> int

-- >>> runParser expr "10-5-5"
-- [(0,"")]
--
-- >>> runParser expr "10*(2+100)"
-- [(1020,"")]

addOp, mulOp :: Parser (Int -> Int -> Int)
addOp  = constP "+" (+) <|> constP "-" (-)
mulOp = constP "*" (*) <|> constP "/" div

constP :: String -> a -> Parser a 
constP s x = do { _ <- string s; return x }

oneOrMore :: Parser a -> Parser (a -> a -> a) -> Parser a
oneOrMore vP oP = do {v1 <- vP; continue v1}
  where 
    continue v1 = do { o <- oP; v2 <- vP; continue (v1 `o` v2) }
               <|> return v1


instance Applicative Parser where
    pure x    = P (\s -> [(x, s)])
    fP <*> vP = P (\s -> forEach (runParser fP s) (\(f, s') ->
                           forEach (runParser vP s') (\(v, s'') -> 
                               [(f v, s'')]
                            )
                         )
                  )