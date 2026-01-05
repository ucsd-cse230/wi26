
{-# LANGUAGE NoMonomorphismRestriction #-}
{-# LANGUAGE FlexibleInstances #-} 
{-# LANGUAGE TypeSynonymInstances #-}

module Lec_11_18_21 where 

import Test.QuickCheck hiding ((===))
import Control.Monad
import Data.List

import qualified Data.Map as M 

import qualified Data.Set as S
import Control.Monad.State hiding (when)
import qualified Data.List as L
import Test.QuickCheck.Arbitrary (Arbitrary)


incr :: Int -> Int
incr x = x + 1

prop_revapp :: [Int] -> [Int] -> Bool
prop_revapp xs ys = 
    reverse (xs ++ ys) == reverse ys ++ reverse xs

-- >>> quickCheck prop_revapp


btw_10_20 :: Gen Int 
btw_10_20 = choose (10, 20)

btw_100_200 :: Gen Int 
btw_100_200 = choose (100, 200)

pair_10_20 :: Gen (Int, Int)
pair_10_20 = do
    x <- btw_10_20
    y <- btw_10_20
    return (x, y)

-- ["red", "blue", "green", "purple"]

listGen :: [a] -> Gen a
listGen xs = do
    n <- choose (0, length xs - 1)
    return (xs !! n)

oneOf' :: [Gen a] -> Gen a
oneOf' gs = do 
    g <- listGen gs
    a <- g
    return a 

randInt :: IO [Int]
randInt = randomThings


{-

Gen (Int, Int)


sample btw_10_20 :: Int

sample :: Gen a -> IO a

-}




myQsort        :: (Ord a) => [a] -> [a]
myQsort []     = []
myQsort (x:xs) = myQsort ls ++ [x] ++ myQsort rs
  where 
    ls         = [y | y <- xs, y < x]  -- elems in xs < x 
    rs         = [z | z <- xs, z > x]  -- elems in xs > x

propSortGOLDEN :: [Int] -> Bool
propSortGOLDEN xs = myQsort xs == L.sort xs

-- [y] forall xs. all inputs are same in xs then output = xs

-- [y] forall xs. length output == length xs

-- [y] forall xs. elems output == elems xs

-- [Y] forall xs. head output == minimum xs

-- [y] forall xs, i, j. 0 <= i <= j < length xs. output[i] <= output[j]

propEqModDups :: [Int] -> Bool
propEqModDups xs = length out == length xs  
    where 
        out      = myQsort xs

propElems :: [Int] -> Bool
propElems xs = S.fromList out == S.fromList xs
   where
      out    = myQsort xs

propOrder :: [Int] -> Int -> Int -> Property
propOrder xs i j = (0 <= i && i <= j && j < length out) ==> out !! i <= out !! j
  where
      out  =  myQsort xs

propOrder' :: [Int] -> Bool
propOrder' xs = isOrd (myQsort xs)

isOrd :: Ord a => [a] -> Bool
isOrd (x1:x2:xs) = x1 <= x2 && isOrd (x2:xs) 
isOrd _          = True

propHead :: [Int] -> Property
propHead xs = not (null xs) ==> (head out == minimum xs)
  where
      out  =  myQsort xs



prop_revapp' :: [Int] -> [Int] -> Bool
prop_revapp' xs ys = reverse (xs ++ ys) == reverse ys ++ reverse xs

-- >>> quickCheckN 500 prop_revapp'

quickCheckN :: Testable prop => Int -> prop -> IO ()
quickCheckN n = quickCheckWith (stdArgs { maxSuccess = n } )


qsort        :: (Ord a) => [a] -> [a]
qsort []     = []
qsort (x:xs) = qsort ls ++ [x] ++ qsort rs
  where 
    ls       = [y | y <- xs, y < x]  -- elems in xs < x 
    rs       = [z | z <- xs, z > x]  -- elems in xs > x

ls :: [Int]
ls = [1,3..19] ++ [2,4..20]

-- >>> ls
-- [1,3,5,7,9,11,13,15,17,19,2,4,6,8,10,12,14,16,18,20]
-- >>> qsort ls
-- [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]

isOrdered :: (Ord a) => [a] -> Bool
isOrdered (x:y:zs) = x <= y && isOrdered (y:zs)
isOrdered _        = True

prop_qsort_isOrdered :: [Int] -> Bool
prop_qsort_isOrdered xs = isOrdered (qsort xs)

-- >>> quickCheckN 1000 prop_qsort_isOrdered 
-- +++ OK, passed 1000 tests.
--


prop_qsort_min :: [Int] -> Bool
prop_qsort_min xs = head (qsort xs) == minimum xs

-- >>> quickCheck prop_qsort_min
-- *** Failed! Exception: 'Prelude.head: empty list' (after 1 test):
-- []
--

prop_qsort_nn_min    :: [Int] -> Property
prop_qsort_nn_min xs =
  not (null xs) ==> head (qsort xs) == minimum xs

-- >>> quickCheck prop_qsort_nn_min
-- +++ OK, passed 100 tests.
--

prop_qsort_sort    :: [Int] -> Bool
prop_qsort_sort xs =  qsort xs == sort xs

-- >>> quickCheck prop_qsort_sort
-- *** Failed! Falsifiable (after 6 tests and 3 shrinks):
-- [-3,-3]

noDuplicates ::(Eq a) => [a] -> Bool
noDuplicates (x:xs) = not (x `elem` xs) && noDuplicates xs
noDuplicates _      = True

prop_qsort_distinct :: [Int] -> Bool 
prop_qsort_distinct xs = noDuplicates (qsort xs)  

-- >>> quickCheck prop_qsort_distinct
-- +++ OK, passed 100 tests.
--

prop_qsort_distinct_sort :: [Int] -> Property 
prop_qsort_distinct_sort xs = (noDuplicates xs) ==> (qsort xs == sort xs)

-- >>> quickCheck prop_qsort_distinct_sort
-- +++ OK, passed 10000 tests.
--
-- >>> quickCheck prop_qsort_sort
-- *** Failed! Falsifiable (after 6 tests and 2 shrinks):
-- [5,5]
-- >>> quickCheck prop_qsort_sort
-- *** Failed! Falsifiable (after 4 tests and 1 shrink):
-- [1,1]
--


-- >>> sample' (choose (0, 5))
-- [4,2,5,3,2,2,2,3,0,0,0]
--

pos = choose (0, 100)

posPair = do
  x1 <- pos
  x2 <- pos
  return (x1, x2)

-- >>> sample' posPair
-- [(29,71),(48,74),(89,53),(73,93),(0,40),(71,35),(23,69),(93,49),(59,58),(27,32),(88,45)]
--

oneOf :: [Gen a] -> Gen a
oneOf gs = do
  g <- elements gs
  x <- g
  return x

-- >>> sample' (oneOf [choose (0,2), choose (10,12)])
-- [2,2,1,1,12,10,2,2,11,0,11]
--

data Day = Mon | Tue | Wed deriving (Show)

instance Arbitrary Day where
    arbitrary = listGen [Mon, Tue, Wed]

randomThings :: (Arbitrary a) => IO [a]
randomThings = sample' arbitrary

-- >>> randomThings :: IO [[Int]]
-- [[],[],[-4,-1],[5,1,0,3,4,3],[0,8,2,3,8,4,3],[-6,-1,8,1,-5,-10,7,2],[-10,11,-6,-6,-12],[5,13,-8,-14,0,-1,-14,-9,10,-10,12,0,14,-4],[-5,8,-9,-12],[-8,-3,-2,12,7,-1,6,3,17,-14,12],[]]
--
-- >>> randomThings :: IO [Bool]
-- [True,True,False,True,False,True,True,True,True,True,True]
--

-- >>> randomThings :: IO [String]
-- ["","\a","\f","\779257W\SUBA","\84573","D\ACK\365059S","9W\554735G","g\SYN~W\62120\&4&[","\NULsc\18427fy(","Q`TI \n/TH","\461027\ESCZ`u\783094\&4B\SOHT\424692"]
--


-- >>> randomThings :: IO [(Int, Bool)] 
-- [(0,True),(1,True),(0,True),(6,False),(-5,True),(4,False),(-12,False),(-8,False),(5,False),(-9,False),(-7,False)]
--

data Variable 
  = V String 
  deriving (Eq, Ord)

data Value 
  = IntVal Int
  | BoolVal Bool
  deriving (Eq, Ord)

data Expression 
  = Var   Variable
  | Val   Value
  | Plus  Expression Expression
  | Minus Expression Expression

data Statement
  = Assign   Variable   Expression
  | If       Expression Statement  Statement
  | While    Expression Statement
  | Sequence Statement  Statement
  | Skip

type WState = M.Map Variable Value

instance Arbitrary Variable where
  arbitrary = do
    x <- elements ['A'..'Z'] 
    return (V [x])

-- >>> randomThings :: IO [Variable]
-- [V "X",V "V",V "W",V "C",V "J",V "G",V "H",V "I",V "D",V "T",V "R"]
--

instance Arbitrary Value where
  arbitrary = oneOf 
    [ IntVal <$> arbitrary
    , BoolVal <$> arbitrary
    ]

instance Arbitrary Expression where
  arbitrary = expr
  -- shrink :: Expression -> [Expression]
  shrink (Plus e1 e2)  = [e1, e2]
  shrink (Minus e1 e2) = [e1, e2]
  shrink _             = []



expr :: Gen Expression
expr     = oneof [base, bin] 
  where 
    base = oneOf [ Var <$> arbitrary, Val <$> arbitrary ]
    bin  = do {o <- op; e1 <- expr; e2 <- expr; return (o e1 e2)} 
    op   = elements [Plus, Minus]

-- >>> randomThings :: IO [WState]
-- [fromList [],fromList [(V "P",IntVal 0)],fromList [(V "M",IntVal 0),(V "Z",IntVal 1)],fromList [(V "E",BoolVal False),(V "J",BoolVal False),(V "X",IntVal 6)],fromList [(V "J",IntVal (-8)),(V "U",IntVal 3),(V "Z",BoolVal True)],fromList [(V "A",BoolVal False),(V "I",BoolVal False),(V "J",BoolVal False)],fromList [(V "H",BoolVal True),(V "J",IntVal (-9)),(V "K",IntVal (-12)),(V "L",BoolVal True),(V "U",BoolVal False),(V "V",IntVal (-4)),(V "W",IntVal (-9))],fromList [(V "A",BoolVal True),(V "C",BoolVal False),(V "E",IntVal 1),(V "K",BoolVal False),(V "N",IntVal (-7)),(V "P",BoolVal True),(V "R",IntVal (-2)),(V "T",BoolVal True),(V "V",IntVal (-1)),(V "Z",BoolVal True)],fromList [(V "A",BoolVal True),(V "M",BoolVal True),(V "O",BoolVal True),(V "S",IntVal 14),(V "W",IntVal 3)],fromList [(V "D",BoolVal True),(V "E",IntVal (-5)),(V "F",BoolVal True),(V "L",BoolVal False),(V "M",IntVal (-13)),(V "T",BoolVal True),(V "V",IntVal (-3)),(V "Z",BoolVal True)],fromList [(V "D",IntVal 13),(V "F",IntVal 16),(V "I",IntVal (-14)),(V "M",IntVal 11),(V "O",BoolVal True),(V "P",BoolVal False),(V "Q",BoolVal False),(V "R",BoolVal False),(V "S",BoolVal False),(V "U",BoolVal True),(V "Y",IntVal 15)]]
--

execute ::  WState -> Statement -> WState
execute s0 stmt = execState (evalS stmt) s0

(===) ::  Statement -> Statement -> Property
p1 === p2 = forAll arbitrary (\st -> execute st p1 == execute st p2)


-- X := 10; Y := 20
prog1 = Sequence 
  (Assign (V "X") (Val (IntVal 10)))
  (Assign (V "Y") (Val (IntVal 20)))

--  Y := 20; X := 10
prog2 = Sequence 
  (Assign (V "Y") (Val (IntVal 20)))
  (Assign (V "X") (Val (IntVal 10)))

--  Y := 20; X := 20
prog3 = Sequence 
  (Assign (V "Y") (Val (IntVal 20)))
  (Assign (V "X") (Val (IntVal 20)))

-- >>> quickCheck (prog1 === prog2)

-- >>> quickCheck (prog1 === prog3)

prop_add_zero_elim :: Variable -> Expression -> Property
prop_add_zero_elim x e = 
   (x `Assign` (e `Plus` Val (IntVal 0))) === (x `Assign` e) 

prop_sub_zero_elim :: Variable -> Expression -> Property
prop_sub_zero_elim x e =
  (x `Assign` (e `Minus` Val (IntVal 0))) === (x `Assign` e)

-- >>> quickCheck prop_add_zero_elim
-- *** Failed! Falsifiable (after 1 test):
-- W
-- True
-- fromList []
--

p1  = V "W" `Assign` Val (BoolVal True)
p2  = V "W" `Assign` (Val (BoolVal True) `Plus` Val (IntVal 0))
st0 = M.empty

-- >>> execute st0 p1
-- fromList [(W,True)]
--

-- >>> execute st0 p2
-- fromList [(W,0)]
--

intExpr :: Gen Expression
intExpr     = oneof [base, bin] 
  where 
    base = oneOf [ Var <$> arbitrary, Val . IntVal <$> arbitrary ]
    bin  = do {o <- op; e1 <- expr; e2 <- expr; return (o e1 e2)} 
    op   = elements [Plus, Minus]

prop_add_zero_elim'   :: Variable -> Property
prop_add_zero_elim' x = 
  forAll intExpr (\e -> (x `Assign` (e `Plus` Val (IntVal 0))) === (x `Assign` e))


-- >>> quickCheck prop_add_zero_elim'
-- *** Failed! Falsifiable (after 11 tests):
-- Z
-- G
-- fromList [(B,False),(F,-4),(G,True),(K,8),(M,True),(N,False),(R,3),(T,False),(V,True)]
--



prop_const_prop :: Variable -> Variable -> Expression -> Property
prop_const_prop x y e = 
  ((x `Assign` e) `Sequence` (y `Assign` e))
  ===
  ((x `Assign` e) `Sequence` (y `Assign` Var x))


-- >>> quickCheck prop_const_prop 


evalE :: Expression -> State WState Value
evalE (Var x)       = get >>= return . M.findWithDefault (IntVal 0) x
evalE (Val v)       = return v
evalE (Plus e1 e2)  = return (intOp (+) 0 IntVal) `ap` evalE e1 `ap` evalE e2
evalE (Minus e1 e2) = return (intOp (-) 0 IntVal) `ap` evalE e1 `ap` evalE e2

evalS :: Statement -> State WState ()
evalS w@(While e s)    = evalS (If e (Sequence s w) Skip)
evalS Skip             = return ()
evalS (Sequence s1 s2) = evalS s1 >> evalS s2
evalS (Assign x e )    = do v <- evalE e
                            m <- get
                            put $ M.insert x v m
                            return ()
evalS (If e s1 s2)     = do v <- evalE e
                            case v of 
                              BoolVal True  -> evalS s1
                              BoolVal False -> evalS s2
                              _             -> return ()


intOp :: (Int -> Int -> a) -> a -> (a -> Value) -> Value -> Value -> Value
intOp op _ c (IntVal x) (IntVal y) = c $ x `op` y
intOp _  d c _          _          = c d 


blank   :: Int -> String 
blank n = replicate n ' '

instance Show Variable where
  show (V x) = x

instance Show Value where
  show (IntVal  i) = show i
  show (BoolVal b) = show b

instance Show Expression where
  show (Var v)       = show v
  show (Val v)       = show v
  show (Plus e1 e2)  = show e1 ++ " + " ++ show e2
  show (Minus e1 e2) = show e1 ++ " + " ++ show e2

instance Show Statement where
  show = showi 0

showi :: Int -> Statement -> String 
showi n Skip         = blank n ++ "skip"
showi n (Assign x e) = blank n ++ show x ++ " := " ++ show e
showi n (If e s1 s2) = blank n ++ "if " ++ show e ++ " then\n" ++ 
                       showi (n+2) s1 ++
                       blank n ++ "else\n" ++ showi (n+2) s2 ++ blank n ++ "endif"

showi n (While e s)  = blank n ++ "while " ++ show e ++ " do\n" ++ 
                       showi (n+2) s
showi n (Sequence s1 s2) = showi n s1 ++ "\n" ++ showi n s2 

instance Arbitrary Statement where
  arbitrary = oneof [ Assign   <$> arbitrary <*> arbitrary
                    , If       <$> arbitrary <*> arbitrary <*> arbitrary
                    , While    <$> arbitrary <*> arbitrary
                    , Sequence <$> arbitrary <*> arbitrary
                    , pure Skip ]

