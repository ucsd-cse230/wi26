{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE DeriveFunctor #-}

module Lec_11_9_21 where

-- import Data.Map

import Data.Char (isAlpha, isDigit)
import qualified Data.List as L
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
intP = fmap read (manyP digitP)

-- pat :: Monad m => (a -> b) -> m a -> m b
-- pat f e = do { x <- e ; return (f x) }

manyP :: Parser a -> Parser [a]
manyP aP = (do { a <- aP; as <- manyP aP; return (a:as) })
            `orElse`
            return []


-- >>> runParser intP "345cat"
-- [(345,"cat")]

-- B. [(345, "cat")]
-- D. [(3, "45cat")]
-- E. [("345", "cat")]

-- A. []
-- C. [(3, "cat")]



-- >>> runParser exprP "10*2+5"
-- 25

-- >>> runParser exprP "10-2-5"
-- 3


-- >>> runParser expr1P "10-2-2"
-- [(6,"")]

-- >>> runParser expr1P "10*2+5"
-- [(25,"")]
 
expr1P, sumP, prodP :: Parser Int
expr1P = sumP   
sumP   = manyWithOp' prodP (addP `orElse` subP)
prodP  = manyWithOp' intP  mulP 

manyWithOp :: Parser a -> Parser (a -> a -> a) -> Parser a
manyWithOp xP oP = do
  x1  <- xP 
  oxs <- manyP (do { o <- oP; x <- xP; return (o, x) })
  return $ L.foldl' (\x (o, x') -> x `o` x') x1 oxs

manyWithOp' :: Parser a -> Parser (a -> a -> a) -> Parser a
manyWithOp' xP oP = do {x1 <- xP; continue x1}
  where 
    continue x = do { o <- oP; x' <- xP; continue (x `o` x') } 
                 `orElse`
                 return x


-- x1 o x2 o x3 o x4



--    (((x1 o x2) o x3) o x4)

-- x1 [(o, x2), (o, x3), (o, x4), ...]

{- 

      EXPR = n1 o1 n2 o2 n3 o3 n4 o ...


      EXPR = SUM 

      SUM  = (((PROD + PROD) + PROD) + PROD) ...

      PROD = ((NUM * NUM) * NUM) * NUM


      10 * 20 * 30 + 40 * 50 * 60 + 70 * 80 * 90

      PROD1 = 10 * 20 * 30
          (NUM_10 * NUM_20) * NUM_3 

      PROD2 = 40 * 50 * 60
      PROD4 = 60 * 70 * 80



      (PROD * 30) + (PROD * 60) + (PROD * 90)
      
      PROD + PROD + PROD 

      SUM + PROD 

      SUM

      EXPR


-}

exprP :: Parser Int
exprP = binExpP `orElse` intP

binExpP :: Parser Int
binExpP = do
  n1 <- exprP
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



data Expr
  = Number Int            -- ^ 0,1,2,3,4
  | Plus   Expr Expr      -- ^ e1 + e2
  | Div    Expr Expr      -- ^ e1 / e2
  | Try    Int Expr 
  deriving (Show)

data Result s  a = Err s | Ok a
                  deriving (Show, Functor)

data Either e a = Left e | Right a


instance Applicative (Result s) where

instance Monad (Result s) where
  return x      = Ok x
  (Ok v)  >>= f = f v
  (Err s) >>= _ = Err s

eval :: Expr -> Result Expr Int
eval (Number n)    = return n
eval (Plus  e1 e2) = do 
  n1 <- eval e1
  n2 <- eval e2 
  return (n1+n2)
eval (Div   e1 e2) = do 
  n1 <- eval e1 
  n2 <- eval e2 
  if n2 /= 0 
    then return (n1 `div` n2) 
    else throw e2
eval (Try n e) = eval e 
                  `catch` (\_ -> return n)


catch :: Result e a -> (e -> Result e a) -> Result e a
catch (Ok val) _      = Ok val
catch (Err e ) handler = handler e

-- catch :: Result e Int -> (e -> Result e Int) -> Result e Int 

throw :: s -> Result s a
throw = Err

-- >>> eval (Div (Number 10) (Number 5))
-- Ok 2

-- >>> eval (Try 55 (Plus (Number 3) (Div (Number 10) (Plus (Number 5) (Number (-5))))))
-- Ok 55
