#![allow(warnings)]

use std::f64::consts::PI;

pub mod concurrency;

fn fib(n: usize) -> usize {
    if n <= 1 {
        n
    } else {
        let mut res = fib(n - 1);
        res = res + fib(n - 2);
        res
    }
}

// fn main() {
//     println!("Hello, world!");
//     // signed 32-bit int
//     let x: i32 = 42;
//     // 64-bit (double precision float)
//     let y: f64 = 3.14;
//     // boolean
//     let z = true;
//     // tuple
//     let tup = (x + x, y * y, z || false);
//     println!("tup = {:?}", tup);
// }

// Why not ALWAYS just say `mut`
// 1. So other HUMANS know when things don't change
// 2. So the COMPILER can optimize better
// 3. So the COMPILER can catch bugs when you accidentally change something
//      - multithreading

fn change_mut(z: &mut String) {
    *z = String::from("yum yum!");
}

#[test]
fn test_mut_example() {
    let mut s = String::from("hello");
    let r = &mut s;
    println!("string is: {s}");
    change_mut(&mut s);
    let r = &mut s;
    // println!("string is now: {r}");
}

#[test]
fn change_is_bad() {
    let mut my_vec = vec![10, 20, 30];
    let r1 = &mut my_vec[1];
    let r2 = &mut my_vec[2];
    // my_vec.pop();
    println!("last = {r2}");
}

#[test]
fn quizA() {
    let mut s = String::from("yo");
    let r1 = &s;
    let r2 = &s;
    // CHANGE HERE
    // s.push_str("dog"); // BAD!
    println!("{} and {}", r1, r2);

    // CHANGE
    s.push_str("dog"); // OK!
    println!("{s}");
}

fn main() {
    let mut s = 42;
    fronkly(&mut s);
    println!("s = {}", s);
}

fn fronkly(z: &mut i32) {
    secret_inc(z)
}

fn secret_inc(a: &mut i32) {
    let curr = *a;
    *a = curr + 1;
}
fn gibbergibber(z: &mut String) {
    z.push_str(", world!");
}

fn mumble(x: &String) {
    call_me_string(x);
}

fn call_me_string(bob: &String) {
    println!("call me with s = {}", bob);
}

fn call_me_string_ret(bob: String) -> String {
    println!("call me with s = {}", bob);
    bob
}

/*

// (A)
fn main() {
    let mut s = 42;
    call_me_i32(s);
    println!("s = {}", s);
}

fn call_me_i32(s: i32) {
    println!("call me with s = {}", s);
}


// (B)



*/

fn change_bob(mut z: Vec<i32>) {
    z.pop();
}

fn bob() {
    let v = vec![10, 20, 30];
    let r0 = &v[0];
    let r1 = &v[1];
    let r2 = &v[2];
    println!("elems are {:?}, {:?}, {:?}", *r0, *r1, *r2);
    // let mr = &mut v;
    change_bob(v);
    // change_bob(v);
    // println!("r1 is {:?}", *r1); NOT ok
    // println!("v is {:?}", v); // OK
}

#[derive(Debug)]
struct Circle {
    x: f64,
    y: f64,
    radius: f64,
}

fn circle_area(c: &Circle) -> f64 {
    let r = c.radius;
    PI * r * r
}

#[test]
fn test_circle_area() {
    let c = Circle {
        x: 0.0,
        y: 0.0,
        radius: 10.0,
    };
    let area = circle_area(&c);
    println!("circle {c:?} has area = {area}");
}

#[derive(Debug)]
enum Shape {
    Rect(f64, f64),        // width, height
    Poly(Vec<(f64, f64)>), // list of points
}

fn shape_area(s: &Shape) -> f64 {
    match s {
        Shape::Rect(w, h) => w * h,
        Shape::Poly(pts) => poly_area(pts),
    }
}

fn poly_area(pts: &Vec<(f64, f64)>) -> f64 {
    todo!()
}
/*
fn poly_area(pts: Vec<(f64, f64)>) -> f64

*/

fn test_area() {
    let sh = Shape::Rect(10.0, 20.0);
    let area = shape_area(&sh);
    println!("shape {sh:?} has area = {area}");
}

// ----------------------------------------------------------------------------------------------------------------

