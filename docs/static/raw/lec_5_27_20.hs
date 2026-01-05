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

{- 
 "hello"

 [c1,c2,c3,c4,c5]

 do char c1 
    char c2 
    char c3 
    char c4 
    char c5 
    return [c1,c2,c3,c4,c5]


   map char [c1,c2,c3] 

   [char c1, char c2, char c3] :: [Parser Char]



 -}

string :: String -> Parser String 
string cs = mapM char cs -- sequ (map char cs) 

-- >>> :t mapM 
-- mapM :: (a -> Parser b) -> [a] -> Parser [b]
--



-- string   []    = return []
-- string   (h:t) = do { c <- char h; cs <- string t; return (h:t) }

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




-- string         [c5] = do {                 char c5; return         [c5] }
-- string     [c4, c5] = do {        char c4; char c5; return     [c4, c5] }
-- string (c3: cs)     = do { char c3; out <- string cs; return (c3:cs) }
-- string [c3; c4; c5] = do { char3; char c4; char c5; return [c3, c4, c5] }

-- string s = undefined -- char 


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

-- (A) lets go 7 mins
-- (B) lets stop i need to eat (etc.)


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
  y  <- int 
  return (x `op` y)

{-
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

-- "3918"
manyP :: Parser a -> Parser [a]
manyP p = orElse p1 p0 
  where
    p1  = do { v <- p; vs <- manyP p; return (v:vs) }
    p0  = return []

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

