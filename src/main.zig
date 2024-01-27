const std = @import("std");

pub fn main() !void {
    const arr = [_]u64{1,2,3,4,5,6};
    const slice = arr[0..];
    const pointer: [*]const u64 = &arr;
    std.debug.print("{any}\n", .{@typeInfo(@TypeOf(slice))});
    std.debug.print("{any}\n", .{@typeInfo(@typeInfo(@TypeOf(slice)).Pointer.child)});
    std.debug.print("\n{any}\n", .{@typeInfo(@TypeOf(pointer))});
}
