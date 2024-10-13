mod types;
mod diff;
mod string;
mod demo;
mod printer;

pub use types::DiffResult;
pub use diff::do_diff;
pub use string::{split_chars, split_lines};
pub use printer::{write_header, write_lines, write_inline_diff};

/// Computes the diff between the lines of two strings.
pub fn lines(left: @ByteArray, right: @ByteArray) -> Array<DiffResult<@ByteArray>> {
    do_diff(split_lines(left).span(), split_lines(right).span(),)
}

/// Computes the diff between the chars of two strings.
pub fn chars(left: @ByteArray, right: @ByteArray) -> Array<DiffResult<u8>> {
    do_diff(split_chars(left).span(), split_chars(right).span(),)
}
