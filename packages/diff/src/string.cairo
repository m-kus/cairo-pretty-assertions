pub(crate) fn split_lines(text: @ByteArray) -> Array<@ByteArray> {
    let mut lines = ArrayTrait::new();
    let mut curr_line = "";
    let len = text.len();
    let mut i = 0;
    while i != len {
        let chr = text[i];
        if chr == '\n' {
            lines.append(@curr_line);
            curr_line = "";
        } else {
            curr_line.append_byte(chr)
        }
        i += 1;
    };
    if curr_line.len() != 0 {
        lines.append(@curr_line);
    }
    lines
}

pub(crate) fn split_chars(string: @ByteArray) -> Array<u8> {
    let mut chars = ArrayTrait::new();
    let len = string.len();
    let mut i = 0;
    while i != len {
        chars.append(string[i]);
        i += 1;
    };
    chars
}
