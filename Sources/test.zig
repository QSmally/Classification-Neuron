
const std = @import("std");
const file = @import("file/file.zig");
const Point = @import("neuron/point.zig").Point;

const stdout = std.io
    .getStdOut()
    .writer();
pub const required_args = 2;

pub fn execute(allocator: std.mem.Allocator, args: [][]const u8) !void {
    // Mark: weights file
    const weights = try file.json([]f64, allocator, args[0]);
    defer allocator.free(weights);

    if (weights.len != 3)
        return std.debug.print("error: weights file must be an array of exactly 3 f64 values, got {}\n", .{ weights.len });

    // Mark: annotations file
    const points = try file.json([]Point, allocator, args[1]);
    defer allocator.free(points);
    std.debug.print("annotations file with {} points, start...\n", .{ points.len });

    // Mark: run through points
    for (points) |point| {
        const group = point.group_from(weights[0..3].*);
        const annotated_group = point.group orelse 255;
        const message = if (group == annotated_group) "CORRECT" else "FAULT";

        try stdout.print("Point({}, {}): calculated = {}, annotated = {} ({s})\n", .{
            point.x,
            point.y,
            group,
            annotated_group,
            message });
    }

    std.debug.print("exit: no errors\n", .{});
}
