// SPDX-FileCopyrightText: Alexandria contributors https://github.com/keep-starknet-strange/alexandria
//
// SPDX-License-Identifier: MIT

use crate::parse::StructInfo;

pub(crate) fn generate_pretty_format_impl(struct_info: &StructInfo) -> String {
    let generic_params = struct_info
        .generic_params
        .as_ref()
        .map_or(String::new(), |params| format!("<{}>", params.join(", ")));

    let trait_bounds = struct_info
        .generic_params
        .as_ref()
        .map_or_else(String::new, |params| {
            let bounds = params
                .iter()
                .flat_map(|param| {
                    vec![
                        format!("+pretty_print::PrettyFormat<{}>", param),
                    ]
                })
                .collect::<Vec<_>>()
                .join(",\n");
            format!("<{},\n{}>", params.join(", "), bounds)
        });

    let pretty_print_fn = struct_info
        .members
        .iter()
        .map(|member| format!("f.buffer.append(format!(\"\\n{{}}{{}},\", ident, {}.pretty_print(f, inner_ident)));", member))
        .collect::<Vec<_>>()
        .join("\n");

    format!(
        "\n
impl {0}PrettyFormatImpl{1}
of pretty_print::PrettyFormat<{0}{2}> {{
    fn pretty_format(self: @{0}{2}, ref f: core::fmt::Formatter, ident: @ByteArray) {{
        let inner_ident = format!(\"{{}}  \", ident);
        f.buffer.append(format!(\"{{}}{0} {{{{\", ident));
        {3}
        f.buffer.append(format!(\"\\n{{}}}}}}\", ident));
    }}
}}\n",
    struct_info.name, trait_bounds, generic_params, pretty_print_fn
    )
}
