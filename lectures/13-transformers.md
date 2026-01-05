---
title: Mixing Monads
date: 2020-05-28
headerImg: books.jpg
--- 

## Monads Can Be Used for Many Things!

* Partial Functions
* Global Variables
* Parsing
* Exceptions
* Test Generation
* Concurrency 
* ... 

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

## Exception Handling 

Recall our expressions with division

```haskell
data Expr
  = Number Int            -- ^ 0,1,2,3,4
  | Plus   Expr Expr      -- ^ e1 + e2
  | Div    Expr Expr      -- ^ e1 / e2
  deriving (Show)
```

We had a **potentially crashing** evaluator

```haskell
eval :: Expr -> Int
eval (Number n)    = n
eval (Plus  e1 e2) = eval e1   +   eval e2
eval (Div   e1 e2) = eval e1 `div` eval e2

-- >>> eval (Div (Val 10) (Plus (Number 5) (Number (-5))))
-- Exception: Divide by zero
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

## We defined a `Result` type

```haskell
data Result a = Ok a | Err String
```

made it a `Monad` 

```haskell
instance Monad Result where
  return x      = Ok x
  (Ok v)  >>= f = f v
  (Err s) >>= _ = Err s
```

and then we can write

```haskell
eval :: Expr -> Result Int
eval (Number n)    = return n
eval (Plus  e1 e2) = do {n1 <- eval e1; n2 <- eval e2; return (n1   +   n2) } 
eval (Div   e1 e2) = do { n1 <- eval e1; 
                          n2 <- eval e2; 
                          if n2 /= 0 
                            then return (n1 `div` n2) 
                            else Err ("DBZ: " ++ show e2)
                        }
```

which doesn't crash but returns an `Err`

```haskell
>>> eval (Div (Number 10) (Plus (Number 5) (Number (-5))))
Err "DBZ: Plus (Number 5) (Number (-5))"
```

and when it succeeds it returns an `Ok`

```haskell
>>> eval (Div (Number 10) (Plus (Number 5) (Number (-5))))
Ok 1
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

## Generalizing `Result` to `Either`

The *standard library* generalizes the `Result` type to `Either` 

```haskell
data Result   a = Err String | Ok a 

data Either e a = Left e     | Right a
```

* `Err s`    becomes `Left s`
* `Ok v`     becomes `Right v`
* `Result a` becomes `Either String a`

(But we can data _other_ than `String` in the `Left` values)



<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## EXERCISE: Generalizing `Result` Monad to `Either` Monad

Lets translate the old `Monad` instance for `Result`

```haskell
instance Monad Result where

  -- return :: a -> Result a
  return x      = Ok x

  -- (>>=) :: Result a -> (a -> Result b) -> Result b
  (Ok v)  >>= f = f v
  (Err s) >>= _ = s
```

into a `Monad` instance for `Either`

```haskell
instance Monad (Either e) where
  -- return :: a -> Either e a
  return x        = ???

  -- (>>=) :: Either e a -> (a -> Either e b) -> Either e b
  (Right v) >>= f = ???  
  (Left  s) >>= _ = ??? 
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

## QUIZ


We can rewrite `eval` to return an `Either` 

```haskell
eval :: Expr -> Either Expr Int
eval (Number n)    = return n
eval (Plus  e1 e2) = do n1 <- eval e1 
                        n2 <- eval e2
                        return (n1+n2)
eval (Div   e1 e2) = do n1 <- eval e1 
                        n2 <- eval e2
                        if n2 /= 0 
                          then return (n1 `div` n2) 
                          else Left e2
```

What does `quiz` evaluate to?

```haskell
quiz = eval (Div (Val 10) (Plus (Number 5) (Number (-5))))
```

**A.** `Err "DBZ: Plus (Number 5) (Number (-5))"`

**B.** `Left "DBZ: Plus (Number 5) (Number (-5))"`

**C.** Run-time Exception 

**D.** `Plus (Number 5) (Number (-5))`

**E.** `Left (Plus (Number 5) (Number (-5)))`


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

## `Either` is an **Exception** Monad! 

What can you do with exceptions?

1. `throwError` an exception (with some value) ... 

2. `catchError` an exception (and use its value) ...

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

## 1. `throw`ing an Exception

We can simply define 

```haskell
throw :: e -> Either e a
throw exn = Left exn
``` 

and now _voila_

```haskell
eval :: Expr -> Either Expr Int
eval (Number n)    = return n
eval (Plus  e1 e2) = do n1 <- eval e1 
                        n2 <- eval e2
                        return (n1 + n2)
eval (Div   e1 e2) = do n1 <- eval e1 
                        n2 <- eval e2
                        if n2 /= 0 
                          then return (n1 `div` n2) 
                          else throw e2
