mod parse;

use cairo_lang_macro::{ProcMacroResult, TokenStream, inline_macro};
use parse::parse_args;

#[inline_macro]
pub fn assert_eq(token_stream: TokenStream) -> ProcMacroResult {
    let args = parse_args(token_stream);
    assert!(args.len() >= 2, "assert_eq!() expects at least two arguments");

    

    ProcMacroResult::new(TokenStream::new(String::new()))
}
