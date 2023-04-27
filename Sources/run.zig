
const std = @import("std");
const file = @import("file/file.zig");

pub const required_args = 2;

pub fn execute(allocator: std.mem.Allocator, args: [][]const u8) !void {
    // Mark: weights file
    const weights = try file.json([]f64, allocator, args[0]);
    defer allocator.free(weights);

    if (weights.len != 3)
        return std.debug.print("error: weights file must be an array of exactly 3 f64 values, got {}\n", .{ weights.len });

    // Mark: run through points
    // TODO: This
}