/*
data Op = Add | Mul | Sub | Div
    deriving(Show)

data Exp = Num Int | Bin Op Exp Exp
*/

#[derive(Debug)]
enum Op {
    Add,
    Mul,
    Sub,
    Div,
}

#[derive(Debug)]
enum Exp {
    Num(i32),
    Bin(Op, Box<Exp>, Box<Exp>),
}

fn bin(op: Op, e1: Exp, e2: Exp) -> Exp {
    Exp::Bin(op, Box::new(e1), Box::new(e2))
}

// 2 + 3
fn test_expr() -> Exp {
    bin(Op::Add, Exp::Num(2), Exp::Num(3))
}

fn test_box_i32() {
    let blah: i32 = 99;
    let mumbles = Box::new(&blah);
}

fn eval_op(op: &Op, v1: i32, v2: i32) -> Option<i32> {
    match op {
        Op::Add => Some(v1 + v2),
        Op::Mul => Some(v1 * v2),
        Op::Sub => Some(v1 - v2),
        Op::Div => {
            if v2 != 0 {
                Some(v1 / v2)
            } else {
                None
            }
        }
    }
}

fn top_eval(e: &Exp) {
    match eval(e) {
        Ok(val) => println!("RESULT = {val}"),
        Err(_) => println!("boo hoho"),
    }
}

fn eval(e: &Exp) -> Result<i32, String> {
    match e {
        Exp::Num(n) => Ok(*n),
        Exp::Bin(op, e1, e2) => {
            let res = eval_op(op, eval(e1)?, eval(e2)?);
            match res {
                Some(n) => Ok(n),
                None => Err(format!("yikes, dbz {e2:?}")),
            }
        } /*  Exp::Bin(op, e1, e2) => {
          let v1 = match eval(e1) {
            Some(v) => v,
            None => return None,
          };
          let v2 =  match eval(e2) {
            Some(v) => v,
            None => return None,
          };
          eval_op(op, v1, v2),
          */
    }
}

/*
    match expr {
        Ok(v) => v,
        Err(e) => return Err(e),
    }

    expr?
*/

#[test]
fn test_vec() {
    let mut vec = vec![10, 1, 20, 3, 4];
    assert!(vec[1] * 3 == vec[3]);
    vec.sort();
    println!("sorted => {vec:?}");
}

#[test]
fn test_eval() {
    let e = bin(Op::Add, Exp::Num(2), Exp::Num(3));
    let n = eval(&e);
    println!("result of {e:?} ==> {n:?}");
}

fn test_opt() -> Option<i32> {
    Some(45)
}

// --- Box<T>

/*

data Maybe a
    = Just a
    | Nothing

enum Option<T> {
    Some(T),
    None,
}


data Either e t
    = Left e
    | Right t

enum Result<T, E> {
    Ok(T),
    Err(E),
}
*/

struct Range {
    begin: usize,
    end: usize,
}

fn first_word(z: &Vec<char>) -> Range {
    let begin = 0;
    let mut end = 0;
    while z[end] != ' ' {
        end += 1;
    }
    Range { begin, end }
}

fn last_word(z: &Vec<char>) -> Range {
    let end = z.len();
    let mut begin = z.len() - 1;
    while begin > 0 && z[begin - 1] != ' ' {
        begin -= 1;
    }
    Range { begin, end }
}

fn print_word(z: &Vec<char>, rng: &Range) {
    print!("<");
    for i in rng.begin..rng.end {
        print!("{}", z[i])
    }
    println!(">");
}

fn print_word_slice(z: &[char]) {
    print!("<");
    for ch in z {
        print!("{ch}");
    }
    println!(">");
}

fn first_word_slice(z: &mut Vec<char>) -> &mut [char] {
    let begin = 0;
    let mut end = 0;
    while z[end] != ' ' {
        end += 1;
    }
    &mut z[begin..end]
}

fn last_word_slice<'a>(z: &'a Vec<char>) -> &'a [char] {
    let end = z.len();
    let mut begin = z.len() - 1;
    while begin > 0 && z[begin - 1] != ' ' {
        begin -= 1;
    }
    &z[begin..end]
}

