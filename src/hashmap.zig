const std = @import("std");
const t = std.testing;

fn SimpleMap(allocator: std.mem.Allocator, comptime T: type, comptime KT: type, capacity: usize) type {
    const Container = struct {
        key: ?KT = null,
        value: ?T = null,
        deleted: bool = false, // lazy deletion
    };

    return struct {
        const Self = @This();
        const load_threshold = 0.5;

        allocator: std.mem.Allocator,
        capacity: usize,
        values: []Container,
        count: usize = 0,
        seed: u64 = 0,

        fn init() !Self {
            const new = Self{
                .values = try allocator.alloc(Container, capacity),
                .allocator = allocator,
                .capacity = capacity,
            };

            @memset(new.values, Container{});

            return new;
        }

        fn deinit(self: *Self) void {
            self.allocator.free(self.values);
        }

        fn extend(self: *Self) !void {
            const new_cap = self.capacity * 2;
            const new = try self.allocator.alloc(Container, new_cap);
            @memset(new, Container{});
            std.mem.copyForwards(Container, new, self.values);
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

            // linear probbing
            for (self.values[index..]) |*v| {
                if (v.*.key == null) {
                    v.*.key = key;
                    v.*.value = value;
                    break;
                }
            } else {
                for (self.values[0..index]) |*v| {
                    if (v.*.key == null) {
                        v.*.key = key;
                        v.*.value = value;
                        break;
                    }
                } else {
                    return error.MapFull;
                }
            }

            self.count += 1;
        }

        fn take(self: *Self, key: anytype) !?T {
            const index: usize = self.hash(key);

            // The problem with this implementation is that it is always worst case
            // when key does not exist in the map, and it's a common case.
            // We know the index found when we put it, but we are not using this information.
            // We could also have a flag that tells if if linear search is required or not.
            for (self.values[index..]) |v| {
                if (v.key != null and std.mem.eql(u8, v.key.?, key)) { // TODO: need to fix this so type is not hardcoded to 'u8'
                    return v.value;
                }
            }
            for (self.values[0..index]) |v| {
                if (v.key != null and std.mem.eql(u8, v.key.?, key)) { // TODO: need to fix this so type is not hardcoded to 'u8'
                    return v.value;
                }
            } else {
                return error.NotFound;
            }
        }

        fn debugPrint(self: *Self) void {
            for (self.values) |contain| {
                std.debug.print("{?s:<10} <---> {?d:<7} del?: {any}\n", .{contain.key, contain.value, contain.deleted});
            }
        }
    };
}

test "SimpleMap" {
    const IntMap = SimpleMap(t.allocator, i32,[]const u8, 10);

    var table = try IntMap.init();
    defer table.deinit();

    std.debug.print("Capacity: {d}, Count: {d}\n", .{table.capacity, table.count});
    table.debugPrint();

    const keys = [_][]const u8{"apple", "banana", "orange", "pineapple", "melon", "watermelon",
                               "snake", "bob", "tim", "zig"};
    const values = [_]?i32{1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
    var retrieve: [10]?i32 = undefined;

    for (keys, values) |k, v| {
        try table.put(k, v.?);
    }

    std.debug.print("Capacity: {d}, Count: {d}\n", .{table.capacity, table.count});
    table.debugPrint();

    for (keys, &retrieve) |k, *r| {
        r.* = try table.take(k);
    }

    t.expectEqualDeep( values, retrieve) catch |e| {
        std.debug.print("{!}, values have been clobbered!\n", .{e});
        std.debug.print("Expected: {?any}\n", .{values});
        std.debug.print("Actual  : {?any}\n", .{retrieve});
        return e;
    };
}
