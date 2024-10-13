mod utils;

use core::fmt::{Formatter, Error};

pub trait PrettyFormat<T> {
    fn pretty_fmt(self: @T, ref f: Formatter, ident: @ByteArray) -> Result<(), Error>;
}

impl PrettyFormatByteArray of PrettyFormat<ByteArray> {
    fn pretty_fmt(self: @ByteArray, ref f: Formatter, ident: @ByteArray) -> Result<(), Error> {
        f.buffer.append(ident);
        if utils::is_readable_ascii(self) {
            f.buffer.append(self);
        } else {
            f.buffer.append(utils::to_hex(self))
        }
        Result::Ok(())
    }
}

