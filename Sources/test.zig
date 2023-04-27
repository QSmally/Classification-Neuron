
const std = @import("std");
const Point = @import("neuron/point.zig").Point;

const stdout = std.io
    .getStdOut()
    .writer();
pub const required_args = 2;

pub fn execute(allocator: std.mem.Allocator, args: [][]const u8) !void {
    // Mark: weights file
    const weights_string = try std.fs
        .cwd()
        .readFileAlloc(allocator, args[0], 1024);
    var weights_parse_stream = std.json.TokenStream.init(weights_string);
    const weights = try std.json.parse([]f64, &weights_parse_stream, .{ .allocator = allocator });

    if (weights.len != 3)
        return std.debug.print("error: weights file must be an array of exactly 3 f64 values, got {}\n", .{ weights.len });

    allocator.free(weights_string);
    defer allocator.free(weights);
    std.debug.print("parsed weights file\n", .{});

    // Mark: annotations file
    const dataset_string = try std.fs
        .cwd()
        .readFileAlloc(allocator, args[1], 4096);
    var dataset_parse_stream = std.json.TokenStream.init(dataset_string);
    const points = try std.json.parse([]Point, &dataset_parse_stream, .{ .allocator = allocator });

    allocator.free(dataset_string);
    defer allocator.free(points);
    std.debug.print("parsed annotations file with {} points\n", .{ points.len });
    std.debug.print("validating each point with its annotated group (255 means no annotation)...\n", .{});

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

    std.debug.print("\nexit: no errors\n", .{});
}
