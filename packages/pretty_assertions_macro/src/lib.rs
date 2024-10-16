mod parse;

use cairo_lang_macro::{inline_macro, ProcMacroResult, TokenStream};
use parse::parse_args;

#[inline_macro]
pub fn assert_eq(token_stream: TokenStream) -> ProcMacroResult {
    let args = parse_args(token_stream);
    assert!(
        args.len() >= 2,
        "assert_eq!() expects at least two arguments"
    );
    let res = format!(
        "pretty_assertions::assert_eq({}, {}, \"\")",
        args[0], args[1]
    );
    ProcMacroResult::new(TokenStream::new(res))
}
