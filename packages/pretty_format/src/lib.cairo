mod utils;

use core::fmt::{Formatter, Error};

pub trait PrettyFormat<T> {
    fn pretty_fmt(self: @T, ref f: Formatter, indent: @ByteArray) -> Result<(), Error>;

    fn to_string(
        self: @T, indent: @ByteArray
    ) -> Result<
        ByteArray, Error
    > {
        let mut f: Formatter = Default::default();
        Self::pretty_fmt(self, ref f, indent)?;
        Result::Ok(f.buffer)
    }
}

impl PrettyFormatByteArray of PrettyFormat<ByteArray> {
    fn pretty_fmt(self: @ByteArray, ref f: Formatter, indent: @ByteArray) -> Result<(), Error> {
        f.buffer.append(indent);
        if utils::is_ascii_readable_string(self) {
            f.buffer.append(self);
        } else {
            f.buffer.append(@utils::bytes_to_hex(self))
        }
        Result::Ok(())
    }
}

impl PrettyFormatInteger<
    T, +core::to_byte_array::AppendFormattedToByteArray<T>, +Into<u8, T>, +TryInto<T, NonZero<T>>
> of PrettyFormat<T> {
    fn pretty_fmt(self: @T, ref f: Formatter, indent: @ByteArray) -> Result<(), Error> {
        f.buffer.append(indent);
        let base: T = 10_u8.into();
        self.append_formatted_to_byte_array(ref f.buffer, base.try_into().unwrap());
        Result::Ok(())
    }
}

// TODO: implement for all signed integers

impl PrettyFormatNonZero<T, +PrettyFormat<T>, +Copy<T>, +Drop<T>> of PrettyFormat<NonZero<T>> {
    fn pretty_fmt(self: @NonZero<T>, ref f: Formatter, indent: @ByteArray) -> Result<(), Error> {
        let value: T = (*self).into();
        PrettyFormat::pretty_fmt(@value, ref f, indent)
    }
}

impl PrettyFormatBool of PrettyFormat<bool> {
    fn pretty_fmt(self: @bool, ref f: Formatter, indent: @ByteArray) -> Result<(), Error> {
        f.buffer.append(indent);
        if *self {
            write!(f, "true")
        } else {
            write!(f, "false")
        }
    }
}

impl PrettyFormatSnapshot<T, +PrettyFormat<T>> of PrettyFormat<@T> {
    fn pretty_fmt(self: @@T, ref f: Formatter, indent: @ByteArray) -> Result<(), Error> {
        PrettyFormat::pretty_fmt(*self, ref f, indent)
    }
}
