const std = @import("std");
const testing = std.testing;

const ImplTypes = enum {
    Int,
    Float,
};

fn findSmallest(comptime T: type, arr: []const T) usize {
    switch (@typeInfo(T)) {
        .Int, .Float => {
            var smallest: usize = 0;
            for (arr, 0..) |x, i| {
                smallest = if (x < arr[smallest]) i else smallest;
            }
            return smallest;
        },
        else => @compileError("expecting types 'Int', 'Float'"),
    }
}

fn selectionSort(allocator: std.mem.Allocator, comptime T: type, newArr: []T, arr: []const T) !void {
    // delegating comptime type assertion to findSmallest()
    var copy = try allocator.alloc(T, arr.len);
    defer(allocator.free(copy));
    std.mem.copyForwards(T, copy, arr);

    for (newArr[0..copy.len], 0..) |*x, i| {
        const copyS = copy[i..];
        const smallest = findSmallest(T, copyS);
        std.mem.swap(T, &copyS[0], &copyS[smallest]);
        x.* = copyS[0];
    }
}

test "selectionSort" {
    try testing.expectEqual(0, findSmallest(i64, &[_]i64{1,2,3}));
    try testing.expectEqual(1, findSmallest(i60, &[_]i60{8,3,5}));
    try testing.expectEqual(2, findSmallest(u13, &[_]u13{9,7,2}));
    try testing.expectEqual(2, findSmallest(f64, &[_]f64{9.56,1.32,-9.99}));
    //_ = findSmallest(ImplTypes, &[_]ImplTypes{.Int});
    const unsorted = [_]f64{0, -10.0, 60.87, 15.12, -40};
    var sorted: [5]f64 = undefined;
    try selectionSort(testing.allocator, f64, &sorted, &unsorted);
    for (&[_]f64{-40, -10.0, 0, 15.12, 60.87}, sorted) |e, a| {
        //std.debug.print("Expected: {d}, Actual: {d}\n", .{e, a});
        try testing.expectApproxEqRel(e, a, 0.001);
    }
}
