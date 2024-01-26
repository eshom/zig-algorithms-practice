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

fn bubbleSort(comptime T: type, arr: []T) void {
    var i: usize = 1;
    while (i < arr.len) : (i += 1) {
        var j: usize = 0;
        while (j < arr.len - i) : (j += 1) {
            const left = &arr[j];
            const right = &arr[j+1];
            if (left.* > right.*) std.mem.swap(T, left, right);
        }
    }
}

test "bubbleSort" {
    var case1 = [_]u32{7, 6, 5, 4, 3, 2, 1, 0};
    var case2 = [_]f32{6.3, -1.0, -5.43, 10.4};

    bubbleSort(@TypeOf(case1[0]), &case1);
    bubbleSort(@TypeOf(case2[0]), &case2);

    try testing.expectEqual([_]u32{0, 1, 2, 3, 4, 5, 6, 7}, case1);
    for ([_]f32{-5.43, -1.0, 6.3, 10.4}, case2) |e, a| {
        try testing.expectApproxEqRel(e, a, 0.001);
    }
}
