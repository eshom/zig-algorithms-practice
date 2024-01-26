const std = @import("std");

fn myNull() ?i32 {
    return null;
}

fn myError() error{NullValue}!i32 {
    return error.NullValue;
}

pub fn main() !void {
    const y = myError();
    const x = myNull() orelse error.NullValue;
    std.debug.print("My value: {d}\n", .{try x});
    _ = try y;
}
