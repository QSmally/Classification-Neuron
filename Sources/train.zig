
const std = @import("std");
const Trainer = @import("neuron/trainer.zig").Trainer;
const Point = @import("neuron/point.zig").Point;

const stdout = std.io
    .getStdOut()
    .writer();
pub const required_args = 1;

pub fn execute(allocator: std.mem.Allocator, args: [][]const u8) !void {
    // Mark: annotations file
    const dataset_string = try std.fs.
        cwd()
        .readFileAlloc(allocator, args[0], 4096);
    var dataset_parse_stream = std.json.TokenStream.init(dataset_string);
    const points = try std.json.parse([]Point, &dataset_parse_stream, .{ .allocator = allocator });

    allocator.free(dataset_string);
    defer allocator.free(points);
    std.debug.print("parsed annotation file with {} points\n", .{ points.len });

    // Mark: training
    var trainer = Trainer.init_random(4096);
    std.debug.print("init trainer instance with max_iter={}, start...\n", .{ trainer.max_iterations });

    const iterations = trainer.train(points);
    if (iterations == trainer.max_iterations)
        std.debug.print("warning! iter=max_iter which likely means the dataset is invalid (couldn't perform linear regression)\n", .{});
    std.debug.print("done! training took {} iterations (writing weights to stdout...)\n", .{ iterations });

    try std.json.stringify(trainer.weights, .{}, stdout);
    std.debug.print("\nexit: no errors\n", .{});
}
