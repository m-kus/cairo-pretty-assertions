# `diff.cairo`

A Cairo port of the [`diff.rs`](https://github.com/utkarshkukreti/diff.rs) crate.

## Usage

To compute a line by line diff between two strings:

```cairo
let line_by_line_diff = diff::lines(@"left\nbar", @"right\nbaz");
```

For character level diff:

```
let char_diff = diff::chars(@"bar", @"baz");
```

The result is an array of `DiffResult` where the latter can store one of three variants:
- `Both((L, R))` if strings/characters are equal
- `Left(L)` if the element exists only in the left input
- `Right(R)` if the element exists only in the right input
