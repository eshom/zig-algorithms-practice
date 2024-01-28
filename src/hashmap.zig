const std = @import("std");
const t = std.testing;

fn SimpleMap(allocator: std.mem.Allocator, comptime T: type, capacity: usize) type {
    return struct {
        const Self = @This();
        const load_threshold = 0.5;

        allocator: std.mem.Allocator,
        capacity: usize,
        values: []T,
        count: usize = 0,
        seed: u64 = 0,

        fn init() !Self {
            const new = Self{
                .values = try allocator.alloc(T, capacity),
                .allocator = allocator,
                .capacity = capacity,
            };

            @memset(new.values, 0);

            return new;
        }

        fn deinit(self: *Self) void {
            self.allocator.free(self.values);
        }

        fn extend(self: *Self) !void {
            const new_cap = self.capacity * 2;
            const new = try self.allocator.alloc(T, new_cap);
            @memset(new, 0);
            std.mem.copyForwards(T, new, self.values);
            self.allocator.free(self.values);
            self.values = new;
            self.capacity = new_cap;
        }

        fn hash(self: *Self, key: anytype) u64 {
            return std.hash.XxHash3.hash(self.seed, key) % self.capacity;
        }

        fn put(self: *Self, key: anytype, value: T) !void {
            const cnt: f64 = @floatFromInt(self.count);
            const cap: f64 = @floatFromInt(self.capacity);
            const load: f64 = cnt / cap;

            if (load > load_threshold) {
                try self.extend();
            }

            const index: usize = self.hash(key);
            self.values[index] = value;
            self.count += 1;
        }

        fn take(self: *Self, key: anytype) T {
            const index: usize = self.hash(key);
            return self.values[index];
        }
    };
}

test "SimpleMap" {
    const IntMap = SimpleMap(t.allocator, i32, 10);

    var table = try IntMap.init();
    defer table.deinit();
    std.debug.print("Capacity: {d}\n", .{table.capacity});
    std.debug.print("Values: {any}\n", .{table.values});

    const keys = [_][]const u8{"apple", "banana", "orange", "pineapple", "melon", "watermelon",
                               "snake", "bob", "tim", "zig"};
    const values = [_]i32{1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
    var retrieve = [_]i32{0} ** 10;

    for (keys, values) |k, v| {
        try table.put(k, v);
    }

    std.debug.print("Capacity: {d}\n", .{table.capacity});
    std.debug.print("Values: {any}\n", .{table.values});

    for (keys, &retrieve) |k, *r| {
        r.* = table.take(k);
    }

    try t.expectEqualSlices(i32, &values, &retrieve);
}
