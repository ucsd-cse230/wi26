{-# LANGUAGE DeriveFunctor #-}

module Tmp where

data Expr a 
  = Var a 
  | Val Int 
  | Add (Expr a) (Expr a)
  deriving (Show, Functor)

instance Applicative Expr where
    pure   = Var
    -- <*> :: Expr (a -> b) -> Expr a -> Expr b 
    (<*>) = undefined

instance Monad Expr where
  return = Var
  
  -- (>>=)        :: Expr a -> (a -> Expr b) -> Expr b
  (Var x)   >>= f  = f x
  (Val n)   >>= f  = Val n
  (Add x y) >>= f  = Add (x >>= f) (y >>= f)

-- | Subsets a X is a Set (Set a) where each set is a subset of X 
{-@ type Subsets a X = S.Set {v:S.Set a | S.isSubsetOf v X} @-}

{-@ data Topology a = T 
     { unX  :: S.Set a
     , unT  :: {t: Subsets a unX | (S.member S.empty t) && (S.member unX t) } 
     , pfUn :: x1:{_| S.member x1 unT} -> x2:{_| S.member x2 unT} ->
               {v:() | S.member (S.union x1 x2) unT} 
     , pfIn :: x1:{_| S.member x1 unT} -> x2:{_| S.member x2 unT} ->
               {v:() | S.member (S.intersection x1 x2) unT} 
     }  
  @-}

  Subset a unX
data Topology a = T { unT :: [[a]], unX :: [a] }


{- 
Definition 4. A topology on a set X is a collection T of subsets of X
satisfying the following properties:
1. X ∈ T .
2. ∅ ∈ T .
3. The union of any collection of elements of T is also in T .
4. The intersection of any finite collection of elements of T is also in T .

I've been able to express and verify conditions (1) and (2) using this
(listElts and Set_mem doesn't seem to work with nested lists, hence
the need to re-invent the wheel):
```
{-@ reflect hasElem @-}
hasElem :: Eq a => a -> [a] -> Bool
hasElem x [] = False
hasElem x (y:ys) = x == y || hasElem x ys
```

Then my thought was to define:

```
{-@ using (Topology a) as {v:Topology a |
    true
    && hasElem empty (unT v)
    && hasElem (unX v) (unT v)
    && hasSubsetUnion (unT v)
   && hasSubsetIntersection (unT v)
    } @-}
```
-}