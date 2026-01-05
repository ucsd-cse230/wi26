{-# LANGUAGE DeriveFunctor #-}

module Lec_5_27_20 where

import Data.Char

-------------------------------------------------------------------------------
-- | A Type for Representing Parsers
-------------------------------------------------------------------------------

-- data Parser a = P (String -> (a, String))

data Parser a = P (String -> [(a, String)])
  deriving (Functor) 

runParser :: Parser a -> String -> [(a, String)]
runParser (P f) s = f s

-------------------------------------------------------------------------------
-- | `Parser` is a `Monad`
-------------------------------------------------------------------------------

forEach :: [a] -> (a -> [b]) -> [b]
forEach []     f = []
forEach (x:xs) f = f x ++ forEach xs f 


example = forEach [1,2,3] (\n -> 
            forEach [0, 1, 2] (\m -> 
              [n * 100 + m]  
            )
          )

-- >>> example
-- [100,101,102,200,201,202,300,301,302,200,201,202,300,301,302]
--

instance Monad Parser where
  return x     = P (\s_in -> [(x, s_in)]) 
  (>>=) pa fpb = P (\s0 ->
    forEach (runParser pa s0) (\(va, s1) -> 
      forEach (runParser (fpb va) s1) (\(vb, s2) ->
        [(vb, s2)]
        ) 
      ) 
    )

-------------------------------------------------------------------------------
-- | Combining Parsers
-------------------------------------------------------------------------------

oneChar :: Parser Char
oneChar = P (\cs -> case cs of
                      [] -> [] 
                      (c:cs') -> [(c, cs')])

-- >>> runParser oneChar "cat"
-- [('c',"at")]
--

pairP :: Parser a -> Parser b -> Parser (a, b)
pairP pa pb = do 
  va <- pa
  vb <- pb
  return (va, vb)

-- >>> runParser (pairP oneChar oneChar) "c"
-- []
--

failP :: Parser a 
failP = P (\_ -> [])

satP :: (Char -> Bool) -> Parser Char
satP p = do 
  c <- oneChar
  if p c then return c else failP


-- >>> runParser (satP (\c -> c == 'h')) "hellow" 
-- [('h',"ellow")]
--
-- >>> runParser (satP (\c -> c == 'h')) "yellow" 
-- []
--
-- >>> (\c -> c == 'h') 'h'
-- True

-- >>> runParser (char '+') "+dog" 
-- [('+',"dog")]
--

-- parse ONLY the Char c
char :: Char -> Parser Char
char c = satP (\c' -> c == c')


-- >>> isAlpha 'c'
-- True
--

-- >>> isAlpha '0'
-- False
--

-- >>> runParser (alphaChar) "-og" 
-- []
--

-- parse ANY ALPHABET 
alphaChar :: Parser Char
alphaChar = satP isAlpha



-- >>> runParser digitChar "9-og" 
-- [('9',"-og")]
--


-- parse ANY NUMERIC DIGIT
digitChar :: Parser Char
digitChar = satP isDigit

-- >>> read ['9'] :: Int
-- 9
--

-- string   []    = return []
-- string   (h:t) = do { c <- char h; cs <- string t; return (h:t) }

string :: String -> Parser String 
string cs = mapM char cs 

-- >>> :t mapM 
-- mapM :: (a -> Parser b) -> [a] -> Parser [b]
--


sequ :: [Parser a] -> Parser [a]
sequ []     = return []
sequ (p:ps) = do { v <- p; vs <- sequ ps; return (v:vs) }

-- >>> runParser (string "doge") "dogeral"
-- [("doge","ral")]
-- >>> runParser (string "doge") "doberman"
-- []

-- char 'd'; char 'o'; char 'g'; char 'e' 

-- >>> runParser (char 'g') "berman"
-- []
--



-- parses EXACTLY the String s and nothing else

catOrDog = orElse (string "cat") (string "dog")

-- >>> runParser catOrDog "caterPiller"
-- [("cat","erPiller")]
--

-- >>> runParser catOrDog "dogerPiller"
-- [("dog","erPiller")]
--

