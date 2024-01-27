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

fn sum(comptime T: type, arr: []const T) T {
    if (arr.len == 0) return 0; // base case 1
    if (arr.len == 1) return arr[0]; // base case 2

    return arr[0] + sum(T, arr[1..]);
}

test "sum" {
    const case1 = [_]u64{1, 2, 3, 4, 5} ** 3;
    const case2 = [_]u64{};
    const case3 = [_]f64{1.5, 2.0, -2.0, -1.5};

    try testing.expectEqual(45, sum(u64, &case1));
    try testing.expectEqual(0, sum(u64, &case2));
    try testing.expectApproxEqRel(0, sum(f64, &case3), 0.001);
}

fn length(slice: anytype) usize {
    if (slice.len == 0) return 0;
    return length(slice[1..]) + 1;
}

test "length" {
    const case1 = [_]u8{'a'} ** 10;
    const case2 = "a" ** 10;

    std.debug.print("Case1: Expected length {d} Actual: {d}\n", .{case1.len, length(&case1)});
    try testing.expectEqual(10, length(&case1));
    std.debug.print("Case2: Expected length {d} Actual: {d}\n", .{case2.len, length(case2)});
}

fn max(comptime T: type, slice: []const T) !T {
    if (slice.len == 0) return error.EmptyArray;
    if (slice.len == 1) return slice[0];

    const next = try max(T, slice[1..]);
    return if (slice[0] > next) slice[0] else next;
}

test "max" {
    const case1 = "abcdefg";
    std.debug.print("Case1: Expected item 'g' and found '{!c}'\n", .{max(u8, case1)});
    try testing.expectEqual('g', try max(u8, case1));

    const case2 = [_]u64{0, 6, 4, 2, 81, 54, 32, 11, 99, 100, 88, 54, 0};
    std.debug.print("Case2: Expected item '100' and found '{!d}'\n", .{max(u64, &case2)});
    try testing.expectEqual(100, try max(u64, &case2));
}

fn binarySearch(comptime T: type, item: T, sorted: []const T) ?usize {
    if (sorted.len == 0)  return null; // Base case not found

    const mid = sorted.len / 2;
    if (sorted[mid] == item) return mid; // Base case found

    var left_section: ?usize = null;
    var right_section: ?usize = null;
    if (sorted[mid] > item) {
        left_section = binarySearch(T, item, sorted[0..mid]);
    } else {
        right_section = binarySearch(T, item, sorted[(mid+1)..]);
    }

    return left_section orelse right_section;
}

test "binarySearch" {
    const arr = try testing.allocator.alloc(i32, 100_000);
    defer testing.allocator.free(arr);

    for (arr, 0..) |*item, idx| {
        const casted: i32 = @intCast(idx);
        item.* = casted - 50_000;
    }

    const found_idx = binarySearch(i32, 0, arr) orelse error.NotFound;
    const not_found = binarySearch(i32, 50_001, arr) orelse error.NotFound;
    const found_slice = arr[(try found_idx - 5)..(try found_idx + 5)];
    std.debug.print("Found slice: {any}\nNot found: {!any}\n", .{found_slice, not_found});
    try testing.expectEqual(0, arr[try found_idx]);
    try testing.expectError(error.NotFound, not_found);
}