```

*Exactly* the same evaluator 

- Result is a `Left` ==> an *exception* came all the way to the top.

- `Either` monad ensures the "exception" shoots to the top! 

```haskell
>>> eval (Div (Numer 10) (Plus (Number 5) (Number (-5))))
Left (Minus (Number 5) (Number 5))
```

No further evaluation happens after a `throw` because ???

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

## `catch`ing an exception

How to _catch_ an exception?

Lets change our `Expr` type to 

```haskell
data Expr
  = Number  Int            -- ^ 0,1,2,3,4
  | Plus    Expr Expr      -- ^ e1 + e2
  | Div     Expr Expr      -- ^ e1 / e2
  | Try     Expr Int       -- ^ try e1 n
  deriving (Show)
```

Informally, `try e n` evaluates to `e` but 

- **if** `e` is undefined due to *divide-by-zero* 

- **then** evaluate to `n`

```haskell
eval :: Expr -> Either Expr Int
eval (Number n)    = return n
eval (Plus  e1 e2) = do n1 <- eval e1 
                        n2 <- eval e2
                        return (n1+n2)
eval (Div   e1 e2) = do n1 <- eval e1 
                        n2 <- eval e2
                        if n2 /= 0 
                          then return (n1 `div` n2) 
                          else throw e2
eval (Try e n)     = catch (eval e) (\_ -> return n)
```

## QUIZ 

What should the _type_ of `catch` be?

**A.** `Either e a -> (a -> Either e b) -> Either e b`

**B.** `Either e a -> (e -> Either e b) -> Either e b`

**C.** `Either e a -> (e -> Either e a) -> Either e a`

**D.** `Either e a -> Either e a -> Either e a`

**E.** `Either e a -> Either e b -> Either e b`


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

## Implementing `catch`

Lets implement the `catch` function!

```haskell
catch :: Either e a -> (e -> Either e a) -> Either e a
catch (Left  e) handler = ???
catch (Right a) handler = ???
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

## QUIZ

```haskell
catch :: Either e a -> (e -> Either e a) -> Either e a
catch (Left  e) handle  = ???
catch (Right a) handler = ???

eval :: Expr -> Either Expr Int
eval (Number n)    = return n
eval (Plus  e1 e2) = do n1 <- eval e1 
                        n2 <- eval e2
                        return (n1+n2)
eval (Div   e1 e2) = do n1 <- eval e1 
                        n2 <- eval e2
                        if n2 /= 0 
                          then return (n1 `div` n2) 
                          else throw e2
eval (Try e n)     = catch (eval e) (\_ -> return n)

e1  = Div (Number 10) (Plus (Number 5) (Number (-5)))
e1' = Try e1 7

quiz = eval (Try e1 7)
```

What does `quiz` evaluate to?

**A.** `Right 7`

**B.** `Left 7`

**C.** `Right 0`

**D.** `Left 0`

**E.** `Left (Plus (Number 5) (Number (-5)))`

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

## `Either` is an **Exception** Monad! 

1. `throw` an exception (with some value) ... 

2. `catch` an exception (and use its value) ...

```haskell
throw :: e -> Either e a
throw e = Left e

catch :: Either e a -> (e -> Either e a) -> Either e a
catch (Left  e) handle = handle e
catch (Right e) _      = Right  e
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

## Monads Can Be Used for Many Things!

* Partial Functions
* Global State 
* Parsing
* Exceptions
* Test Generation
* Concurrency 
* ... 

... but what if I want *Exceptions* **and** *Global State* ?

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Mixing Monads

What if I want *Exceptions* **and** *Global State* ?

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
<br>
<br>
<br>
<br>
<br>

## Profiling with the ST Monad

Lets implement a *profiling* monad that counts the number of operations

```haskell
-- A State-Transformer with a "global" `Int` counter 
type Profile a = State Int a
```

We can write a `runProfile` that 

- executes the transformer from `0`
- and renders the result

```haskell
runProfile :: (Show a) => Profile a -> String 
runProfile st = showValCount (runState st 0)

showValCount :: (Show v, Show c) => (v, c) -> String
showValCount (val, count) = "value: " ++ show val ++ ", count: " ++ show count
```

A function to _increment_ the counter

```haskell
count :: Profile ()
count = do
  n <- get
  put (n+1)
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

## A Profiling Evaluator

We can use `count` to write a *profiling* evaluator 

```haskell
evalProf :: Expr -> Profile Int 
evalProf = eval 
  where
    eval (Number n)    = return n
    eval (Plus  e1 e2) = do n1 <- eval e1 
                            n2 <- eval e2
                            count
                            return (n1+n2)
    eval (Div   e1 e2) = do n1 <- eval e1 
                            n2 <- eval e2
                            count
                            return (n1 `div` n2) 
```

And now, as there are *two* operations, we get

