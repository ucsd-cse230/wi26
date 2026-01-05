---
title: Property-based Testing
date: 2020-05-28
headerImg: books.jpg
---

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>




## Property-based Testing

        Typeclasses + Monads = Automatic Testing

Lets look at [QuickCheck][1]

- Developed by [Koen Claessen][0] and [John Hughes][11] in 2000

Ported to [40 other languages](https://en.wikipedia.org/wiki/QuickCheck)

- [JSVerify](http://jsverify.github.io/), 
  [JUNIT-quickcheck](https://github.com/pholser/junit-quickcheck),
  [hypothesis](https://github.com/HypothesisWorks/hypothesis)

PBT used in basically all kinds of software...

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Plan

1. **Property-based Testing**

2. Random Test Generation

3. Case-Study

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Property-based Testing

**Don't** (only) write individual *unit-tests* 

- only check particular input-output behavior of code

**Do write** *properties* desired of the functions

- *generate* random inputs 
- *run* function 
- *verify* (or rather, try to falsify) the property

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Testing with Specifications 

PBT emphasizes the importance of **specifying correct behavior** 

- Makes you think about what the code *should do*,

- Finds *corner-cases* where the specification is violated (so code or spec are fixed)

- Makes specs live on as machine-checked *documentation*.

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>



## Properties

A `Property` is a function that returns a `Bool`

```haskell
prop_revapp :: [Int] -> [Int] -> Bool
prop_revapp xs ys = 
    reverse (xs ++ ys) == reverse xs ++ reverse ys
```

Looks like a _theorem_ that the programmer _believes_ is true. 

- By convention, we write the prefix `"prop_"`

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## QUIZ

Consider the property `prop_revapp` 

```haskell
prop_revapp :: [Int] -> [Int] -> Bool
prop_revapp xs ys = 
    reverse (xs ++ ys) == reverse xs ++ reverse ys
```

It says *forall* `xs`, `ys`.  `reverse (xs ++ ys) == reverse xs ++ reverse ys`.

Is the property true?

**A.** Yes

**B.** No

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Question

Why specify type as `[Int] -> [Int] -> Bool`? 

* Why not write `[a] -> [a] -> Bool`? 


<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Checking Properties

QC uses the types to generate *random inputs* 

- For that, it needs a *specific* type like `[Int]` 

- Cannot generate an input of type `[a]` 

Let's `quickCheck` it!

```haskell
>>> quickCheck prop_revapp
*** Failed! Falsifiable (after 6 tests and 9 shrinks):
[0]
[1]
```

Huh? QC gives us a _counterexample_ with `xs = [0]` and `ys == [1]`

```haskell
reverse (xs ++ ys) 
==> reverse ([0] ++ [1]) 
==> reverse ([0, 1]) 
==> [1, 0]
```

but 

```haskell
reverse xs ++ reverse ys
==> reverse [0] ++ reverse [1]
==> [0] ++ [1]
==> [0, 1]
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## EXERCISE 

Can you modify `prop_revapp` so that it is _sensible_  and _true_ ?

```haskell
prop_revapp :: [Int] -> [Int] -> Bool
prop_revapp xs ys = reverse (xs ++ ys) == ???
```

When you are done, we should see

```haskell
>>> quickCheck prop_revapp'
+++ OK, passed 100 tests.
```

We can run *more* tests by specifying that as a parameter

```haskell
quickCheckN n = quickCheckWith (stdArgs {maxSuccess = n})
```

Followed by

```haskell
quickCheckN 10000 prop_revapp
+++ OK, passed 10000 tests
```


<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## QuickSort

Here's a simple sorting function (`quickSort`)

```haskell
qsort        :: (Ord a) => [a] -> [a]
qsort []     = []
qsort (x:xs) = qsort ls ++ [x] ++ qsort rs
  where 
    ls       = [y | y <- xs, y < x]  -- elems in xs < x 
    rs       = [z | z <- xs, z > x]  -- elems in xs > x
```

Seems to work?

```haskell
>>> [1,3..19] ++ [2,4..20]
[1,3,5,7,9,11,13,15,17,19,2,4,6,8,10,12,14,16,18,20]

>>> qsort ([1,3..19] ++ [2,4..20])
[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## QuickCheck QuickSort

Lets *check* the output of `qsort` is **ordered**

```haskell
isOrdered :: (Ord a) => [a] -> Bool
isOrdered ::         (Ord a) => [a] -> Bool
isOrdered (x1:x2:xs) = x1 <= x2 && isOrdered (x2:xs)
isOrdered _          = True
```

and use it to write a property

```haskell
prop_qsort_isOrdered :: [Int] -> Bool
prop_qsort_isOrdered xs = isOrdered (qsort xs)
```

which we can check

```haskell
>>> quickCheckN 1000 prop_qsort_isOrdered
+++ OK, passed 1000 tests.
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## QUIZ 

Lets check that the *first* element of the output is the smallest

```haskell
qsort        :: (Ord a) => [a] -> [a]
qsort []     = []
qsort (x:xs) = qsort ls ++ [x] ++ qsort rs
  where 
    ls       = [y | y <- xs, y < x]  -- elems in xs < x 
    rs       = [z | z <- xs, z > x]  -- elems in xs > x

prop_qsort_min :: [a] -> Bool
prop_qsort_min xs = head (qsort xs) == minimum xs
```

What is the result of

```haskell
>>> quickCheck prop_qsort_min
```

**A.** Pass 100 tests

**B.** Fail

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Properties and Assumptions

```haskell
prop_qsort_min :: [a] -> Bool
prop_qsort_min xs = head (qsort xs) == minimum x
```

Oops!

```haskell
>>> quickCheck prop_qsort_min
*** Failed! Exception: 'Prelude.head: empty list' (after 1 test):
[]
```

`prop_qsort_min` is not true **for all** `Int` lists

- Property *only* makes sense if `xs` is not empty

Writing specifications clarifies the *assumptions* 

- under which a given piece of code is supposed to work. 

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Conditional Properties 

Lets modify `prop_qsort_min` so equality holds *if* input is non-null

```haskell
prop_qsort_nn_min    :: [Int] -> Property
prop_qsort_nn_min xs =
  not (null xs) ==> head (qsort xs) == minimum xs
```

Instead of `Bool` the function's output is `Property` 

- a special type built into the QC library

The *implies* operator `==>` is one of many 

- that allow the construction of rich properties.

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## QUIZ 

Lets test that our `qsort` is *identical* to a *trusted reference implementation* 

- may be too *slow* to deploy but ok to use for checking correctness

Lets use the standard library's `Data.List.sort` function

- (_Much_ faster than ours... but just for illustration!)

```haskell
prop_qsort_sort    :: [Int] -> Bool
prop_qsort_sort xs =  qsort xs == sort xs
```

What is the result of

```haskell
qsort        :: (Ord a) => [a] -> [a]
qsort []     = []
qsort (x:xs) = qsort ls ++ [x] ++ qsort rs
  where 
    ls       = [y | y <- xs, y < x]  -- elems in xs < x 
    rs       = [z | z <- xs, z > x]  -- elems in xs > x

>>> quickCheck prop_qsort_sort
```

**A.** `OK` after 100 tests

**B.** `Failed! Falsifiable...`

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Lets Check 

```haskell
>>> quickCheck prop_qsort_sort
*** Failed! Falsifiable (after 6 tests and 3 shrinks):
[-3,-3]
```

Oops? What?

```haskell
>>> sort [-3, -3]
[-3, -3]

>>> qsort [-3, -3]
[-3]
```

Ugh! So close, and yet ... Can you spot the bug in our code?

```haskell
qsort        :: (Ord a) => [a] -> [a]
qsort []     = []
qsort (x:xs) = qsort ls ++ [x] ++ qsort rs
  where 
    ls       = [y | y <- xs, y < x]  -- elems in xs < x 
    rs       = [z | z <- xs, z > x]  -- elems in xs > x
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Specifying No-Duplicates

We assumed that the input has **no duplicates**

- **Values equal to** `x` are thrown out from `ls` and `rs`

Is this a *bug*? Maybe? Maybe not?

- But at least its something we should be *aware* of!

Lets specify that a list has no-duplicates 

```haskell
noDuplicates ::(Eq a) => [a] -> Bool
noDuplicates (x:xs) = not (x `elem` xs) && noDuplicates xs
noDuplicates _      = True
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Specifying a Post-Condition

We can now check that `qsort` **outputs** a list with no-duplicates

```haskell
prop_qsort_distinct :: [Int] -> Bool 
prop_qsort_distinct xs = noDuplicates (qsort xs)  

-- >>> quickCheck prop_qsort_distinct
-- +++ OK, passed 100 tests.
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Specifying a Pre-Condition

Also, `qsort` is identical to `sort` on **inputs with no duplicates**

```haskell
prop_qsort_distinct_sort :: [Int] -> Property 
prop_qsort_distinct_sort xs = 
  (isDistinct xs) ==> (qsort xs == sort xs)

-- >>> quickCheck prop_qsort_distinct_sort
-- +++ OK, passed 100 tests.
--
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Plan

1. **Property-based Testing**
    - Properties are boolean-functions
    - Generate inputs, run function, check if result is `False`

2. Random Test Generation

3. Case-Study

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Plan

1. Property-based Testing
    - Properties are boolean-functions
    - Generate inputs, run function, check if result is `False`

2. **Test Generation**

3. Case-Study


<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Test Generation

Lets notice something about `quickCheck`

If you run it once ...

```haskell
>>> quickCheck prop_qsort_sort
*** Failed! Falsifiable (after 6 tests and 2 shrinks):
[5,5]
```

and if you run it again ...

```haskell
>>> quickCheck prop_qsort_sort
*** Failed! Falsifiable (after 4 tests and 1 shrink):
[1,1]
```

The *falsifying tests* are different! 

How is this possible?

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Generators

QC defines a special *Generator* data type

```haskell
data Gen a = MkGen (StdGen -> Int -> a)
```

A `Gen a` is a function that takes as *input*

- a random number generator `StdGen`
- a "seed" `Int`

and returns as *output*

- a **value** of type `a`

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Creating `Gen`erators

There are some functions to *create* generators, e.g.

```haskell
choose :: (Int, Int) -> Gen Int
```

which 

- takes a pair of `(lo, hi)`

- returns a random generator for values between `lo` and `hi`

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Running `Gen`erators

To *execute* the `Gen` we need access to the system's "randomness"

Done via an `IO` "recipe"

```haskell
sample' :: Gen a -> IO [a]
```

Which 

- takes a `Gen`erator of `a` values and
- returns a *recipe* that produces a list of (10) `a` values

We can *run* the recipe in `ghci`

```haskell
>>> sample' (choose (0, 5))
[4,2,5,3,2,2,2,3,0,0,0]
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## EXERCISE 

Lets write a function that returns a `Gen`erator over a list of `elements`

```haskell
elements :: [a] -> Gen a
elements = ???
```

So `elements [x0,x1,...,xn]` returns a `Gen`erator that randomly produces 
values from `x0`, `x1`, ... `xn`.

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## PROBLEM: How to *combine* `Gen`erators?

Suppose I have a generator of positive `Int`

```haskell
pos :: Gen Int
pos = sample (0, 100)
```

How can I create a generator of a *pair* of positive `Int`s?

```haskell
posPair :: Gen (Int, Int)
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>


## `Gen`erator is a Monad! 

- You can [see details here][12]

- This will let us *combine* generators (like combining parsers...)

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## QUIZ 

Which of the below implements `posPair :: Gen (Int, Int)` ?

- given `pos :: Gen Int` and `sample :: (Int, Int) -> Gen Int` 

```haskell
-- A
posPair = do { x1 <- pos; x2 <- pos; return (x1, x2) }

-- B
posPair = (pos, pos)

-- C
posPair = do { x <- pos; return (x, x) }  

-- D
posPair = Gen (4, 5)

-- E 
posPair = (sample (0, 100), sample (0, 100))
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

```haskell
posPair = do { x1 <- pos; x2 <- pos; return (x1, x2) }

-- >>> sample' posPair
-- [(29,71),(48,74),(89,53),(73,93),(0,40),(71,35),(23,69),(93,49),(59,58),(27,32),(88,45)]
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## EXERCISE

Lets write a function that *mixes* a list of `Gen`erators

```haskell
oneOf :: [Gen a] -> Gen a
oneOf = ???
```

`oneOf [g0,g1,...,gn]` should be a generator that

- randomly selects *one of* `g0`,...`gn`

- randomly generates a value from the chosen generator

```haskell
>>> sample' (oneOf [choose (0,2), choose (10,12)])
[2,2,1,1,12,10,2,2,11,0,11]
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

`oneOf` is generalized into the `frequency` combinator

```haskell
frequency :: [(Int, Gen a)] -> Gen a
```

which builds *weighted mixtures* of individual `Gen`erators

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Types that can be `Gen`erated

QC has a `class` for types whose values can be randomly `Gen`erated

```haskell
class Arbitrary a where
  arbitrary :: Gen a
```

`T` is an instance of `Arbitrary` if there is `Gen T` function

- i.e. there is a generator of `T` values!

```haskell
randomThings :: (Arbitrary a) => IO [a]
randomThings = sample' arbitrary
```

Many standard types have `Arbitrary` instances

- Users write their own instances when testing their own types

```haskell
>>> randomThings :: IO [Int]
[0,-2,-2,0,-1,8,1,-14,-13,5,19]

>>> randomThings :: IO [(Int, Bool)] 
[(0,True),(1,True),(0,True),(6,False),(-5,True),(4,False),(-12,False),(-8,False),(5,False),(-9,False),(-7,False)]
-
>>> randomThings :: IO [String]
["","\a","\f","\779257W\SUBA","\84573","D\ACK\365059S","9W\554735G","g\SYN~W\62120\&4&[","\NULsc\18427fy(","Q`TI \n/TH","\461027\ESCZ`u\783094\&4B\SOHT\424692"]
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Plan

1. Property-based Testing
    - Properties are `Bool`ean-functions
    - Generate inputs, run function, check if result is `False`

2. Test Generation
    - `Gen a` is a monadic *generator* of `a` values
    - `Arbitrary` is a class for types with generators

3. **Case-Study**

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Case Study: Compiler Optimizations

Lets use QC to test *compiler optimizations*

- Learn how to *generate* structure data (*programs*)

- Learn how to *specify* fancy properties (*equivalence*)

Using the `WHILE` language from your HW assignment.

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## WHILE: Syntax

Recall the definition of `Variable` and `Value`

```haskell
data Variable = V String 

data Value = IntVal Int | BoolVal Bool
```

which we used to define `Expression`

```haskell
data Expression = Var   Variable | Val   Value
                | Plus  Expression Expression
                | Minus Expression Expression
```

and `Statement`

```haskell
data Statement
  = Assign   Variable   Expression
  | If       Expression Statement  Statement
  | While    Expression Statement
  | Sequence Statement  Statement
  | Skip
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>


## WHILE: Semantics

Next, we defined the *behavior* of programs as 

- functions from *starting* state to *final* state 

- where *state* was defined as a map from `Variable` to `Value`

```haskell
type WState = M.Map Variable Value
```

and then you wrote a function

```haskell
execute ::  WState -> Statement -> WState
execute s0 stmt = execState (evalS stmt) s0
```

(We can skip the details of `evalS` because *you* wrote it... right?)

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Generating WHILE Programs

Lets write a *program generator* 

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

<!--
## QUIZ

But first, what is the type of

```haskell
quiz f m = do
  x <- m
  return (f x)
```

**A.** `             (a -> a) -> m a -> m a`

**B.** `             (a -> b) -> m a -> m b`

**C.** `             (a -> b) -> [a] -> [b]`

**D.** `             (a -> b) -> Gen a -> Gen b`

**E.** `(Monad m) => (a -> b) -> m a -> m b`

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## A Common Pattern?

Note that if `Monad m` then `Functor m` so ... 

What other *operator* / *function* has the type 

```
(a -> b) -> m a -> m b
```

???

--> 

### Generating Variables

```haskell
instance Arbitrary Variable where
  arbitrary = do
    x <- elements ['A'..'Z'] 
    return (V [x])
```

<!--
We can rewrite the above to

```haskell
instance Arbitrary Variable where
  arbitrary = (\x -> V [x]) <$> elements ['A'..'Z'] 
```
-->

and we get

```haskell
>>> randomThings :: IO [Variable]
[V "G",V "U",V "Z",V "F",V "Z",V "K",V "P",V "D",V "Y",V "M",V "H"]
```

<br>
<br>
<br>
<br>
<br>


### Generating Values

```haskell
instance Arbitrary Value where
  arbitrary = oneOf [ do {n <- arbitrary; return (IntVal n) }
                    , do {b <- arbitrary; return (BoolVal b)} 
                    ]
```

and we get

```haskell
>>> randomThings :: IO [Value]
[IntVal 0,BoolVal False,BoolVal True,IntVal 3
,IntVal (-8),IntVal (-3),IntVal 1,BoolVal False
,IntVal 6,BoolVal True,BoolVal False]
```

<br>
<br>
<br>
<br>
<br>


### Generating Expressions

```haskell
instance Arbitrary Expression where
  arbitrary = expr

expr, binE, baseE :: Gen Expression
expr     = oneof [baseE, binE] 

binE  = do { o  <- elements [Plus, Minus];
             e1 <- expr; 
             e2 <- expr 
             return (o e1 e2) }

baseE = oneOf [ do {x <- arbitrary; return (Var x) }
              , do {v <- arbitrary; return (Val v)} ]
```

which gives us

```haskell
>>> randomThings :: IO [Expression]
... -- lots of expressions! 
```

<br>
<br>
<br>
<br>
<br>


## Generating States 

QC already has an way to automatically generate `Map`s 

```haskell
instance (Ord k, Arbitrary k, Arbitrary v) =>  Arbitrary (M.Map k v) where
  arbitrary = do {kvs <- arbitrary; return (M.fromList kvs) }
```

So for free we get a generator for `WState`

```haskell
>>> randomThings :: IO [WState]
...
```

<br>
<br>
<br>
<br>
<br>

## Specification: Program Equivalence

Next, lets specify the **properties**

Let `p1` and `p2` be two *While* programs. 

Program `p1` is *equivalent to* `p2` written `p1 === p2` if

```haskell
(===) ::  Statement -> Statement -> Property
p1 === p2 = forAll arbitrary (\st -> execute st p1 == execute st p2)
```

That is, for all *input* states `st`

- executing `p1` from `st` and 

- executing `p2` from `st`

produce the _same_ state.

## QUIZ 

For example, suppose that

```haskell
-- X := 10; Y := 20
prog1 = Sequence 
  (Assign (V "X") (Val (IntVal 10)))
  (Assign (V "Y") (Val (IntVal 20)))

--  Y := 20; X := 10
prog2 = Sequence 
  (Assign (V "Y") (Val (IntVal 20)))
  (Assign (V "X") (Val (IntVal 10))

--  Y := 20; X := 20
prog3 = Sequence 
  (Assign (V "Y") (Val (IntVal 20)))
  (Assign (V "X") (Val (IntVal 20)))
```

then what do the following two queries return?

```haskell
>>> quickCheck (prog1 === prog2)
>>> quickCheck (prog1 === prog3)
```

**A.** FAIL, FAIL 

**B.** FAIL, PASS

**C.** PASS, FAIL

**D.** PASS, PASS 

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Checking Compiler Optimizations

A **compiler optimization** can be viewed as a **pair** of programs

- *input* written by human `p_in`
- *output* optimized by compiler `p_out` 

An optimization is **correct** if `p_in === p_out`

- Compiler should not *change behavior* of the code

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Checking an Optimization: Zero-Add-Elimination

Here's a simple optimization 

| **In**       | **Out**   |
|:-------------|:----------|
| `X := E + 0` | `X := E`  | 
| `X := E - 0` | `X := E`  | 
|              |           |

Should be correct because adding `0` doesn't change anything...

We can write this as a QC **property**

```haskell
prop_add_zero_elim :: Variable -> Expression -> Property
prop_add_zero_elim x e = 
   (x `Assign` (e `Plus` Val (IntVal 0))) === (x `Assign` e) 

prop_sub_zero_elim :: Variable -> Expression -> Property
prop_sub_zero_elim x e =
  (x `Assign` (e `Minus` Val (IntVal 0))) === (x `Assign` e)
```

So what does QC say?

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

```haskell
-- >>> quickCheck prop_add_zero_elim
-- *** Failed! Falsifiable (after 1 test):
-- W
-- True
-- fromList []
```

What's that? Lets see is `W := True` equivalent to `W := True + 0` ?

Forgot about those pesky boolean expressions! 

If you recall `W := True` will just assign `True` to `W`

```haskell
>>> execute M.empty ((V "W") `Assign` (Val (BoolVal True)))
fromList [(W,True)]
```

but `W := True + 0` will have a "type error" so will assign `0` to `W`!

```haskell
>>> execute M.empty (V "W") `Assign` ((Val (BoolVal True) `Plus` Val (IntVal 0)))
fromList [(W,0)]
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>


## Fix: Restrict Optimizations to `Int` Expressions

Problem was expressions like `True`

- Caused strange behaviors due to "type errors" 

Lets *restrict* to **only integer-valued expressions**

```haskell
exprI, baseI, binI :: Gen Expression
exprI = oneof [baseI, binE] 

baseI = oneOf [ do {x <- arbitrary; return (Var x) }
              , do {n <- arbitrary; return (Val (IntVal n)) } 
              ]
binI  = do { o  <- elements [Plus, Minus];
             e1 <- exprI;
             e2 <- exprI;
             return (o e1 e2) }
```

Now we can restrict the property to

```haskell
prop_add_zero_elim'   :: Variable -> Property
prop_add_zero_elim' x = 
  forAll intExpr (\e -> (x `Assign` (e `Plus` Val (IntVal 0))) === (x `Assign` e))
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## QUIZ

Consider the property 

```haskell
prop_add_zero_elim'   :: Variable -> Property
prop_add_zero_elim' x = 
  forAll intExpr (\e -> (x `Assign` (e `Plus` Val (IntVal 0))) === (x `Assign` e))
```

What will be the result of 

```haskell
>>> quickCheck prop_add_zero_elim'
```

**A.** PASS

**B.** FAIL

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

```haskell
>>> quickCheck prop_add_zero_elim'
*** Failed! Falsifiable (after 11 tests):
Z
G
fromList [(B,False),(F,-4),(G,True),(K,8),(M,True),(N,False),(R,3),(T,False),(V,True)]
```

Oops, the counterexample is `Z := G` and `Z := G + 0` 

- *but* now the _starting_ state maps `(G, True)` 

Pesky `Bool` sneaked right back in ... 

**Moral:** Even simple optimizations are _really_ tricky without types!

**Try at home** Can you fix this property so it passes?

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>


## Checking an Optimization: Constant-Folding-ish

Lets try another optimization that doesn't use any *arithmetic* 

- So should not have any problems with `Int`-vs-`Bool`

Suppose you have two back-to-back assignments

```haskell
X := E;   Y := E
```

Why *recompute* `E`? Result is already stored in `X`! So optimize the above to

```haskell
X := E;   Y := X
```

We can specify this transformation as the QC property

```haskell
prop_const_prop :: Variable -> Variable -> Expression -> Property
prop_const_prop x y e = 
  ((x `Assign` e) `Sequence` (y `Assign` e))
  ===
  ((x `Assign` e) `Sequence` (y `Assign` Var x))
```

Mighty QC, do you agree ?

```haskell
>>> quickCheck prop_const_prop 
*Testing> quickCheck prop_const_prop
*** Failed! Falsifiable (after 82 tests):
D
B
True + N + L + M + True + -45 + H + -9 + 70 + True + -68 + N + -29 + I + True + G + O + P + True + Q + False + False + True + True + True + True + X + I + False + 81 + -42 + False + 31 + -13 + T + 23 + True + S + True + I + M + True + True + True + Z + H + -65 + G + K + -22 + D
fromList [(A,True),(B,-72),(C,-19),(D,-34),(E,50),(F,True),(G,True),(H,-21),(I,5),(J,3),(K,True),(L,-20),(M,True),(N,-10),(O,-20),(P,False),(Q,-10),(R,-78),(S,True),(T,70),(U,False),(V,-55),(W,True),(X,True),(Y,True),(Z,-56)]
``` 

![](/static/img/thinking-face.png)

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Shrinking Tests

The property *fails* ... but the *counterexample* is very long!

![](/static/img/crying-face.png)

QC has a **test shrinking** mechanism ... also in the `Arbitrary` class 

```haskell
shrink :: a -> [a]
```

`shrink t` 

- takes as *input* a **candidate** `t` and  
- returns as *output* a list of **smaller candidates** 

That QC will systematically search with to find a **minimally** failing test!

```haskell
instance Arbitrary Expression where
  arbitrary = expr

  -- shrink :: Expression -> [Expression]
  shrink (Plus e1 e2)  = [e1, e2]
  shrink (Minus e1 e2) = [e1, e2]
  shrink _             = []
```

We should just keep shrinking each `Expression` to its *sub*-`Expressions`.

```haskell
>>> quickCheck prop_const_prop 
*** Failed! Falsifiable (after 26 tests and 4 shrinks):    
D
U
A + D
fromList [(D,-638),(G,256),(H,False),(K,False),(O,True),(R,True),(S,-81),(T,926)]
~~~~~

Aha! Consider the two programs

```haskell
D := A + D;   
U := A + D
``` 

and 

```haskell
D := A + D; 
U := D
```

are they equivalent? Pretty subtle, eh. 


<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Recap: Property-Based Testing

1. Property-based Testing
    - Properties are `Bool`ean-functions
    - Generate inputs, run function, check if result is `False`

2. Test Generation
    - `Gen a` is a monadic *generator* of `a` values
    - `Arbitrary` is a class for types with generators

3. **Case-Study**
    - Compiler optimizations are very tricky 
    - QC-inspired methods have found serious bugs in many compilers & databases & ...

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Recap: Property-Based Testing

QuickCheck is awesome! 

- **Simple:** typeclasses + monads

- **Useful**: Can find subtle bugs or inconsistencies in your code. 

Lots of literature on QC and techniques it has [inspired][13]

- Can even use QC to generate [test data][9] systems in *other* languages 

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>


[0]: http://www.cse.chalmers.se/~koen/
[1]: http://www.cse.chalmers.se/~rjmh/QuickCheck/
[2]: http://www.cs.york.ac.uk/fp/smallcheck/
[3]: http://video.google.com/videoplay?docid=4655369445141008672#
[4]: http://www.erlang-factory.com/upload/presentations/55/TestingErlangProgrammesforMulticore.pdf
[5]: http://en.wikipedia.org/wiki/Insertion_sort
[6]: http://hackage.haskell.org/packages/archive/QuickCheck/latest/doc/html/src/Test-QuickCheck-Gen.html#Gen
[7]: http://book.realworldhaskell.org/read/monads.html
[8]: http://book.realworldhaskell.org/read/testing-and-quality-assurance.html
[9]: http://www.haskell.org/haskellwiki/QuickCheck_as_a_test_set_generator
[10]: http://community.moertel.com/~thor/talks/pgh-pm-talk-lectrotest.pdf
[11]: http://www.cse.chalmers.se/~rjmh
[12]: https://hackage.haskell.org/package/QuickCheck-2.14/docs/src/Test.QuickCheck.Gen.html#line-76
[13]: https://arxiv.org/pdf/1812.00078.pdf
