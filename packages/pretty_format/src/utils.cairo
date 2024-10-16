pub fn is_ascii_readable_string(string: @ByteArray) -> bool {
    let str_len = string.len();
    let mut res = true;
    for i in 0
        ..str_len {
            let char = string[i];
            if !is_ascii_readable_char(char) {
                res = false;
                break;
            }
        };
    res
}

pub fn is_ascii_readable_char(char: u8) -> bool {
    (char >= 32 && char <= 126) // Printable ASCII characters
        || char == 9 // Tab
        || char == 10 // Line feed (LF, \n)
        || char == 13 // Carriage return (CR, \r)
}

pub fn bytes_to_hex(data: @ByteArray) -> ByteArray {
    let alphabet: @ByteArray = @"0123456789abcdef";
    let mut result: ByteArray = Default::default();

    let mut i = 0;
    while i != data.len() {
        let value: u32 = data[i].into();
        let (l, r) = core::traits::DivRem::div_rem(value, 16);
        result.append_byte(alphabet.at(l).unwrap());
        result.append_byte(alphabet.at(r).unwrap());
        i += 1;
    };
    result
}
