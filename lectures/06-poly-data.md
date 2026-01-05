---
title: Polymorphism
headerImg: sea.jpg
---

## Polymorphic Functions 

```haskell
doTwice :: (a -> a) -> a -> a 
doTwice f x = f (f x)
```

*Operate* on different kinds values

```haskell
>>> double x = 2 * x
>>> yum x = x ++ " yum! yum!"

>>> doTwice double 10
40
>>> doTwice yum "cookie"
"cookie yum! yum!"
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
doTwice :: (a -> a) -> a -> a
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
