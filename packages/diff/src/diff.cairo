use crate::types::{DiffResult, Vec2, Vec2Trait};
use core::fmt::Debug;

pub fn do_diff<T, +Copy<T>, +Drop<T>, +PartialEq<T>, +Debug<T>>(
    left: Span<T>, right: Span<T>
) -> Array<DiffResult<T>> {
    let mut diff = ArrayTrait::new();
    let mut l = left;
    let mut r = right;
    loop {
        if let Option::Some(lhs) = l.pop_front() {
            if let Option::Some(rhs) = r.pop_front() {
                if lhs == rhs {
                    diff.append(DiffResult::Both((*lhs, *rhs)));
                    continue;
                }
            }
        }
        break;
    };

    let mut footer = ArrayTrait::new();
    loop {
        if let Option::Some(lhs) = l.pop_back() {
            if let Option::Some(rhs) = r.pop_back() {
                if lhs == rhs {
                    footer.append(DiffResult::Both((*lhs, *rhs)));
                    continue;
                }
            }
        }
        break;
    };

    let start = diff.len();
    let llen = left.len() - start - footer.len();
    let rlen = right.len() - start - footer.len();
    do_naive_diff(left.slice(start, llen), right.slice(start, rlen), ref diff);

    let mut span = footer.span();
    while let Option::Some(elt) = span.pop_back() {
        diff.append(*elt);
    };

    diff
}

fn do_naive_diff<T, +Copy<T>, +Drop<T>, +PartialEq<T>, +Debug<T>>(
    left: Span<T>, right: Span<T>, ref diff: Array<DiffResult<T>>
) {
    let mut table: Vec2<u32> = Vec2Trait::new(0, left.len() + 1, right.len() + 1);
    let mut i = 0;
    let mut j = 0;

    for l in left {
        for r in right {
            let cell = if l == r {
                table.get(i, j) + 1
            } else {
                let a = table.get(i, j + 1);
                let b = table.get(i + 1, j);
                if a > b {
                    a
                } else {
                    b
                }
            };
            table.set(i + 1, j + 1, cell);
            j += 1;
        };
        i += 1;
        j = 0;
    };

    let mut res: Array<DiffResult<T>> = ArrayTrait::new();
    let mut i = table.len0 - 1;
    let mut j = table.len1 - 1;

    loop {
        if j != 0 && (i == 0 || table.get(i, j) == table.get(i, j - 1)) {
            j -= 1;
            res.append(DiffResult::Right(*right[j]));
        } else if i != 0 && (j == 0 || table.get(i, j) == table.get(i - 1, j)) {
            i -= 1;
            res.append(DiffResult::Left(*left[i]));
        } else if i != 0 && j != 0 {
            i -= 1;
            j -= 1;
            res.append(DiffResult::Both((*left[i], *right[j])));
        } else {
            break;
        }
    };

    let mut snap = res.span();
    while let Option::Some(elt) = snap.pop_back() {
        diff.append(*elt);
    }
}
