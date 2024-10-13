mod parse;
mod generate;

use cairo_lang_macro::{ProcMacroResult, TokenStream, derive_macro};
use generate::generate_pretty_format_impl;
use parse::parse_struct_info;

#[derive_macro]
pub fn pretty_format(token_stream: TokenStream) -> ProcMacroResult {
    let struct_info = parse_struct_info(token_stream);
    ProcMacroResult::new(TokenStream::new(generate_pretty_format_impl(&struct_info)))
}
