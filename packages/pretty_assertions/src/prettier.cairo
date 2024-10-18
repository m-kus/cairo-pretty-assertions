/// Pretty formats an element implementing Debug, roughly an analogue of "{:#?}" from Rust.
pub fn pretty_debug_fmt<T, +core::fmt::Debug<T>, +Drop<T>>(
    item: T, indent_size: usize, hex_string: bool
) -> ByteArray {
    let input = format!("{:?}", item);
    let input_len = input.len();
    let mut output = "";
    let mut indent_level = 0;
    let mut in_string = false; // Flag to track if we're inside a string literal
    let mut escape = false; // Flag to track if we're in an escape sequence
    let mut new_elt = false; // Flag to track if we are at the new element in a collection

    for i in 0
        ..input_len {
            let char = input[i];

            if escape {
                // If the previous character was a backslash, this character is part of an escape
                // sequence.
                output.append_byte(char);
                escape = false; // Reset escape flag
                continue;
            }

            if char == '\\' {
                // If we encounter a backslash, we might be entering an escape sequence.
                escape = true;
                output.append_byte(char); // Keep the backslash as part of the string
            } else if char == '"' {
                // Handle string literals (considering escape sequences)
                output.append_byte(char);
                in_string = !in_string; // Toggle in_string only if it's not an escaped quote
            } else if char == '{' || char == '[' || char == '(' {
                // Opening brace/bracket/parenthesis
                output.append_byte(char);
                if !in_string {
                    indent_level += 1;
                    new_elt = true;
                }
            } else if char == '}' || char == ']' || char == ')' {
                // Closing brace/bracket/parenthesis
                if !in_string {
                    if !new_elt && i != input_len - 3 {
                        // always add a comma after an element except for empty collection,
                        // or the very last element in the structure
                        output.append_byte(',');
                    }
                    new_elt = false; // handle empty collection case
                    output.append_byte('\n'); // Add newline
                    indent_level -= 1;
                    append_indent(ref output, indent_level * indent_size);
                }
                output.append_byte(char);
            } else if char == ',' {
                // Commas should introduce a new line, but only if not inside a string
                output.append_byte(char);
                if !in_string {
                    new_elt = true;
                }
            } else if char == ' ' {
                // Trim all leading spaces before new elements in an array/tuple/struct
                // Also trim trailing spaces for the last field in a struct
                if new_elt || input[i + 1] == '}' {
                    continue;
                }
                output.append_byte(char);
            } else if in_string {
                if hex_string {
                    append_byte_hex(ref output, char);
                } else {
                    output.append_byte(char);
                }
            } else {
                if new_elt {
                    output.append_byte('\n'); // Add newline
                    append_indent(ref output, indent_level * indent_size);
                    new_elt = false;
                }
                output.append_byte(char);
            }
        };

    output
}

fn append_indent(ref str: ByteArray, size: usize) {
    for _ in 0..size {
        str.append_byte(' ');
    }
}

fn append_byte_hex(ref str: ByteArray, byte: u8) {
    let alphabet: @ByteArray = @"0123456789abcdef";
    let value: u32 = byte.into();
    let (l, r) = core::traits::DivRem::div_rem(value, 16);
    str.append_byte(alphabet.at(l).unwrap());
    str.append_byte(alphabet.at(r).unwrap());
}
