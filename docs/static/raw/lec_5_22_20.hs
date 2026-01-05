{-# LANGUAGE DeriveFunctor #-}

module Lec_5_22_20 where

import Data.Char





data Parser a = P (String -> [(a, String)])
  deriving (Functor) 



runParser :: Parser a -> String -> [(a, String)]
runParser (P f) s = f s

oneChar :: Parser Char
oneChar = P (\cs -> case cs of
                      [] -> [] 
                      (c:cs') -> [(c, cs')])

oneCharD = P (\cs -> [(head cs, tail cs)])

-- >>> runParser oneChar "friday"
-- [('f',"riday")]
--
-- >>> runParser oneChar ""
-- []
--

{-
-- A
oneChar = P (\cs -> head cs)

-- B
oneChar = P (\cs -> case cs of 
                      []   -> [('', [])] 
                      c:cs -> (c, cs))
-- C
oneChar = P (\cs -> (head cs, tail cs))

-- D
oneChar = P (\cs -> [(head cs, tail cs)])

-- E
oneChar = P (\cs -> case cs of
                      [] -> [] 
                      cs -> [(head cs, tail cs)])
-}


twoChar :: Parser (Char, Char)
twoChar = P (\cs -> case cs of 
                      (c1:c2:cs') -> [((c1,c2), cs')]
                      _           -> []
            ) 

forEach' :: [a] -> (a -> [b]) -> [b]
forEach' []     f = []
forEach' (x:xs) f = f x ++ forEach' xs f 

-- forEach' xs f = concat (map f xs)

example = forEach' [1,2,3] (\n -> 
            forEach' [0, 1, 2] (\m -> 
              [n * 100 + m]  
            )
          )

-- >>> example
-- [100,101,102,200,201,202,300,301,302]
--

-- >>> forEach' [1,2,3] (\n -> [n*100, n*100 + 1, n*100 + 2])
-- [100,101,102,200,201,202,300,301,302]
--


retP :: a -> Parser a
retP x = P (\s -> [(x, s)])

bindP :: Parser a -> (a -> Parser b) -> Parser b
bindP pa f = P (\s ->
  forEach (runParser pa s) (\(va, s1) -> 
    forEach (runParser (f va) s1) (\(vb, s2) ->
      [(vb, s2)]
      ) 
    ) 
  )

instance Monad Parser where
  return = retP
  (>>=) = bindP

pairP :: Parser a -> Parser b -> Parser (a, b)
pairP pa pb = do 
  va <- pa
  vb <- pb
  return (va, vb)

p3 :: Parser a -> Parser (a, a, a)
p3 p = do
  x1 <- p
  x2 <- p
  x3 <- p
  return (x1, x2, x3)

-- >>> runParser (p3 oneChar) "fr"
-- []
--
-- >>> runParser (pairP oneChar oneChar) "f"
-- []
--

-- >>> runParser twoChar "f"

forEach xs f = concatMap f xs 

instance Applicative Parser where
  pure x    = P (\s -> [(x, s)])
  fP <*> vP = P (\s -> forEach (runParser fP s) (\(f, s') ->
                         forEach (runParser vP s') (\(v, s'') -> 
                            [(f v, s'')]
                         )
                       )
                )

