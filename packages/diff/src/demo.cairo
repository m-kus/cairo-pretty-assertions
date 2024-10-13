use crate::printer::{write_header, write_lines};
use core::fmt::Formatter;

fn main() {
    let left =
        @"\n    use super::{\n        compute_block_reward, validate_coinbase, validate_coinbase_input,\n        validate_coinbase_sig_script, validate_coinbase_witness, validate_coinbase_outputs,\n        calculate_wtxid_commitment, is_bip30_unspendable\n    };\n";
    let right =
        @"\n    use super::{\n        compute_block_reward, validate_coinbase, validate_coinbase_input,\n        validate_coinbase_sig_script, validate_coinbase_witness, validate_coinbase_outputs,\n        calculate_wtxid_commitment, is_coinbase_txid_duplicated, FIRST_DUP_TXID, SECOND_DUP_TXID,\n    };\n";

    let mut f: Formatter = Default::default();
    write_header(ref f).unwrap();
    write_lines(ref f, left, right).unwrap();

    print!("{}", f.buffer);
}
