pub mod printer;
pub mod prettier;

use prettier::pretty_debug_fmt;
use core::fmt::{Formatter, Debug};

pub fn assert_eq<T, +Debug<T>, +PartialEq<T>, +Drop<T>>(lhs: T, rhs: T) {
    assert_eq_inner(lhs, rhs, "", 4, true);
}

pub fn assert_eq_macro<T, +Debug<T>, +PartialEq<T>, +Drop<T>>(lhs: T, rhs: T, message: ByteArray) {
    assert_eq_inner(lhs, rhs, message, 2, false);
}

pub fn assert_eq_inner<T, +Debug<T>, +PartialEq<T>, +Drop<T>>(lhs: T, rhs: T, message: ByteArray, indent: usize, hex_string: bool) {
    if lhs != rhs {
        let left = pretty_debug_fmt(lhs, indent, hex_string);
        let right = pretty_debug_fmt(rhs, indent, hex_string);
        let mut f: Formatter = Default::default();
        write!(f, "assertion failed: `(left == right)` {message}\n\n").unwrap();
        printer::write_header(ref f).unwrap();
        printer::write_lines(ref f, @left, @right).unwrap();
        // TODO: use panic! when cairo1-run supports printing ByteArrays
        print!("{}", f.buffer);
        core::panics::panic(array![]);
    }
}
