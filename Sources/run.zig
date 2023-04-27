
const std = @import("std");
const svg = @import("svg.zig");
const file = @import("file/file.zig");
const Point = @import("neuron/point.zig").Point;
const Trainer = @import("neuron/trainer.zig").Trainer;

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

    // Mark: iterator and determine model name
    const run_dir = try std.fs
        .cwd()
        .openIterableDir(args[1], .{});
    var run_dir_walk = run_dir.iterate();

    const dataset_path_string = try std.fs
        .cwd()
        .realpathAlloc(allocator, args[0]);
    const dataset_name_string = std.fs.path.basename(std.fs.path.dirname(dataset_path_string).?);
    defer allocator.free(dataset_path_string);

    std.debug.print("running model '{s}'...\n", .{ dataset_name_string });
    var errors: u32 = 0;

    // Mark: run through points
    while (try run_dir_walk.next()) |entry| {
        if (entry.kind != .File or !std.mem.eql(u8, std.fs.path.extension(entry.name), ".json")) continue;

        try stdout.print("processing file '{s}'... ", .{ entry.name });
        var points = file.json_from([]Point, allocator, run_dir.dir, entry.name) catch {
            try stdout.print("error! (malformed, skipped)\n", .{});
            errors += 1;
            continue;
        };
        defer allocator.free(points);

        const output_path_string = try std.fmt.allocPrint(allocator, "{s}/{s}", .{ dataset_name_string, entry.name });
        var output_dir = try run_dir.dir.makeOpenPath(output_path_string, .{});
        allocator.free(output_path_string);

        // Mark: input SVG
        var input_svg_file = try output_dir.createFile("input.svg", .{ .read = true });
        try svg.generate(&points, input_svg_file.writer());
        input_svg_file.close();

        // Mark: output predictions SVG
        for (points) |*point|
            point.*.group = point.*.group_from(weights[0..3].*);
        var output_svg_file = try output_dir.createFile("prediction.svg", .{ .read = true });
        try svg.generate(&points, output_svg_file.writer());
        output_svg_file.close();

        // Mark: output predictions
        var output_predictions_file = try output_dir.createFile("prediction.json", .{ .read = true });
        try std.json.stringify(points, .{}, output_predictions_file.writer());
        output_predictions_file.close();


        try stdout.print("done!\n", .{});
        output_dir.close();
    }

    std.debug.print("exit: {} errors\n", .{ errors });
}
