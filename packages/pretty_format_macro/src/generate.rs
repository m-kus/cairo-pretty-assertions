// SPDX-FileCopyrightText: Alexandria contributors https://github.com/keep-starknet-strange/alexandria
//
// SPDX-License-indentifier: MIT

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
                .flat_map(|param| vec![format!("+PrettyFormat<{}>", param)])
                .collect::<Vec<_>>()
                .join(",\n");
            format!("<{},\n{}>", params.join(", "), bounds)
        });

    let pretty_print_fn = struct_info
        .members
        .iter()
        .map(|member| format!(
            "\twrite!(f, \"\\n{{}}\", indent)?;\n\tPrettyFormat::pretty_fmt(self.{member}, ref f, @inner_indent)?;\n\twrite!(f, \",\")?;"
        ))
        .collect::<Vec<_>>()
        .join("\n");

    format!(
        "\n
impl {0}PrettyFormat{1} of PrettyFormat<{0}{2}> {{
    fn pretty_fmt(self: @{0}{2}, ref f: core::fmt::Formatter, indent: @ByteArray) -> Result<(), core::fmt::Error> {{
        let inner_indent = format!(\"{{}}{{}}\", indent, indent);
        write!(f, \"{{}}{0} {{{{\", indent)?;
        {3}
        write!(f, \"\\n{{}}}}}}\", indent)
    }}
}}\n",
    struct_info.name, trait_bounds, generic_params, pretty_print_fn
    )
}
