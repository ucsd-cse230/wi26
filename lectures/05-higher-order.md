---
title: Higher-Order Functions
headerImg: sea.jpg
---

## Functions are *first-class* values

Can be treated as *any* other data

```haskell
plus1 :: Int -> Int
plus1 x = x + 1

minus1 :: Int -> Int
minus1 x = x - 1
``` 

You can make a *pair* of functions

```haskell
funPair = (plus1, minus1)
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

What is the type of `funPair` ? 

```haskell
plus1 :: Int -> Int
plus1 x = x + 1

minus1 :: Int -> Int
minus1 x = x - 1

funPair :: ???
funPair = (plus1, minus1)
```

**A.** `Int -> Int`

**B.** `(Int, Int) -> Int`

**C.** `Int -> (Int, Int)`

**D.** `(Int, Int) -> (Int, Int)`

**E.** `(Int -> Int, Int-> Int)`

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

Or you can make *lists* of functions:

What is the type of `funList` ? 

```haskell
plus1 :: Int -> Int
plus1 x = x + 1

minus1 :: Int -> Int
minus1 x = x - 1

funList :: ???
funList = [plus1, minus1]
```

**A.** `Int -> Int`

**B.** `[Int -> Int]`

**C.** `[Int] -> Int`

**D.** `Int -> [Int]`

**E.** `[Int] -> [Int]`

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



## Functions are data

So we can write *higher-order functions* 

- Functions that take *other* functions as *input*
- Functions that return *other* functions as *output*

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


## Using Functions as Input

For example consider

```haskell
doTwice f x = f (f x)
```

The function `doTwice` 

- takes *two inputs* : a function `f` and value  `x`,
- returns the result of `f (f x)` 

**Note:** how the code is clearer to understand than English...

Btw, which $\lambda$-calculus term does this remind you of?

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

## Lets Run `doTwice`

```haskell
>>> doTwice plus1 10
12
>>> doTwice minus1 100
98
```

**REMINDER:** Execution model is *substitute equals for equals*

```haskell
doTwice plus1 10 
                        -- definition of doTwice
==> plus1 (plus1 10)
                        -- definition of plus1 
==> plus1 (10 + 1)
                        -- definition of plus1 
==> (10 + 1) + 1
                        -- arithmetic
==> 12
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

## Functions as Output

Instead of separate `plus1`, `plus2`, `plus3` *etc.* lets write

```haskell
plus :: Int -> (Int -> Int)
plus n = \x -> x + n 
```

So `plus n` returns `\x -> x + n`. Lets use it!

```haskell
plus10 :: Int -> Int
plus10  = plus 10

minus20 :: Int -> Int
minus20 = plus (-20)
```

Lets run it!

```haskell
plus10 100
                        -- definition of plus10
==> (plus 10) 110
                        -- definition of plus
==> (\x -> x + 10) 100
                        -- "beta-step"
==> 100 + 10
                        -- arithmetic
==> 110
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

What is the value of `quiz` ?

```haskell
plus :: Int -> (Int -> Int)
plus n = \x -> x + n 

quiz = plus 25 100
```

**A.** Error

**B.** `\x -> x + 100`

**C.** `\x -> x + 25`

**D.** `125`

**E.** `110`

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

## QUIZ: Partial Application

Recall that in Haskell the following **mean the same thing**

```haskell
plus n x  = n + x
plus n    = \x -> n + x
plus      = \n x -> n + x
```

So you can pass *zero* inputs

```haskell 
zeroIn = plus

oneIn  = plus 10

twoIn  = plus 10 20
```

What is the type of `zeroIn`, `oneIn` and `twoIn` ? 

**A.** `Int` 

**B.** `Int -> Int`

**C.** `Int -> Int -> Int`


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

## QUIZ

What is the value of `quiz` ?

```haskell
doTwice f x = f (f x)

plus n x    = n + x

oneIn       = plus 10

quiz        = doTwice oneIn 0
```

**A.** *Type Error*

**B.** `0`

**C.** `10`

**D.** `20`

**E.** `30`




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

## Lets Run It!

```haskell
doTwice f x = f (f x)
plus n x    = n + x
oneIn       = plus 10
quiz        = doTwice oneIn 0
```

So (do in class)

```haskell
quiz 
==> ???
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

## Polymorphism

We used to `doTwice` to repeat an arithmetic operation

```haskell
>>> doTwice (plus 25) 0
50
```

but `doTwice` works for types *other than* than `Int` too

```haskell
>>> doTwice f x = f (f x)

>>> sayYum s = s ++ " yum! yum!" 

>>> sayYum "ice cream"
"ice cream yum! yum!"

>>> doTwice sayYum "ice cream"
"ice cream yum! yum! yum! yum!"
```


`doTwice` is **polymorphic**  i.e. works with

- *many kinds* of values
- e.g. functions adding `Int`
- e.g. functions that concatenate `String`


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

What is the value of `quiz`?

```haskell
greaterThan :: Int -> Int -> Bool
greaterThan x y = x > y

quiz = doTwice (greaterThan 10) 0
```

**A.** `True`

**B.** `False`

**C.** *Type* Error

**D.** *Run-time* Exception

**E.** `101`


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



## With great power, comes great responsibility!

```haskell
>>> doTwice (greaterThan 10) 0 

36:9: Couldn't match type ‘Bool’ with ‘Int’
    Expected type: Int -> Int
      Actual type: Int -> Bool
    In the first argument of ‘doTwice’, namely ‘greaterThan 10’
    In the expression: doTwice (greaterThan 10) 0
``` 

**The input and output types are different!** 

Cannot feed the *output* of `(greaterThan 10 0)` into `greaterThan 10`! 


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

## Polymorphic Types

But the **type of** `doTwice` would have spared us this grief.

```haskell
>>> :t doTwice
doTwice :: (t -> t) -> t -> t
```

The signature has a *type parameter* `t`

- **re-use** `doTwice` to increment `Int` or concat `String` or ...

- The first argument `f` must take *input* `t` and return *output* `t` (i.e. `t -> t`)

- The second argument `x` must be of type `t` 

- Then `f x` will *also* have type `t` ... and we can call `f (f x)`.

But `f`unction is *incompatible* with `doTwice`

- if its input and output types *differ* 

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

Lets make sure you're following! 

What is the type of `quiz`?

```haskell
quiz x f = f x
```

**A.** `a -> a`

**B.** `(a -> a) -> a`

**C.** `a -> b -> a -> b`

**D.** `a -> (a -> b) -> b`

**E.** `a -> b -> a`

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

Lets make sure you're following! 

What is the *value* of `quiz`?

```haskell
apply x f = f x

greaterThan :: Int -> Int -> Bool
greaterThan x y = x > y

quiz = apply 100 (greaterThan 10)
```

**A.** *Type* Error

**B.** *Run-time* Exception

**C.** `True`

**D.** `False`

**E.** `110`

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

[1]: http://hackage.haskell.org/packages/archive/base/latest/doc/html/Data-List.html "Data.List"
[2]: http://haskell.org/hoogle "Hoogle Query: Char -> Char"
[3]: http://www.livescience.com/health/070412_rhesus_monkeys.html
[4]: http://en.wikipedia.org/wiki/MapReduce "MapReduce"
