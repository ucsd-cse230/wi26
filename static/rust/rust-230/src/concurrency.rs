use std::sync::Arc;
use std::sync::Mutex;
use std::sync::mpsc;
use std::thread;
use std::time::Duration;

#[test]
fn test() {
    assert!(3 == 1 + 2)
}

// -------------------------------------------------------------------

#[test]
fn test_spawn() {
    thread::spawn(|| {
        for i in 1..10 {
            println!("mr spawn says: {i}");
            thread::sleep(Duration::from_millis(1));
        }
    });

    for i in 1..3 {
        println!("main says: {i}");
        thread::sleep(Duration::from_millis(1));
    }
}

// -------------------------------------------------------------------

#[test]
fn test_spawn_join() {
    let plz_wait = thread::spawn(|| {
        for i in 1..10 {
            println!("spawned: {i}");
            thread::sleep(Duration::from_millis(1));
        }
    });

    for i in 1..3 {
        println!("main: {i}");
        thread::sleep(Duration::from_millis(1));
    }

    plz_wait.join().unwrap(); // wait for spawned thread to finish
}

// -------------------------------------------------------------------

#[test]
fn test_spawn_with_move() {
    let mut v = vec![1, 2, 3];

    let handle = thread::spawn(move || {
        println!("Here's a vector: {:?}", v);
    });

    // v.pop();

    handle.join().unwrap();
}

// -------------------------------------------------------------------

#[test]
fn test_channel() {
    let (tx, rx) = mpsc::channel();

    thread::spawn(move || {
        let msg = String::from("hey hey!");
        tx.send(msg).unwrap();
        // println!("sent: {msg}");
    });

    let received = rx.recv().unwrap();
    println!("Got: {received}");
}
// -------------------------------------------------------------------

#[test]
fn test_multiple_messages() {
    let (tx, rx) = mpsc::channel();

    thread::spawn(move || {
        let msgs = vec!["hello", "from", "the", "other", "side"];
        for msg in msgs {
            tx.send(String::from(msg)).unwrap();
            thread::sleep(Duration::from_millis(300));
        }
    });

    for received in rx {
        // rx works as an iterator!
        println!("Got: {received}");
    }
}

// -------------------------------------------------------------------

#[test]
fn test_multiple_producers() {
    let (tx1, rx) = mpsc::channel();

    let tx2 = tx1.clone();
    thread::spawn(move || {
        let msgs = vec!["hello", "from", "the", "other", "side"];
        for msg in msgs {
            tx1.send(String::from(msg)).unwrap();
        }
    });

    thread::spawn(move || {
        let msgs = vec!["i", "must've", "called", "a", "thousand", "times"];
        for msg in msgs {
            tx2.send(String::from(msg)).unwrap();
        }
    });

    for received in rx {
        println!("Got: {received}");
    }
}

// -------------------------------------------------------------------

#[test]
fn test_mutex() {
    let m = Mutex::new(5);

    {
        let mut num = m.lock().unwrap(); // acquire lock
        *num += 1; // mutate the data
    } // lock released automatically!

    println!("m = {:?}", m); // m = Mutex { data: 6 }
}

// -------------------------------------------------------------------
#[test]
fn test_mutex_simple() {
    let counter = Arc::new(Mutex::new(0));

    let thread_counter = counter.clone();
    let plz_wait = thread::spawn(move || {
        let mut num = thread_counter.lock().unwrap();
        *num += 1;
        println!("thread: BEFORE pause");
        thread::sleep(Duration::from_millis(5000));
        println!("thread: AFTER pause");
    });

    println!("Result: {}", *counter.lock().unwrap());

    plz_wait.join().unwrap();

    iter.for_each(|x| -> { do_thing })
    for x in iter {
        do_thing
    }
}

#[test]
fn test_mutex_many() {
    let counter = Arc::new(Mutex::new(0));
    let mut handles = vec![];

    for _ in 0..10 {
        let counter = counter.clone();
        let handle = thread::spawn(move || {
            // do stuff BEFORE
            {
                let mut num = counter.lock().unwrap();
                *num += 5;
            }
            // do stuff AFTER
        });
        handles.push(handle);
    }

    for handle in handles {
        handle.join().unwrap();
    }

    println!("Result: {}", *counter.lock().unwrap());
}
