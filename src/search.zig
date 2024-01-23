const std = @import("std");
const testing = std.testing;
const math = std.math;

fn binarySearch(sorted: []const i64, what: i64) ?usize {
    var low: usize = 0;
    var high: usize = sorted.len - 1;

    while (low <= high) {
        const mid: usize = low + (high - low) / 2;
        const guess: i64 = sorted[mid];

        switch (math.order(guess, what)) {
            .eq => return mid,
            .gt => high = mid - 1,
            .lt => low = mid + 1,
        }
    }

    return null;
}

test "binarySearch" {
    const sorted_int_arr = [_]i64{-5, -1, 0, 7, 20, 50, 100, 160, 190, 200};

    const found = binarySearch(sorted_int_arr[0..], 190);
    testing.expectEqual(8, found.?) catch {};

    const not_found = binarySearch(sorted_int_arr[0..], 260);
    testing.expect(not_found == null) catch {
        std.debug.print("expected null, found some integer\n", .{});
    };

    const t = struct {
        fn order(context: void, lhs: i64, rhs: i64) math.Order {
            _ = context;
            return math.order(lhs, rhs);
        }
    };

    for (sorted_int_arr, 0..) |num, i| {
        testing.expectEqual(i, binarySearch(sorted_int_arr[0..], num).?) catch {};
        testing.expectEqual(std.sort.binarySearch(i64,
                                                  num,
                                                  sorted_int_arr[0..],
                                                  {},
                                                  t.order).?,
                            binarySearch(sorted_int_arr[0..], num).?) catch {};
    }
}
