use std::f64::consts::PI;

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

// 2 + 3
fn test_expr() -> Exp {
    Exp::Bin(Op::Add, Box::new(Exp::Num(2)), Box::new(Exp::Num(3)))
}
