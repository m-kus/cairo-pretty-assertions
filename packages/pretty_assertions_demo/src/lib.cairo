use pretty_format::PrettyFormat;

#[derive(Drop, Copy, Debug, PartialEq, PrettyFormat)]
struct TestData {
    a: u32,
    b: @ByteArray,
}

fn main() {
    let lhs = TestData { a: 132, b: @"Hello" };
    let rhs = TestData { a: 132, b: @"Hi", };
    assert_eq!(lhs, rhs);
}

#[cfg(test)]
mod tests {
    #[test]
    fn test() {
        assert_eq!(0, 1);
    }
}