```haskell
>>> e1
Div (Number 10) (Plus (Number 5) (Number 5))

>>> runProfile (evalProf e1)
"value: 1, count: 2"
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
<br>

## But what about Divide-by-Zero?

Bad things happen...


```haskell
>>> e2
Div (Number 10) (Plus (Number 5) (Number (-5)))

>>> runProfile (evalProf e2)
*** Exception: divide by zero
"value: 
``` 

**Problem:** How to get _global state_ AND _exception handling_ ?

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

## Mixing Monads with Transformers

### Start with a _Basic_ Monad 

![](/static/img/mtrans_0.png){#fig:Basic-Monad .align-right width=80%}

`m` implements 

- _no_ special operations

### Transform it to add some _Capabilities_ 

![](/static/img/mtrans_1.png){#fig:Add-Capabilities .align-right width=80%}

`Transform1 m` implements 

- `m` operations **and** 
- operations added by `Transform1`

### Transform again to add _more_ Capabilities 

![](/static/img/mtrans_2.png){#fig:More-Capabilities .align-right width=80%}

`Transform2 (Transform1 m)` implements 

- `m` operations **and** 
- operations added by `Transform1` **and**
- operations added by `Transform2` 


### ... And so on

![](/static/img/mtrans_3.png){#fig:More-Capabilities .align-right width=80%}

`Transform3 (Transform2 (Transform1 m))` implements 

- `m` operations **and** 
- operations added by `Transform1` **and**
- operations added by `Transform2` **and** 
- operations added by `Transform3` ...

Reminiscent of the [Decorator Design Pattern][2] or [Python's Decorators][3].

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


## Mixing Monads with Transformers

* Step 1: **Specifying**   Monads with Extra Features

* Step 2: **Implementing** Monads with Extra Features 

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

## Specifying Monads with Extra Features 

First, instead of using _concrete_ monads 

- e.g. `Profile` or `Either` 

We will use **type-classes** to _abstractly_ specify a monad's _capabilities_

- e.g. `MonadState s m` or `MonadError e m` 

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

## A Class for State-Transformers Monads

The class `MonadState s m` defined in the [`Control.Monad.State`][5] says

- `m` is a *State-Transformer* monad with state type `s`

```haskell 
class Monad m => MonadState s m where
  get :: m s
  put :: s -> m ()
```

That is to say, `m` implements

- `>>=` and `return` operations specified by `Monad` *and*

- `get` and `put` operations specified by `MonadState`! 

### Generalize Types to use Classes

So we can *generalize* the type of `count` to use `MonadState Int m`

```haskell
count :: (MonadState Int m) => m ()
count = do
  n <- get
  put (n+1)
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

## A Class for Exception Handling Monads

The class `MonadError e m` defined in [`Control.Monad.Except`][6] says 

- `m` is a *Exception-Handling* monad with exception type `e`

```haskell
class Monad m => MonadError e m where
  throwError :: e -> m a
  catchError :: m a -> (e -> m a) -> m a
```

That is to say, `m` implements

- `>>=` and `return` operations specified by `Monad` *and*

- `throwError` and `catchError` operations specified by `MonadError`! 

### Generalize Types to use Classes

So we can *generalize* the type of `tryCatch` to use `MonadError e m`

```haskell
tryCatch :: (MonadError e m) => m a -> a -> m a  
tryCatch m def = catchError m (\_ -> return def)
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

## Generalize `eval` to use Constraints

We can now _specify_ that `eval` uses a monad `m` that implements 

- `MonadState Int` **and** `MonadError Expr`

```haskell
eval :: (MonadState Int m, MonadError Expr m) => Expr -> m Int 
eval (Number n)    = return n
eval (Plus  e1 e2) = do n1 <- eval e1 
                        n2 <- eval e2
                        count
                        return (n1 + n2)
eval (Div   e1 e2) = do n1 <- eval e1 
                        n2 <- eval e2
                        count
                        if (n2 /= 0) 
                          then return (n1 `div` n2) 
                          else throwError e2
eval (Try e n)     = tryCatch (eval e) n
```

Lets try to run it!

```haskell
>>> e1

>>> evalMix e1
... GHC yells "please IMPLEMENT this MAGIC monad that implements BOTH features"
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
<br>


## Mixing Monads with Transformers

* Step 1: **Specifying**   Monads with Extra Features

* Step 2: **Implementing** Monads with Extra Features 

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

## Implementing Monads with **Extra Features**


