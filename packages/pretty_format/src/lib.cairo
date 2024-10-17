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

// FIXME: implement for all signed integers, because AbsAndSign is not public

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

impl PrettyFormatTuple0 of PrettyFormat<()> {
    fn pretty_fmt(self: @(), ref f: Formatter, indent: @ByteArray) -> Result<(), Error> {
        write!(f, "{indent}()")
    }
}

impl PrettyFormatTuple1<E0, +PrettyFormat<E0>> of PrettyFormat<(E0,)> {
    fn pretty_fmt(self: @(E0,), ref f: Formatter, indent: @ByteArray) -> Result<(), Error> {
        let (a,) = self;
        let inner_indent = format!("{indent}  ");
        write!(f, "{indent}(\n")?;
        PrettyFormat::pretty_fmt(a, ref f, @inner_indent)?;
        write!(f, "{indent})")
    }
}

impl PrettyFormatTuple2<E0, E1, +PrettyFormat<E0>, +PrettyFormat<E1>> of PrettyFormat<(E0, E1)> {
    fn pretty_fmt(self: @(E0, E1), ref f: Formatter, indent: @ByteArray) -> Result<(), Error> {
        let (a, b) = self;
        let inner_indent = format!("{indent}  ");
        write!(f, "{indent}(\n")?;
        PrettyFormat::pretty_fmt(a, ref f, @inner_indent)?;
        write!(f, ",\n")?;
        PrettyFormat::pretty_fmt(b, ref f, @inner_indent)?;
        write!(f, ",\n")?;
        write!(f, "{indent})")
    }
}

impl PrettyFormatTuple3<
    E0, E1, E2, +PrettyFormat<E0>, +PrettyFormat<E1>, +PrettyFormat<E2>
> of PrettyFormat<(E0, E1, E2)> {
    fn pretty_fmt(self: @(E0, E1, E2), ref f: Formatter, indent: @ByteArray) -> Result<(), Error> {
        let (a, b, c) = self;
        let inner_indent = format!("{indent}  ");
        write!(f, "{indent}(\n")?;
        PrettyFormat::pretty_fmt(a, ref f, @inner_indent)?;
        write!(f, ",\n")?;
        PrettyFormat::pretty_fmt(b, ref f, @inner_indent)?;
        write!(f, ",\n")?;
        PrettyFormat::pretty_fmt(c, ref f, @inner_indent)?;
        write!(f, ",\n")?;
        write!(f, "{indent})")
    }
}

impl PrettyFormatTuple4<
    E0, E1, E2, E3, +PrettyFormat<E0>, +PrettyFormat<E1>, +PrettyFormat<E2>, +PrettyFormat<E3>
> of PrettyFormat<(E0, E1, E2, E3)> {
    fn pretty_fmt(
        self: @(E0, E1, E2, E3), ref f: Formatter, indent: @ByteArray
    ) -> Result<(), Error> {
        let (a, b, c, d) = self;
        let inner_indent = format!("{indent}  ");
        write!(f, "{indent}(\n")?;
        PrettyFormat::pretty_fmt(a, ref f, @inner_indent)?;
        write!(f, ",\n")?;
        PrettyFormat::pretty_fmt(b, ref f, @inner_indent)?;
        write!(f, ",\n")?;
        PrettyFormat::pretty_fmt(c, ref f, @inner_indent)?;
        write!(f, ",\n")?;
        PrettyFormat::pretty_fmt(d, ref f, @inner_indent)?;
        write!(f, ",\n")?;
        write!(f, "{indent})")
    }
}

impl PrettyFormatFixedSizedArray0<T, +PrettyFormat<T>> of PrettyFormat<[T; 0]> {
    fn pretty_fmt(self: @[T; 0], ref f: Formatter, indent: @ByteArray) -> Result<(), Error> {
        write!(f, "{indent}[]")
    }
}

// FIXME: span is only available for N > 0 but we cannot use use negative impls here
//
// impl PrettyFormatFixedSizedArrayN<T, const N: usize, +PrettyFormat<T>> of PrettyFormat<[T; N]> {
//     fn pretty_fmt(self: @[T; N], ref f: Formatter, indent: @ByteArray) -> Result<(), Error> {
//         PrettyFormat::pretty_fmt(@self.span(), ref f, indent)
//     }
// }

impl PrettyFormatArray<T, +PrettyFormat<T>> of PrettyFormat<Array<T>> {
    fn pretty_fmt(self: @Array<T>, ref f: Formatter, indent: @ByteArray) -> Result<(), Error> {
        PrettyFormat::pretty_fmt(@self.span(), ref f, indent)
    }
}

impl PrettyFormatSpan<T, +PrettyFormat<T>> of PrettyFormat<Span<T>> {
    fn pretty_fmt(self: @Span<T>, ref f: Formatter, indent: @ByteArray) -> Result<(), Error> {
        write!(f, "{indent}[\n")?;
        let mut inner_result = Result::Ok(());
        let inner_indent = format!("{indent}  ");
        for elt in *self {
            inner_result = PrettyFormat::pretty_fmt(elt, ref f, @inner_indent);
            if inner_result.is_err() {
                break;
            }
            inner_result = write!(f, ",\n");
            if inner_result.is_err() {
                break;
            }
        };
        inner_result?;
        write!(f, "{indent}]")
    }
}
