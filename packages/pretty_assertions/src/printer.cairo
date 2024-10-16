use core::fmt::{Formatter, Error};

/// Present the diff output for two mutliline strings in a pretty, colorised manner.
pub fn write_header(ref f: Formatter) -> Result<(), Error> {
    writeln!(f, "\x1b[1mDiff\x1b[0m \x1b[31m< left\x1b[0m / \x1b[32mright >\x1b[0m :")
}

/// Delay formatting this deleted chunk until later.
///
/// It can be formatted as a whole chunk by calling `flush`, or the inner value
/// obtained with `take` for further processing (such as an inline diff).
#[derive(Drop, Copy, Default)]
struct LatentDeletion {
    // The most recent deleted line we've seen
    value: Option<@ByteArray>,
    // The number of deleted lines we've seen, including the current value
    count: usize,
}

#[generate_trait]
pub impl LatentDeletionImpl of LatentDeletionTrait {
    /// Set the chunk value.
    fn set(ref self: LatentDeletion, value: @ByteArray) {
        self.value = Option::Some(value);
        self.count += 1;
    }

    /// Take the underlying chunk value, if it's suitable for inline diffing.
    ///
    /// If there is no value or we've seen more than one line, return `None`.
    fn take(ref self: LatentDeletion) -> Option<@ByteArray> {
        if self.count == 1 {
            let res = self.value;
            self.value = Option::None;
            res
        } else {
            Option::None
        }
    }

    /// If a value is set, print it as a whole chunk, using the given formatter.
    ///
    /// If a value is not set, reset the count to zero (as we've called `flush` twice,
    /// without seeing another deletion. Therefore the line in the middle was something else).
    fn flush(ref self: LatentDeletion, ref f: Formatter) -> Result<(), Error> {
        if let Option::Some(value) = self.value {
            writeln!(f, "\x1b[31m<{value}\x1b[0m")?;
            self.value = Option::None;
        } else {
            self.count = 0;
        }

        Result::Ok(())
    }
}

// Adapted from:
// https://github.com/johannhof/difference.rs/blob/c5749ad7d82aa3d480c15cb61af9f6baa08f116f/examples/github-style.rs
// Credits johannhof (MIT License)

/// Present the diff output for two mutliline strings in a pretty, colorised manner.
pub fn write_lines(ref f: Formatter, left: @ByteArray, right: @ByteArray,) -> Result<(), Error> {
    let mut changes = diff::lines(left, right);
    let mut next_change = changes.pop_front();
    let mut previous_deletion: LatentDeletion = Default::default();
    let mut inner_result = Result::<(), Error>::Ok(());

    while let Option::Some(change) = next_change {
        next_change = changes.pop_front();
        match change {
            // If the text is unchanged, just print it plain
            diff::DiffResult::Both((
                value, _
            )) => {
                inner_result = previous_deletion.flush(ref f);
                if inner_result.is_err() {
                    break;
                }
                inner_result = writeln!(f, " {}", value);
            },
            // Defer any deletions to next loop
            diff::DiffResult::Left(deleted) => {
                inner_result = previous_deletion.flush(ref f);
                if inner_result.is_err() {
                    break;
                }
                previous_deletion.set(deleted);
            },
            diff::DiffResult::Right(inserted) => {
                if is_right(next_change) {
                    // If we're being followed by more insertions, don't inline diff
                    inner_result = previous_deletion.flush(ref f);
                    if inner_result.is_err() {
                        break;
                    }
                    inner_result = writeln!(f, "\x1b[32m>{inserted}\x1b[0m");
                } else {
                    // Otherwise, check if we need to inline diff with the previous line (if it was
                    // a deletion)
                    if let Option::Some(deleted) = previous_deletion.take() {
                        inner_result = write_inline_diff(ref f, deleted, inserted);
                    } else {
                        inner_result = previous_deletion.flush(ref f);
                        if inner_result.is_err() {
                            break;
                        }
                        inner_result = writeln!(f, "\x1b[32m>{inserted}\x1b[0m");
                    }
                }
            },
        };
        if inner_result.is_err() {
            break;
        }
    };

    previous_deletion.flush(ref f)?;
    Result::Ok(())
}

/// Returns true if pattern matches Option::Some(diff::DiffResult::Right(_))
fn is_right<T, +Drop<T>>(maybe_diff: Option<diff::DiffResult<T>>) -> bool {
    if let Option::Some(diff) = maybe_diff {
        if let diff::DiffResult::Right(_) = diff {
            return true;
        }
    }
    false
}

/// Format a single line to show an inline diff of the two strings given.
///
/// The given strings should not have a trailing newline.
///
/// The output of this function will be two lines, each with a trailing newline.
pub fn write_inline_diff(
    ref f: Formatter, left: @ByteArray, right: @ByteArray
) -> Result<(), Error> {
    let char_diff = diff::chars(left, right).span();
    let mut inner_result = Result::<(), Error>::Ok(());

    // Print the left string on one line, with differences highlighted
    write!(f, "\x1b[31m<\x1b[0m")?;
    for change in char_diff {
        inner_result = match change {
            diff::DiffResult::Both((
                value, _
            )) => write!(f, "\x1b[31m{}\x1b[0m", char_to_str(*value)),
            diff::DiffResult::Left(value) => write!(
                f, "\x1b[91m\x1b[1m{}\x1b[0m", char_to_str(*value)
            ),
            _ => Result::Ok(()),
        };
        if inner_result.is_err() {
            break;
        }
    };
    if inner_result.is_err() {
        return inner_result;
    }
    writeln!(f, "")?;

    // Print the right string on one line, with differences highlighted
    write!(f, "\x1b[32m>\x1b[0m")?;
    for change in char_diff {
        inner_result = match change {
            diff::DiffResult::Both((
                value, _
            )) => write!(f, "\x1b[32m{}\x1b[0m", char_to_str(*value)),
            diff::DiffResult::Right(value) => write!(
                f, "\x1b[92m\x1b[1m{}\x1b[0m", char_to_str(*value)
            ),
            _ => Result::Ok(()),
        };
        if inner_result.is_err() {
            break;
        }
    };
    inner_result?;
    writeln!(f, "")
}

/// Converts single character to a string containing single symbol
fn char_to_str(char: u8) -> ByteArray {
    let mut str = "";
    str.append_byte(char);
    str
}
