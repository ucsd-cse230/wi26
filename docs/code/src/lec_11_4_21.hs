{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE DeriveFunctor #-}

module Lec_11_4_21 where

-- import Data.Map

import Data.Char (isAlpha, isDigit)
newtype Parser a = MkParser (String -> [(a, String)]) 
  deriving (Functor)


runParser :: Parser a -> String -> [(a, String)]
runParser (MkParser p) s = p s 

-- >>> runParser twoChar "hahahaha"
-- [(('h','a'),"hahaha")]

-- [(('h','e'), "y!")]

-- twoChar = do 
--     c1 <- oneChar
--     c2 <- oneChar
--     return (c1, c2)

-- >>> runParser (combineP oneChar oneChar) "h"
failP :: Parser a
failP = MkParser (\_ -> [])

combineP :: Parser a -> Parser b -> Parser (a, b)
combineP aP bP = do
    a <- aP
    b <- bP
    return (a, b)


satP :: (Char -> Bool) -> Parser Char
satP p = do 
  c <- oneChar
  if p c then return c else failP

digitP :: Parser Char
digitP = satP isDigit

alphaP :: Parser Char
alphaP = satP isAlpha

strP :: String -> Parser String
strP []     = return []
strP (c:cs) = do 
  _ <- satP (== c)
  _ <- strP cs 
  return (c:cs)

data Day = Mon | Tue | Wed deriving (Show, Read)

dayP :: Parser Day
dayP = do 
    s <- strP "Mon" `orElse` strP "Tue" `orElse` strP "Wed" 
    return (read s)


orElse :: Parser a -> Parser a -> Parser a
orElse p1 p2 = MkParser (\s -> 
    -- runParser p1 s ++ runParser p2 s
    case runParser p1 s of
        [] -> runParser p2 s
        rs -> rs
    ) 

{- 
   digitP :: Parser Char
   c2i    :: Char -> Int

  -}

c2i :: Char -> Int
c2i c = read [c]

intP :: Parser Int 
intP = do 
    is <- manyP digitP
    return (read is)

manyP :: Parser a -> Parser [a]
manyP aP = (do { a <- aP; as <- manyP aP; return (a:as) })
            `orElse`
            return []

-- >>> runParser calcP "19-1"
-- stack overflow

calcP :: Parser Int
calcP = do
    n1 <- intP
    o  <- opP
    n2 <- intP
    return (o n1 n2)

opP :: Parser (Int -> Int -> Int)
opP = addP `orElse` subP `orElse` mulP


-- 1. whitespace,
-- 2. more than one digit
-- 3.
-- >>> runParser calcP "10-1"
-- [(0,"")]


{- 
    do e1 
       e2 
    
    e1 >> e2

    -}

addP  = strP "+" >> return (+)
subP = strP "-" >> return (-)
mulP = strP "*" >> return (*)

minusP= do
    strP "-"
    return (-)


-- >>> runParser calcP "1+9zoo"
-- [(10, "zoo")]


-- foo = isDigit
-- >>> runParser alphaP "jello"
-- [('j',"ello")]

--     MkParser (\s ->
--   forEach  (runParser aP s) (\(ai, si) ->
--     forEach  (runParser bP si) (\(bj, sij) -> 
--         [((ai, bj), sij)]
--     )
--   )
--   )

instance Monad Parser where
    return = returnP
    (>>=)  = awesomeP

returnP :: a -> Parser a
returnP x = MkParser (\s -> [(x, s)])

awesomeP :: Parser a -> (a -> Parser b) -> Parser b
awesomeP aP aTobP = MkParser (\s -> 
    forEach (runParser aP s) (\(a, s') ->
      forEach (runParser (aTobP a) s') (\(b, s'') -> 
         [(b, s'')]
      )
    )
  )








-- >>> runParser 


{- 
   forEach (ai, Si) in (runParser aP s):
     forEach (bij, Sij) in (runParser bP Si): 
        yield ((ai, bij), Sij)
   
    S       ===>       [(a1, S1), (a2, S2), (a3, S3), ...]
                            [(b11, S11), (b12, S12), ...]
                            [(b21, S21), (b22, S22), ...]

                       [((a1, b11), S11), ((a1, b12), S12), ...]


-}

-- >>> silly
-- []

silly :: [(Integer, Bool)]
silly = forEach [] (\i -> 
          forEach [True, False] (\b ->
            [(i, b)]    
          )
        )



twoChar' :: Parser (Char, Char)
twoChar' = combineP oneChar oneChar

-- >>> runParser twoChar' "hello!" 
-- [(('h','e'),"llo!")]


twoChar :: Parser (Char, Char)
twoChar = MkParser (\case
                      c1:c2:cs -> [((c1, c2), cs)]
                      _        -> [] 
                   )



oneChar :: Parser Char 
oneChar = MkParser (\case
                      c:cs -> [(c, cs)]
                      _    -> [] 
                   )








forEach :: [t] -> (t -> [a]) -> [a]
forEach []     _ = []
forEach (x:xs) f = f x ++ forEach xs f

charP :: Parser Char
charP = MkParser (\case
    [] -> [] 
    c:cs -> [(c, cs)]
  )



















{- 
instance Monad Parser where
  return x              = MkParser (\s -> [(x, s)])
  MkParser aP >>= aTobP = MkParser (\s -> 
      forEach (aP s) (\(a, s') -> 
          runParser (aTobP a) s'
      )
    )

pairP :: Parser a -> Parser b -> Parser (a, b)
pairP aP bP = do 
    a <- aP
    b <- bP
    return (a, b)

failP :: Parser a
failP = MkParser (\_ -> [])

-- >>> runParser (pairP charP charP) "hot"
-- [(('h','o'),"t")]



-}

instance Applicative Parser where
    pure x = MkParser (\s -> [(x, s)])
    (<*>)  = undefined