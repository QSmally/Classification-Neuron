
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
    else if (std.mem.eql(u8, command, "svg"))   { try command_svg(args[2..]); }
    else if (std.mem.eql(u8, command, "test"))  { try command_test(args[2..]); }
    else if (std.mem.eql(u8, command, "run"))   { try command_run(args[2..]); }
    else std.debug.print("error: {s}: command not found\n", .{ command });
}

fn command_help() !void {
    const message =
        \\Classification Neuron - split graphs into two sections by training weights from a dataset.
        \\
        \\Implements the linear regression algorithm.
        \\
        \\USAGE
        \\  classifier [command] [arguments...]
        \\  classifier [command] [arguments...] > [output file]
        \\
        \\COMMANDS
        \\  train <annotated points>            trains a model from an annotated points file, outputs the weights to stdout
        \\  svg <any points>                    from an (annotated) points file, converts it to an SVG format and outputs it to stdout
        \\  test <weights> <annotated points>   runs an annotated points file through a weights file to see training accuracy in stdout
        \\  run <weights> <points/>             runs a non-annotated directory of points files through a weights file and writes the results in <points>/<dataset>/*/
        \\
        \\EXAMPLES
        \\  $ # see rendered output of an annotation file
        \\  $ classifier svg /mnt/dataset_0/annotated.json > /mnt/dataset_0/annotated.svg
        \\  $
        \\  $ # train and test a dataset
        \\  $ classifier train /mnt/dataset_0/annotated.json > /mnt/dataset_0/weights.json
        \\  $ classifier test /mnt/dataset_0/weights.json /mnt/dataset_0/annotated.test.json
        \\  $
        \\  $ # run the model through the run/ directory of point files and render their input and output
        \\  $ # view the result in /mnt/run/dataset_0/*/
        \\  $ classifier run /mnt/dataset_0/weights.json /mnt/run/
    ;

    try stdout.print("{s}\n", .{ message });
}

fn command_train(args: [][]const u8) !void {
    if (args.len != 1)
        return std.debug.print("error: gave {} args whilst expecting 1: annotated points file\n", .{ args.len });

    // Mark: annotations file
    const dataset_string = try cwd.readFileAlloc(allocator, args[0], 4096);
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

fn command_svg(args: [][]const u8) !void {
    if (args.len != 1)
        return std.debug.print("error: gave {} args whilst expecting 1: points file\n", .{ args.len });

    // Mark: points file
    const points_string = try cwd.readFileAlloc(allocator, args[1], 4096);
    var points_parse_stream = std.json.TokenStream.init(points_string);
    const points = try std.json.parse([]Point, &points_parse_stream, .{ .allocator = allocator });

    allocator.free(points_string);
    defer allocator.free(points);

    // Mark: conversion
    // TODO: Output a file conversion to stdout
}

fn command_test(args: [][]const u8) !void {
    if (args.len != 2)
        return std.debug.print("error: gave {} args whilst expecting 2: weights model, annotated points\n", .{ args.len });

    // Mark: weights file
    const weights_string = try cwd.readFileAlloc(allocator, args[0], 1024);
    var weights_parse_stream = std.json.TokenStream.init(weights_string);
    const weights = try std.json.parse([]f64, &weights_parse_stream, .{ .allocator = allocator });

    if (weights.len != 3)
        return std.debug.print("error: weights file must be an array of exactly 3 f64 values, got {}\n", .{ weights.len });

    allocator.free(weights_string);
    defer allocator.free(weights);
    std.debug.print("parsed weights file\n", .{});

    // Mark: annotations file
    const dataset_string = try cwd.readFileAlloc(allocator, args[1], 4096);
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

fn command_run(args: [][]const u8) !void {
    if (args.len != 2)
        return std.debug.print("error: gave {} args whilst expecting 2: weights model, points directory\n", .{ args.len });
    // TODO: Directory walk and do svg output
}
