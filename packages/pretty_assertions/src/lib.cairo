mod printer;

use pretty_format::PrettyFormat;
use core::fmt::Formatter;

pub fn assert_eq<T, +PrettyFormat<T>, +PartialEq<T>, +Drop<T>>(lhs: T, rhs: T, message: ByteArray) {
    if lhs != rhs {
        let indent: ByteArray = "  ";
        let left = lhs.to_string(@indent).unwrap();
        let right = rhs.to_string(@indent).unwrap();
        let mut f: Formatter = Default::default();
        write!(f, "assertion failed: `(left == right)` {message}\n\n").unwrap();
        printer::write_header(ref f).unwrap();
        printer::write_lines(ref f, @left, @right).unwrap();
        print!("{}", f.buffer);
        core::panics::panic(array![]);
    }
}
