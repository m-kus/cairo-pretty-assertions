#[derive(Drop, Copy, PartialEq, Debug)]
struct Account {
    owner: @ByteArray,
    balance: u64,
    flags: (u8, u8),
    last_visits: Span<u32>,
    deposits: Span<Deposit>,
}

#[derive(Drop, Copy, PartialEq, Debug)]
struct Deposit {
    id: u64,
    amount: u64,
    time: u32,
    memo: @ByteArray,
}

fn main() {
    assert_eq!("hello", "hello");
    assert_eq!(@"hi", @"hi", "yeah");

    let lhs = Account {
        owner: @"Mr Snark",
        balance: 100500,
        flags: (42, 67),
        last_visits: array![
            1729106358,
            1729248570,
            1729033710,
            1729132601
        ].span(),
        deposits: array![
            Deposit {
                id: 0,
                amount: 4200,
                time: 1729033710,
                memo: @"First!"
            },
            Deposit {
                id: 1,
                amount: 8200,
                time: 1729033710,
                memo: @"Second"
            },
        ].span()
    };

    let rhs = Account {
        owner: @"Mr Stark",
        balance: 100500,
        flags: (32, 50),
        last_visits: array![
            1729132601
        ].span(),
        deposits: array![
            Deposit {
                id: 0,
                amount: 10000,
                time: 1729132601,
                memo: @"First!"
            },
        ].span()
    };

    assert_eq!(lhs, rhs, "Something is {}", 0xdead);
}

#[cfg(test)]
mod tests {
    #[test]
    fn test() {
        assert_eq!(0, 1);
    }
}
