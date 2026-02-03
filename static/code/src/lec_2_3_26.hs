{- HLINT ignore "Eta reduce" -}
{- HLINT ignore "Use uncurry" -}
{- HLINT ignore "Use :" -}
{- HLINT ignore "Use id" -}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE InstanceSigs #-}
{- HLINT ignore "Use list comprehension" -}
{- HLINT ignore "Use >=>" -}
{- HLINT ignore "Redundant return" -}
{- HLINT ignore "Avoid lambda" -}
{- HLINT ignore "Use map" -}

module Lec_2_3_26  where
import GHC.Int (neInt32)

-- >>> (Add (Num 5) (Num 19))

-- (2 + 3) * ((50 - 4) / 7)
expr0 :: Expr
expr0 = Bin Mul
          (Bin Add (Num 2) (Num 3))                     -- (2 + 3)
          (Bin Div (Bin Sub (Num 50) (Num 4)) (Num 7))   -- ((5-4) / 7)


expr1 :: Expr
expr1 = Bin Mul
          (Bin Add (Num 2) (Num 3))
          (Bin Div (Bin Add (Num 5) (Num 4))
                   (Bin Sub (Num 3) (Bin Add (Num 1) (Num 2))))


data Op
  = Add | Sub | Mul | Div
  deriving (Show)

data Expr
  = Num Int
  | Bin Op Expr Expr
  deriving (Show)

-- >>> eval expr1
-- divide by zero

-- >>> evalR expr1
-- Err "Uff, div by zero!"

res0 :: [Result Int]
res0 = [Ok 78, Err "aaarthgh", Err "dbz", Ok 9]


-- >>> myShowFunc [10, 20]
-- "MY SHOW SAYS: [10,20]"

myShowFunc :: (Show ty) => ty -> String
myShowFunc x = "MY SHOW SAYS: " ++ show x

-- >>> eval' expr0
-- Ok 30

eval :: Expr -> Int
eval (Num n)       = n
eval (Bin o e1 e2) = evalOp o (eval e1) (eval e2)


foo n = z
  where
    a = b + 10
    b = n - 1
    z = a + 5

burp :: Int -> Result Int
burp n = Ok (n+1)

-- >>> scopeEx' 10
-- Ok 13

scopeEx :: Int -> Result Int
scopeEx n = do
  n1 <- burp n
  n2 <- burp n1
  n3 <- burp n2
  return n3

scopeEx' :: Int -> Result Int
scopeEx' n =
  burp n >>= \n1 ->
    burp n1 >>= \n2 ->
      burp n2 >>= \n3 ->
        return n3
{-



  e1 >>= (\x -> e2)     IS same AS      do { x <- e1;  e2 }


  e1 >>= \x1 ->
    e2 >>= \x2 ->
      e3 >>= \x3 ->
        STUFF

  do x1 <- e1
     e2 >>= \x2 ->
       e3 >>= \x3 ->
        STUFF

  do x1 <- e1
     x2 <- e2
     e3 >>= \x3 ->
     STUFF

  do x1 <- e1
     x2 <- e2
     x3 <- e3
     STUFF
do
  x1 <- e1
  x2 <- e2
  x3 <- e3
  STUFF


-}


eval' :: Expr -> Result Int
eval' (Num n) =
  return n
eval' (Bin o e1 e2) = do
  v1 <- eval' e1
  v2 <- eval' e2
  evalOpR e2 o v1 v2

-- Recipe a -> (a -> Recipe b) -> Recipe b

pat :: Result a -> (a -> Result b) -> Result b
pat scrutinee doWithVal =
  case scrutinee of
    Err msg -> Err msg
    Ok v    -> doWithVal v

instance Monad Result where
  (>>=) :: Result a -> (a -> Result b) -> Result b
  (>>=) = pat

  return :: a -> Result a
  return x = Ok x

evalOp :: Op -> Int -> Int -> Int
evalOp Add n1 n2 = n1 +     n2
evalOp Sub n1 n2 = n1 -     n2
evalOp Mul n1 n2 = n1 *     n2
evalOp Div n1 n2 = n1 `div` n2


evalOpR :: (Monad m) => m Int -> Op -> Int -> Int -> m Int
evalOpR _   Add n1 n2 = return (n1 + n2)
evalOpR _   Sub n1 n2 = return (n1 - n2)
evalOpR _   Mul n1 n2 = return (n1 * n2)
evalOpR err Div _  0  = err
evalOpR _   Div n1 n2 = return (n1 `div` n2)

-- >>> evalR expr0
-- BoringVal 30

evalR :: Expr -> BoringResult Int
evalR (Num n) = return n
evalR (Bin o e1 e2) = do
  n1 <- evalR e1
  n2 <- evalR e2
  evalOpR MmmNothing o n1 n2

data BoringResult a = BoringVal a | MmmNothing
  deriving (Show)

-- data List a = Cons a (List a) | Emp

data Result a = Ok a | Err String
  deriving (Show)

-- >>> :i Monad
-- type Monad :: (* -> *) -> Constraint

