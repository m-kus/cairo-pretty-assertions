// SPDX-FileCopyrightText: Alexandria contributors https://github.com/keep-starknet-strange/alexandria
//
// SPDX-License-Identifier: MIT

use cairo_lang_macro::TokenStream;
use cairo_lang_parser::utils::SimpleParserDatabase;
use cairo_lang_syntax::node::kind::SyntaxKind;

pub(crate) fn parse_args(token_stream: TokenStream) -> Vec<String> {
    let db = SimpleParserDatabase::default();
    let (parsed, _diag) = db.parse_virtual_with_diagnostics(token_stream);

    parsed
        .descendants(&db)
        .filter_map(|node| {
            if SyntaxKind::Arg == node.kind(&db) {
                Some(node.get_text(&db))
            } else {
                None
            }
        })
        .collect()
}
