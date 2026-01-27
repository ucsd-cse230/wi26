
fn fib(n: usize) -> usize {
    if n <= 1 {
        n
    } else {
        let res = fib(n - 1);
        res = res + fib(n - 2);
        res
    }
}

fn main() {
    println!("Hello, world!");
    // signed 32-bit int
    let x: i32 = 42;
    // 64-bit (double precision float)
    let y: f64 = 3.14;
    // boolean
    let z = true;
    // tuple
    let tup = (x + x, y * y, z || false);
    println!("tup = {:?}", tup);
}
