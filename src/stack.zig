const std = @import("std");
const testing = std.testing;

fn Stack(comptime T: type) type {
    const Frame = struct {
        const Self = @This();
        item: T,
        next: ?*Self = null,
    };

    return struct {
        const Self = @This();

        head: ?*Frame = null,

        fn pop(self: *Self, alloc: std.mem.Allocator) ?T {
            if (self.head) |f| {
                const item = f.*.item;
                const prev_head = f;
                self.head = f.*.next;
                alloc.destroy(prev_head);
                return item;
            }
            return null;
        }

        fn push(self: *Self, alloc: std.mem.Allocator, item: T) !void {
            const frame = try alloc.create(Frame);
            frame.*.item = item;
            frame.*.next = self.head;
            self.head = frame;
        }
    };
}


fn printStack(alloc: std.mem.Allocator, s: anytype) void {
    while (s.head) |f| {
        std.debug.print("Item: {any}\n", .{f.item});
        _ = s.pop(alloc);
    }
}

test "Stack" {
    const IntStack = Stack(i64);

    var s = IntStack{};
    try s.push(testing.allocator, 1);
    try s.push(testing.allocator, 2);
    try s.push(testing.allocator, 3);

    try testing.expectEqual(3, s.pop(testing.allocator));
    try testing.expectEqual(2, s.pop(testing.allocator));
    try testing.expectEqual(1, s.pop(testing.allocator));
    try testing.expectError(error.EmptyStack,
                            s.pop(testing.allocator) orelse error.EmptyStack);

    const FloatStack = Stack(f64);

    var s2 = FloatStack{};
    const expected = [_]f64{-5.0, -3.5, 0.0, -0.0, 1.5, 3.0};
    const input = [_]f64{3.0, 1.5, -0.0, 0.0, -3.5, -5.0};

    for (input) |in| {
        try s2.push(testing.allocator, in);
        //printStack(testing.allocator, &s2);
    }

    for (expected) |e| {
        const a = s2.pop(testing.allocator) orelse error.EmptyStack;
        std.debug.print("Expected: {d:>6.3} Actual: {d:>6.3}\n", .{e, try a});
        try testing.expectApproxEqRel(e, try a, 0.001);
    }
}
