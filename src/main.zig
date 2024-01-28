const std = @import("std");

pub fn main() !void {
    const Hash = std.hash.XxHash3;
    std.debug.print("{any}\n", .{Hash.hash(0, "a") % 10});
    std.debug.print("{any}\n", .{Hash.hash(0, "a") % 10});
    std.debug.print("{any}\n", .{Hash.hash(0, "b") % 10});
}
