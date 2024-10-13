use core::dict::Felt252Dict;

/// A fragment of a computed diff.
#[derive(Drop, Copy, PartialEq)]
pub enum DiffResult<T> {
    /// An element that only exists in the left input.
    Left: T,
    /// Elements that exist in both inputs.
    Both: (T, T),
    /// An element that only exists in the right input.
    Right: T,
}

pub struct Vec2<T> {
    pub len0: usize,
    pub len1: usize,
    pub data: Felt252Dict<T>,
}

pub impl Vec2Destruct<T, +Drop<T>, +Felt252DictValue<T>> of Destruct<Vec2<T>> {
    fn destruct(self: Vec2<T>) nopanic {
        self.data.squash();
    }
}

#[generate_trait]
pub impl Vec2Impl<T, +Felt252DictValue<T>> of Vec2Trait<T> {
    fn new<+Copy<T>, +Drop<T>>(value: T, len0: usize, len1: usize) -> Vec2<T> {
        let mut data: Felt252Dict<T> = Default::default();
        let data_len = len0 * len1;
        for key in 0..data_len {
            data.insert(key.into(), value);
        };
        Vec2 { len0, len1, data, }
    }

    fn get<+Copy<T>, +Drop<T>>(ref self: Vec2<T>, i: usize, j: usize) -> T {
        assert!(i < self.len0);
        assert!(j < self.len1);
        let key = i * self.len1 + j;
        self.data.get(key.into())
    }

    fn set<+Drop<T>>(ref self: Vec2<T>, i: usize, j: usize, value: T) {
        assert!(i < self.len0);
        assert!(j < self.len1);
        let key = i * self.len1 + j;
        self.data.insert(key.into(), value);
    }
}
