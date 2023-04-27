
const std = @import("std");
const file = @import("file/file.zig");
const Point = @import("neuron/point.zig").Point;
const Trainer = @import("neuron/trainer.zig").Trainer;

const stdout = std.io
    .getStdOut()
    .writer();
pub const required_args = 1;

pub fn execute(allocator: std.mem.Allocator, args: [][]const u8) !void {
    // Mark: annotations file
    const points = try file.json([]Point, allocator, args[0]);
    defer allocator.free(points);
    std.debug.print("annotations file with {} points\n", .{ points.len });

    // Mark: training
    var trainer = Trainer.init_random(4096);
    std.debug.print("trainer instance with max_iter={}, start...\n", .{ trainer.max_iterations });

    const iterations = trainer.train(points);
    if (iterations == trainer.max_iterations)
        std.debug.print("warning! iter=max_iter which likely means the dataset is invalid (couldn't perform linear regression)\n", .{});
    std.debug.print("done! training took {} iterations\n", .{ iterations });

    // Mark: output
    try std.json.stringify(trainer.weights, .{}, stdout);
    try stdout.print("\n", .{});
    std.debug.print("exit: no errors\n", .{});
}
