# Pretty assertions

A Cairo port of the [`rust-pretty-assertions`](https://github.com/rust-pretty-assertions/rust-pretty-assertions) crate.

## Usage

```cairo
assert_eq!(lhs, rhs, "error message: {}", 42);
pretty_assertions::assert_eq(lhs, rhs);
```

Note that the arguments have to implement `Debug`, `PartialEq`, and `Drop`.