![](/static/img/mtrans_2.png){#fig:More-Capabilities .align-right width=80%}

`Transform2 (Transform1 m)` implements 

- `m` operations **and** 
- operations added by `Transform1` **and** 
- operations added by `Transform2`

We require 

* A _basic_ monad `m` 
* A _Transform1_ that adds `State` capabilities 
* A _Transform2_ that adds `Exception` capabilities

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

## A Basic Monad 

First, lets make a **basic** monad 

- only implements `>>=` and `return`

```haskell
data Identity a = Id a

instance Monad Identity where
  return a     = Id a
  (Id a) >>= f = f a
```

A very _basic_ monad: just a **wrapper** (`Id`)  around the value (`a`)

- *No* extra features

![](/static/img/mtrans_id.png)

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## A Transform that adds `State` Capabilities

The transformer `StateT s m` defined in the `Control.Monad.State` [module][5]
- *takes* as input monad `m` and 

- *transforms* it into a new monad `m'`

such that `m'` implements

- all the operations that `m` implements

- *and adds* State-transformer capabilities 

`StateT s m` satisfies the constraint `(MonadState s (StateT s m))`


### A *State-transformer over `Int` states*

```haskell
type Prof = StateT Int Identity 
```

![](/static/img/mtrans_state_id.png)

We can go back and give `evalProf` the type

```haskell
evalProf :: Expr -> Prof Int
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

## A Transform that adds `Except`ion Capabilities

The transformer `ExceptT e m` 

- takes as *input* a monad `m` and 
- *transforms* it into a new monad `m'` 

such that `m'` implements

- all the operations that `m` implements

- *and adds* Exception-handling capabilities 

`ExceptT e m` satisfies the constraint `(MonadError e (ExceptT e m))`

### An Exception Handler Monad with `Expr`-typed exceptions

```haskell
type Exn = ExceptT Expr Identity 
```

![](/static/img/mtrans_except_id.png)

We can go back and give `evalThrowCatch` the type

```haskell
evalThrowCatch :: Expr -> Exn Int
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

## Composing Transformers 

We can use *both* transformers to get *both* powers! 

```haskell
type ExnProf a = ExceptT Expr (StateT Int (Identity)) a
```

![](/static/img/mtrans_except_state_id.png)

`ExnProf` implements _State-transformer-over_ `Int` **and** _Exception-handling-over-`Expr`_

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


## EXERCISE: Executing the Combined Transformer

Recall that

```haskell
type ExnProf a = ExceptT Expr (StateT Int (Identity)) a
```

Lets write a function 

```haskell
runExnProf :: (Show a) => ExnProf a -> String
runExnProf epm = ???
```

such that

```haskell
>>> runExnProf (eval e1) 
"value: 1, count: 2"

>>> runExnProf (eval e2) 
"Plus (Number 5) (Number (-5)) after 2 operations"
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


<!--

```haskell
runExnProf :: (Show a) => ExnProf a -> String
runExnProf m = case runIdentity (runStateT (runExceptT m) 0) of
                 (Right v, c) -> showValCount (v, c)
                 (Left e, c)  -> show e ++ " after " ++ show c ++ " operations"
```

--> 

## TRY AT HOME: Combining in a Different Order

We can also combine the transformers in a _different_ order

```haskell
type ProfExn a = StateT Int (ExceptT Expr (Identity)) a
```

![](/static/img/mtrans_state_except_id.png)

`ExnProf` implements _State-transformer-over_ `Int` **and** _Exception-handling-over-`Expr`_

Can you implement the function

```haskell
runProfExn :: (Show a) => ProfExn a -> String
```

such that when you are done, we can get the following behavior?

```haskell
>>> runProfExn (eval e1) 
"value: 1, count: 2"

>>> runProfExn (eval e2) 
"Left (Plus (Number 5) (Number (-5)))"
```

<!--
runProfExn :: (Show a) => ProfExn a -> String
runProfExn st = case (runIdentity (runExceptT (runStateT st 0))) of
  Right vc -> showValCount vc
  e        -> show e
-->

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Summary: Mixing Monads with Many Features

### 1. Transformers add capabilities to Monads

![](/static/img/mtrans_3.png){#fig:More-Capabilities .align-right width=80%}

`Transform2 (Transform1 m)` implements 

- `m` operations **and** 
- operations added by `Transform1` **and** 
- operations added by `Transform2`

### 2. `StateT` and `ExceptT` add State and Exceptions

* Start with a _basic_ monad `Identity` 
* Use `StateT Int` to add global-`Int` *state-update* capabilities
* Use `ExceptT Expr` to add *exception-handling* capabilities

Play around with this in your homework assignment!









[1]: http://hackage.haskell.org/packages/archive/base/latest/doc/html/Prelude.html#t:Either
[2]: http://oreilly.com/catalog/hfdesignpat/chapter/ch03.pdf
[3]: http://en.wikipedia.org/wiki/Python_syntax_and_semantics#Decorators
[4]: https://hackage.haskell.org/package/mtl-2.2.2/docs/Control-Monad-State-Lazy.html
[5]: http://hackage.haskell.org/package/mtl-2.2.2/docs/Control-Monad-Except.html
