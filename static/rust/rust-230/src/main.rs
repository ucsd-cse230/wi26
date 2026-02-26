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
