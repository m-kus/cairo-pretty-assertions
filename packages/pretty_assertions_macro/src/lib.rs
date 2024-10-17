mod parse;

use cairo_lang_macro::{inline_macro, ProcMacroResult, TokenStream};
use itertools::Itertools;
use parse::parse_args;

#[inline_macro]
pub fn assert_eq(token_stream: TokenStream) -> ProcMacroResult {
    let args = parse_args(token_stream);
    assert!(
        args.len() >= 2,
        "assert_eq!() expects at least two arguments"
    );

    let ty = if args.iter().take(2).any(|arg| arg.starts_with("\"")) {
        "::<ByteArray>"
    } else if args.iter().take(2).any(|arg| arg.starts_with("@\"")) {
        "::<@ByteArray>"
    } else {
        ""
    };

    let message = if args.len() > 3 {
        format!("format!({}, {})", args[2], args.iter().skip(3).join(", "))
    } else if args.len() == 3 {
        args[2].clone()
    } else {
        format!("\"\"")
    };

    let res = format!(
        "pretty_assertions::assert_eq{ty}({}, {}, {message})",
        args[0], args[1]
    );
    ProcMacroResult::new(TokenStream::new(res))
}
