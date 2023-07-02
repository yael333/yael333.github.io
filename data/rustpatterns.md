My journey with Rust has been rocky to say the least, from fandom to hating back to loving it, I never stopped learning about how I program and engineer. I'm a huge nerd of Functional Programming and the thing that absolutely sold me about rust is it's algebric type system, it is my biggest joy to bring type proofness and complexity to low level programs. The pattern matching in it makes for expressive, readable and type-safe code. In this blog article we will take a look at this topic, and I hope you can learn something from it :3

## Patterns

### Refutable vs irrefutable
Patterns in Rust come in two types; refutable and irrefutable. Patterns that match conditionally are called refutable, while patterns that match any possible value are called irrefutable. Which one you can use will depend on the context. For example, a let-statement will need a irrefutable pattern, because what would happen if a variable in a let-statement doesn’t get a value?

```rust
// Irrefutable patterns - variable bindings, always succeeds
let x = 5;
let (x, y) = (1, 2);

// Doesn't compile
let Ok(x) = string.parse::<i32>() // parsing a string will return a Result<T>, and it is refutable whether it's an OK(x)
```

if let statements on the other hand can have refutable patterns, as the body is evaluated conditionally and it's refutability is inherent:

```rust
if let Ok(x) = string.parse::<i32>() {
  // ... do something if string can be parsed as a 32 bit integer ...
}

// if let can have a refutable pattern, so we can also use a value for x:
if let Ok(64) = someString.parse::<i32>() {
  // ... do something if string can be parsed as a 32 bit integer ...
}
``` 

## Destructuring
Many patterns destructure various types, and they can also be mixed and match together. Let’s look at some of them together~

### Tuples
You are already probably familiar with tuple destructuring, but let's examine again:

```rust
// tuple: (i32, i32, &str)
let tuple = (1, 2, "three");
let (x, y, z_str) = tuple;
```

We see in the last line that tuple is destructured into 3 new variables: x, y, and z_str.
This can be done for all sorts of tuples, as long as the destructured types match.

My favorite trick is that you can match elements with ``..`` or ``_``, which are used to skip elements and create more complex logic:

```rust
// discard z_str
let (x, y, _) = tuple;

// get only x
let (x, ..) = tuple;

let big_tuple = (1, 2, 3, 4, 5);

// Does not compile, ambigious pattern.
let (..., middle, ...) = big_tuple;
```
(Patterns have to be unambigious)

### Structs
Structs are not much different than tuples, I'll save your internet bandwidth by not showing an example although it is very self explanatory. The only difference is the .. behaviour, when deconstructing it has to come last and it means to match the rest and ignore the result.

### Enums
This might be the simplest yet most important of them all, the simplest case for enum deconstructing is to match one with no data:

```rust
// simple enum
enum TrafficSignal {
    Red,
    Orange,
    Green
}

// match if our color is green
if let Color::green = my_color {
    // cars go!
}
```

Luckily, Rust enums are way way more interesting as they contain data. So much complexity arises out of that.

```rust
// complex enum
enum Enemy {
    Alive(u32),
    Dead
}

// match against an alive enemy
if let Enemy::Alive(data) = my_enemy {
    // oh no! gotta beat them >:3
}

// match against a dead enemy
if let Enemy::Dead = my_enemy {
    // you win~!
}
```

## Other Patterns
There are other types of patterns in Rust that capture a lot of elementary and cool behaviour. Since they're varied it is best to just demonstrate them:

```rust
// OR pattern

1 | 2 | 3 // matches 1, 2, or 3
"one" | "two" // matches one of these two strings

// range pattern

1..=10 // matches 1 to 10 (inclusive)
1..10 // matches 1 to 10 (non-inclusive)

// at pattern
struct Point {
    x: i32,
    y: i32
}

// matches if my_x exists under an optional condition
if let Point {x: my_x @ 1..=10, ..} = my_data {
    // my_x is between 1 and 10.
}
```

## The Payoff
pattern matching is closely related to Rust's powerful algebric type system. We can combine the different behaviours of patterns in order to write clear and simply awesome code~!<br>
One example that speaks to itself and shows the immense power pattern matching has is to pit it against object-oriented code. let's consider a case where we have a Shape hierarchy with two concrete classes (Circle and Rectangle), we'll compare the object-oriented approach in java with the pattern matching code in Rust.

### Java (OOP):
```java
abstract class Shape {
    abstract double calculateArea();
}

class Circle extends Shape {
    private double radius;

    public Circle(double radius) {
        this.radius = radius;
    }

    public double calculateArea() {
        return Math.PI * radius * radius;
    }
}

class Rectangle extends Shape {
    private double width;
    private double height;

    public Rectangle(double width, double height) {
        this.width = width;
        this.height = height;
    }

    public double calculateArea() {
        return width * height;
    }
}

public class Main {
    public static void main(String[] args) {
        Shape shape = new Circle(5.0);

        if (shape instanceof Circle) {
            Circle circle = (Circle) shape;
            double area = circle.calculateArea();
            System.out.println("Area of Circle: " + area);
        } else if (shape instanceof Rectangle) {
            Rectangle rectangle = (Rectangle) shape;
            double area = rectangle.calculateArea();
            System.out.println("Area of Rectangle: " + area);
        }
    }
}
```
### Rust (Pattern Matching):
```rust
enum Shape {
    Circle(f64),
    Rectangle(f64, f64),
}

fn calculate_area(shape: Shape) -> f64 {
    match shape {
        Shape::Circle(radius) => std::f64::consts::PI * radius * radius,
        Shape::Rectangle(width, height) => width * height,
    }
}

fn main() {
    let circle = Shape::Circle(5.0);
    let circleArea = calculate_area(circle);
    let rectangle = Shape::Rectangle(5.0, 2.0);
    let rectangleArea = calculate_area(rectangle);
    
    println!("Area of Circle: {circleArea}", circleArea);
    println!("Area of Rectangle: {rectangleArea}", rectangleArea);
}
```

### Conclusions
I could go on about it for much longer, although I hope that was enough for the knowledge-hungry.
I hope you now understand pattern matching a little better and see how it is a fundamental and powerful feature in Rust that contributes to its overall expressiveness and safety. Embracing it in my code greatly enchanced my programming exprience and generally leads to more robust and maintanable applications.