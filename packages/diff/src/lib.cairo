mod types;
mod diff;
mod string;

pub use types::DiffResult;
pub use diff::do_diff;
pub use string::{split_chars, split_lines};

/// Computes the diff between the lines of two strings.
pub fn lines(left: @ByteArray, right: @ByteArray) -> Array<DiffResult<@ByteArray>> {
    do_diff(split_lines(left).span(), split_lines(right).span(),)
}

/// Computes the diff between the chars of two strings.
pub fn chars(left: @ByteArray, right: @ByteArray) -> Array<DiffResult<u8>> {
    do_diff(split_chars(left).span(), split_chars(right).span(),)
}
