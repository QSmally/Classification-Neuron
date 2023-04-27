
const std = @import("std");

pub const required_args = 2;

pub fn execute(allocator: std.mem.Allocator, args: [][]const u8) !void {
    _ = allocator;
    _ = args;
}
