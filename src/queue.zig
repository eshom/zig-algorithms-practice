const std = @import("std");
const t = std.testing;

pub fn Queue(comptime T: type, capacity: usize) type {
    return struct {
        const Self = @This();

        front: usize,
        back: usize,
        q: []T,
        size: usize,
        capacity: usize,
        allocator: std.mem.Allocator,

        pub fn init(allocator: std.mem.Allocator) !Self {
            const new = Self{
                .front = 0,
                .back = capacity - 1,
                .size = 0,
                .capacity = capacity,
                .q = try allocator.alloc(T, capacity),
                .allocator = allocator,
            };

            @memset(new.q, "");

            return new;
        }

        pub fn deinit(self: *Self) void {
            self.allocator.free(self.q);
        }

        pub fn enqueue(self: *Self, value: T) !void {
            if (self.size == self.capacity) return error.QueueFull;

            self.back = (self.back + 1) % self.capacity;
            self.size += 1;
            self.q[self.back] = value;
        }

        pub fn dequeue(self: *Self) !T {
            if (self.size == 0) return error.QueueEmpty;

            defer self.front = (self.front + 1) % self.capacity;
            self.size -= 1;
            return self.q[self.front];
        }
    };
}

test "queue" {
    var que = try Queue([]const u8, 5  ).init(t.allocator);
    defer que.deinit();

    std.debug.print("{s:<10} front: {d} back: {d}\n", .{que.q, que.front, que.back});

    const case1 = [_][]const u8{"one", "two", "three", "four", "five"};

    for (case1) |item| {
        try que.enqueue(item);
        std.debug.print("{s:<10} front: {d} back: {d}\n", .{que.q, que.front, que.back});
    }

    std.debug.print("{s:<10} front: {d} back: {d}\n", .{que.q, que.front, que.back});

    try t.expectEqual(5, que.size);
    try t.expectError(error.QueueFull, que.enqueue("full"));

    for (case1) |item| {
        try t.expectEqualStrings(item, try que.dequeue());
    }

    try t.expectEqual(0, que.size);
    try t.expectError(error.QueueEmpty, que.dequeue());
}