#[test]
fn test_bat_man_slice() {
    let mut str = vec!['b', 'a', 't', ' ', 'm', 'a', 'n', 'g', 'o'];

    let first = first_word_slice(&mut str);
    first[0] = 'c';
    print_word_slice(first);

    // let last = last_word_slice(&str); // ------- CREATE IMMUTABLE BORROW
    // print_word_slice(last); // <------ USING IMMUTABLE BORROW

    // println!("first word is {:?}, last word is {:?}", first, last);

    // let blah = &mut str[0..5];
    // blah[0] = 'c';

    println!("{str:?}");
}

// fn longer_og(my_slice: &[char]) -> &[char] {
//     let vec = vec!['a', 'b', 'c'];
//     let bob = &vec[0..2];
//     bob
//     // &my_slice[0..4]
// }

/*
let thing : Thing = mk_thing();
let bob = &thing;
bob.call_method()

*/

fn longer<'banana>(w1: &'banana [char], w2: &'banana [char]) -> &'banana [char] {
    if w1.len() < w2.len() { w2 } else { w1 }
}

// fn test_bla_blah() {
//     let r;
//     {
//         let x = 92;
//         r = &x;
//     }
//     println!("The value of r = {r}")
// }

#[test]
fn test_bat_man() {
    let str = vec!['b', 'a', 't', ' ', 'm', 'a', 'n', 'g', 'o'];

    let first = first_word(&str);
    print_word(&str, &first);

    let last = last_word(&str);
    print_word(&str, &last);
}

// ---

trait Summary {
    fn summarize(&self) -> String;
    fn size(&self) -> usize;

    fn kind() -> String;
}

struct Article {
    headline: String,
    author: String,
}

impl Summary for Article {
    fn summarize(&self) -> String {
        format!("{}, by {}", self.headline, self.author)
    }

    fn size(&self) -> usize {
        self.headline.len()
    }

    fn kind() -> String {
        String::from("Article")
    }
}

#[derive(Debug)]
enum Quarter {
    Fall,
    Winter,
    Spring,
}

struct Midterm {
    year: usize,
    quarter: Quarter,
    course: String,
}

impl Midterm {
    fn get_year(&self) -> usize {
        self.year
    }
}

impl Summary for Midterm {
    fn summarize(&self) -> String {
        format!(
            "Midterm {} for {} {:?}",
            self.course, self.year, self.quarter
        )
    }

    fn size(&self) -> usize {
        0
    }

    fn kind() -> String {
        String::from("Midterm")
    }
}

#[test]
fn test_article() {
    let article0 = Article {
        headline: String::from("My Headline"),
        author: String::from("me"),
    };
    let s = article0.summarize();
    // article0.get_year();

    let k = Article::kind();
    println!("SUMMARY {s} --> {k}");

    let mid0 = Midterm {
        year: 2026,
        quarter: Quarter::Winter,
        course: String::from("CSE 230"),
    };

    print_summary(article0);
    print_summary(mid0);
}

fn test_midterm() {
    let mid0 = Midterm {
        year: 2026,
        quarter: Quarter::Winter,
        course: String::from("CSE 230"),
    };
    mid0.get_year();
}

/*
takes as input a THING that implements Summary

and prints out the summary


print_summary :: (Summary a, Debug a) => a -> IO ()

*/

fn print_summary<T>(thing: T)
where
    T: Summary,
{
    let s = thing.summarize();
    println!("Summary of {s}");
}

#[test]
fn test_loop() {
    let my_vec: Vec<i32> = vec![10, 20, 30, 40, 50];
    let res: Vec<i32> = my_vec
        .iter()
        .map(|n| n + 1)
        .filter(|v| *v % 20 == 0)
        .collect();

    println!("RES = {res:?}");

    // let mut iter = my_vec.iter();

    // println!("NEXT: {:?}", iter.next());
    // println!("NEXT: {:?}", iter.next());
    // println!("NEXT: {:?}", iter.next());
    // println!("NEXT: {:?}", iter.next());
    // println!("NEXT: {:?}", iter.next());
    // println!("NEXT: {:?}", iter.next());
    // println!("NEXT: {:?}", iter.next());
    // println!("NEXT: {:?}", iter.next());

    /*
       for v in my_vec {
           total += v
       }

       let mut iter = my_vec.iter();
       while let Some(v) = iter.next() {
           total += v;
       }


    */

    // let mut total = 0;

    // for i in 0..100 {
    //     total += i;
    // }
}
