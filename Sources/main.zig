
const std = @import("std");
const Trainer = @import("trainer.zig").Trainer;
const Point = @import("point.zig").Point;

const stdout = std.io
    .getStdOut()
    .writer();
const cwd = std.fs.cwd();

var configuration = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = configuration.allocator();

pub fn main() !void {
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);
    if (args.len < 2) return try command_help();

    const command = args[1];

    if (std.mem.eql(u8, command, "help"))       { try command_help(); }
    else if (std.mem.eql(u8, command, "train")) { try command_train(args[2..]); }
    else if (std.mem.eql(u8, command, "test"))  { try command_test(args[2..]); }
    else if (std.mem.eql(u8, command, "run"))   { try command_run(args[2..]); }
    else std.debug.print("error: {s}: command not found\n", .{ command });
}

fn command_help() !void {
    const message =
        \\Classification Neuron - split graphs into two sections by training weights from a dataset.
        \\
        \\USAGE
        \\  classifier [command] [arguments...]
        \\  classifier [command] [arguments...] > [output file]
        \\
        \\COMMANDS
        \\  classifier train [dataset] > [output weights]   trains from an annotated file of points, outputs weights (to store with I/O redirection)
        \\  classifier test [dataset] [weights]             runs an annotated dataset through a weights file to see training accuracy in stdout
        \\  classifier run [points] [weights]               runs a non-annotated (directory of) set(s) through a weights file and writes the results
    ;

    try stdout.print("{s}\n", .{ message });
}

fn command_train(args: [][]const u8) !void {
    if (args.len != 1)
        return std.debug.print("error: gave {} args whilst expecting 1: path to annotated dataset\n", .{ args.len });

    // Mark: annotations file
    const dataset_string = try cwd.readFileAlloc(allocator, args[0], 4096);
    var dataset_parse_stream = std.json.TokenStream.init(dataset_string);
    const points = try std.json.parse([]Point, &dataset_parse_stream, .{ .allocator = allocator });

    allocator.free(dataset_string);
    defer allocator.free(points);
    std.debug.print("parsed annotation file with {} points\n", .{ points.len });

    // Mark: training
    var trainer = Trainer.init_random(4096);
    std.debug.print("init trainer instance with max_iter={}, start... ", .{ trainer.max_iterations });

    const iterations = trainer.train(points);
    std.debug.print("done\ntraining took {} iterations (writing weights to stdout...)\n", .{ iterations });
    try std.json.stringify(trainer.weights, .{}, stdout);
    std.debug.print("\nexit: success\n", .{});
}

fn command_test(args: [][]const u8) !void {
    if (args.len != 2)
        return std.debug.print("error: gave {} args whilst expecting 2: path to annotated dataset, path to weights file\n", .{ args.len });

    // Mark: annotations file
    const dataset_string = try cwd.readFileAlloc(allocator, args[0], 4096);
    var dataset_parse_stream = std.json.TokenStream.init(dataset_string);
    const points = try std.json.parse([]Point, &dataset_parse_stream, .{ .allocator = allocator });

    allocator.free(dataset_string);
    defer allocator.free(points);
    std.debug.print("parsed annotation file with {} points\n", .{ points.len });

    // Mark: weights file
    const weights_string = try cwd.readFileAlloc(allocator, args[1], 1024);
    var weights_parse_stream = std.json.TokenStream.init(weights_string);
    const weights = try std.json.parse([]f64, &weights_parse_stream, .{ .allocator = allocator });

    if (weights.len != 3)
        return std.debug.print("error: weights file must be an array of exactly 3 f64 values, got {}\n", .{ weights.len });

    allocator.free(weights_string);
    defer allocator.free(weights);
    std.debug.print("parsed weights file\nvalidating each point with its annotated group...\n", .{});

    // Mark: run through points
    for (points) |point| {
        const group = point.group_from(weights[0..3].*);
        const annotated_group = point.group orelse 255;
        const message = if (group == annotated_group) "CORRECT" else "FAULT";

        try stdout.print("Point({}, {}) = {}, annotated {} ({s})\n", .{
            point.x,
            point.y,
            group,
            annotated_group,
            message });
    }

    std.debug.print("\nexit: done\n", .{});
}

fn command_run(args: [][]const u8) !void {
    if (args.len != 2)
        return std.debug.print("error: gave {} args whilst expecting 2: path to points file or directory, path to weights file\n", .{ args.len });
    // TODO: Make svg output
}
