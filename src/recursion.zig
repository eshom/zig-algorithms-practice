const std = @import("std");
const testing = std.testing;

fn factorial(n: usize) u64 {
    if (n <= 1) {
        return 1;
    }
    return n * factorial(n - 1);
}

test "factorial" {
    try testing.expectEqual(6, factorial(3));
    try testing.expectEqual(24, factorial(4));
}