-- class Monad m where
--   (>>=) :: m a -> (a -> m b) -> m b
--   return :: a -> m a
--   {-# MINIMAL (>>=) #-}

instance Functor BoringResult where

instance Applicative BoringResult where

instance Monad BoringResult where
  (>>=) :: BoringResult a -> (a -> BoringResult b) -> BoringResult b
  (>>=) MmmNothing f    = MmmNothing
  (>>=) (BoringVal v) f = f v

  return :: a -> BoringResult a
  return x = BoringVal x

instance Functor Result where

instance Applicative Result where

-- instance Monad Result where

--   (>>=) = funkyOp

-- >>> :i Monad
-- class Applicative m => Monad m where
--   (>>=) :: m a -> (a -> m b) -> m b
--   return :: a -> m a

  -- funkyOp (evalR e1) (\n1 ->
  --   funkyOp (evalR e2) (\n2 ->
  --     evalOpR o n1 n2
  --   )
  -- )

funkyOp :: Result t -> (t -> Result a) -> Result a
funkyOp r doStuff = case r of
  Err msg -> Err msg
  Ok n -> doStuff n

-- >>> 10 `sillyFunction` 20
-- [10,20]

sillyFunction :: a -> a -> [a]
sillyFunction x y = [x, y]

{-
4b

- Does that mean lists are really linked lists under the hood?
  (YES -- take CSE 231!)

- Will functor, applicative be on midterm?
  (Yes, see sample)

- In (10 `mod` 3) what do "backticks" do? (infix notation)
  A: same as "mod 10 3"

- What does `Type -> Constraint` mean?

- What about subtypes? (No subtypes in Haskell)

- What's the funny syntax for `fmap`?
  `<$>`

- Is there a typeclass for `Foldable` (yes! it's called `Foldable`)
    https://serokell.io/blog/whats-that-typeclass-foldable

- `gmap` confused me because I didn't understand
  how the connection worked with `mapList` or `mapTree`

- In "fold" we had a parameter for "base";
  how come we don't need it for "gmap"?


- What is a a monad?


-}

-- evalB :: Expr -> Result Int
-- evalB (Add e1 e2) = case evalR e1 of
--                       Err msg -> Err msg
--                       Ok n1   -> case evalR e2 of
--                                    Err msg -> Err msg
--                                    Ok n2   -> Ok (n1 + n2)
-- evalB (Sub e1 e2) = case evalR e1 of
--                       Err msg -> Err msg
--                       Ok n1   -> case evalR e2 of
--                                    Err msg -> Err msg
--                                    Ok n2   -> Ok (n1 - n2)

-- evalB (Mul e1 e2) = case evalR e1 of
--                       Err msg -> Err msg
--                       Ok n1   -> case evalR e2 of
--                                    Err msg -> Err msg
--                                    Ok n2   -> Ok (n1 * n2)
-- evalB (Div e1 e2) = case evalR e1 of
--                       Err msg -> Err msg
--                       Ok n1   -> case evalR e2 of
--                                     Err msg -> Err msg
--                                     Ok 0    -> Err ("oh no DBZ because of:" ++ show e2)
--                                     Ok n2   -> Ok (n1 `div` n2)


data List a
  = Cons a (List a)
  | Emp
  deriving (Show)

list0 :: List Int
list0 = Cons 1 (Cons 2 (Cons 3 Emp))

instance Functor List where
instance Applicative List where

instance Monad List where
  (>>=) :: List a -> (a -> List b) -> List b
  (>>=) = bindList

  return :: a -> List a
  return = returnList



-- bindList [x1, x2, x3] f
-- f x1 ++ f x2 ++ f x3

bindList :: List a -> (a -> List b) -> List b
bindList Emp        f = Emp
bindList (Cons x xs) f = append
                           (f x)           -- :: List b
                           (bindList xs f) -- :: List b

append :: List a -> List a -> List a
append Emp ys = ys
append (Cons x xs) ys = Cons x (append xs ys)

returnList :: a -> List a
returnList x = Cons x Emp

-- >>> quiz
-- Cons (1,"cat") (Cons (1,"dog") (Cons (2,"cat") (Cons (2,"dog") (Cons (3,"cat") (Cons (3,"dog") Emp)))))

quiz :: List (Int, String)
quiz = do
  x <- Cons 1 (Cons 2 (Cons 3 Emp))
  y <- Cons "cat" (Cons "dog" Emp)
  return (x, y)


-- >>> quizL
-- [(1,"cat"),(1,"dog"),(2,"cat"),(2,"dog"),(3,"cat"),(3,"dog")]

quizL :: [(Int, String)]
quizL = do
  x <-  [1, 2 , 3]
  y <- ["cat", "dog"]
  return (x, y)

-- >>> pythag 100
-- [(3,4,5),(5,12,13),(6,8,10),(7,24,25),(8,15,17),(9,12,15),(9,40,41),(10,24,26),(11,60,61),(12,16,20),(12,35,37),(13,84,85),(14,48,50),(15,20,25),(15,36,39),(16,30,34),(16,63,65),(18,24,30),(18,80,82),(20,21,29),(20,48,52),(21,28,35),(21,72,75),(24,32,40),(24,45,51),(24,70,74),(25,60,65),(27,36,45),(28,45,53),(28,96,100),(30,40,50),(30,72,78),(32,60,68),(33,44,55),(33,56,65),(35,84,91),(36,48,60),(36,77,85),(39,52,65),(39,80,89),(40,42,58),(40,75,85),(42,56,70),(45,60,75),(48,55,73),(48,64,80),(51,68,85),(54,72,90),(57,76,95),(60,63,87),(60,80,100),(65,72,97)]

pythag :: Int -> [(Int, Int, Int)]
pythag n = do
  a <- [1..n]
  b <- [a..n]
  c <- [b..n]
  if a*a + b*b == c*c
    then [(a, b, c)]
    else []

{-

[1..n] >>= \a ->
  [a..n] >>= \b ->
    [b..n] >>= \c ->
      if ...
        then [(a, b, c)]
        else []

3*3 + 4*4 = 5*5
for x in [1, 2, 3]:
  for y in ["cat", "dog"]:
    yield (x, y)
-}

-- >>> quiz1
-- Cons 10 (Cons 20 (Cons 30 Emp))

quiz1 :: List Int
quiz1 = do
  x <- Cons 1 (Cons 2 (Cons 3 Emp))
  return (x * 10)