-- >>> runParser catOrDog "mousererPiller"
-- []
--

orElse :: Parser a -> Parser a -> Parser a
orElse p1 p2 = P (\cs -> 
  case runParser p1 cs of
    []  -> runParser p2 cs
    r1s -> r1s
  )

(<|>) p1 p2 = orElse p1 p2


intOp      :: Parser (Int -> Int -> Int) 
intOp      = plus <|> minus <|> times <|> divide 
  where 
    plus   = constP "+" (+) 
    minus  = constP "-" (-) 
    times  = constP "*" (*) 
    divide = constP "/" (div)  

digitInt :: Parser Int
digitInt = do
  c <- digitChar
  return (read [c])



calc :: Parser Int
calc = do 
  x  <- int 
  op <- intOp
  y  <- calc
  return (x `op` y)


calc0 ::  Parser Int
calc0 = binExp <|> int 
  where
    binExp :: Parser Int
    binExp = do
      x <- int 
      o <- intOp 
      y <- calc0 
      return (x `o` y) 

-- >>> runParser calc0 "10*2+100"
-- [(1020,"")]
--

parens :: Parser a -> Parser a
parens p = do
  _ <- char '('
  x <- p
  _ <- char ')'
  return x

calc1 :: Parser Int
calc1 = binExp <|> int 
  where 
    binExp = do
      x <- calc1
      o <- intOp 
      y <- int
      return (x `o` y)


oneOrMore :: Parser a -> Parser (a -> a -> a) -> Parser a
oneOrMore vP oP = do {v1 <- vP; continue v1}
  where 
    continue v1 = do { o <- oP; v2 <- vP; continue (v1 `o` v2) }
               <|> return v1

{- 
chainl vp op

PARSES
v1 o v2 o v3 o v4 o v5 

AS
(((v1 o v2) o v3) o v4) o v5)

10+(2*5)

-}

expr = zum
zum  = oneOrMore prod addOp
prod = oneOrMore base mulOp
base = parens expr <|> int

addOp, mulOp :: Parser (Int -> Int -> Int)
addOp = constP "+" (+) <|> constP "-" (-)
mulOp = constP "*" (*) <|> constP "/" div


{- 

   ((10 * 20) * 30) + (40 * 50) + ((60 * 70) * 80)
     (prod * 30) + prod + prod * 80
     (prod + prod) + prod
     sum + prod
     sum 




 -}


-- >>> runParser calc1 "((10*2)+100)"
-- [(120,"")]
--




{-

runParser (manyP digitChar)   STR 
runParser (m0 <|> m1)         STR 
runParser (return [] <|> m1)  STR 
runParser (return [])         STR 
[([], STR)] 







calc = digitInt >>= \x -> 
        intOp >>= \o ->
          digitInt >>= \y ->
            return (o x y)



-}

-- >>> runParser calc "881-25+94"
-- [(856,"+94")]
--
-- >>> runParser int "813e123"
-- [(813,"e123")]
--

int :: Parser Int
int = do 
  s <- manyP digitChar
  return (read s)

-- "1981cat"
-- (manyP digitChar) "cat"
-- [('1' : '9' : '8' : '1' : [] , "cat")]
manyP :: Parser a -> Parser [a]
manyP p = m1 `orElse` m0  
  where
    m1  = do { v <- p; vs <- manyP p; return (v:vs) }
    m0  = return []


-- >>> runParser (manyP digitChar) "123124DOG"
-- [("123124","DOG")]
--

-- \s -> []           FAILURE
-- \s -> [([], s)]    return []



-- "456"

constP :: String -> a -> Parser a 
constP s v = do { string s ; return v } 

-- e1 >> e2          do { _ <- e1; e2 }











instance Applicative Parser where
  pure x    = P (\s -> [(x, s)])
  fP <*> vP = P (\s -> forEach (runParser fP s) (\(f, s') ->
                         forEach (runParser vP s') (\(v, s'') -> 
                            [(f v, s'')]
                         )
                       )
                )

