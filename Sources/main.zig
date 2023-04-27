
const std = @import("std");
const ctrain = @import("train.zig");
const csvg = @import("svg.zig");
const ctest = @import("test.zig");
const crun = @import("run.zig");

const stdout = std.io
    .getStdOut()
    .writer();
var configuration = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = configuration.allocator();

pub fn main() !void {
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);
    if (args.len < 2) return try help();

    const command = args[1];
    const rest = args[2..];

    if (std.mem.eql(u8, command, "help"))       { try help(); }
    else if (std.mem.eql(u8, command, "train")) { try execute(ctrain, rest); }
    else if (std.mem.eql(u8, command, "svg"))   { try execute(csvg, rest); }
    else if (std.mem.eql(u8, command, "test"))  { try execute(ctest, rest); }
    else if (std.mem.eql(u8, command, "run"))   { try execute(crun, rest); }
    else std.debug.print("error: {s}: command not found\n", .{ command });
}

fn help() !void {
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

fn execute(command: anytype, args: [][]const u8) !void {
    if (args.len != command.required_args)
        return std.debug.print("error: gave {} args whilst expecting {}\n", .{ args.len, command.required_args });
    try command.execute(allocator, args);
}
