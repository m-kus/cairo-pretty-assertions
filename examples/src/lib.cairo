#[derive(Drop, Copy, PartialEq, Debug)]
struct TestData {
    a: u32,
    b: @ByteArray,
    c: (u8, u16),
    d: Span<u64>,
}

fn main() {
    assert_eq!("hello", "hello");
    assert_eq!(@"hi", @"hi", "yeah");

    let lhs = TestData { a: 132, b: @"Hello", c: (1, 2), d: array![].span() };
    let rhs = TestData { a: 132, b: @"Hi", c: (2, 3), d: array![42].span() };

    assert_eq!(lhs, rhs, "Something is {}", 0xdead);
}

#[cfg(test)]
mod tests {
    #[test]
    fn test() {
        assert_eq!(0, 1);
    }
}
