mod generate;
mod parse;

use cairo_lang_macro::{derive_macro, ProcMacroResult, TokenStream};
use generate::generate_pretty_format_impl;
use parse::parse_struct_info;

#[derive_macro]
pub fn pretty_format(token_stream: TokenStream) -> ProcMacroResult {
    let struct_info = parse_struct_info(token_stream);
    let res = generate_pretty_format_impl(&struct_info);
    ProcMacroResult::new(TokenStream::new(res))
}
