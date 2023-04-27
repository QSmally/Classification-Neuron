
const std = @import("std");
const file = @import("file/file.zig");
const Point = @import("neuron/point.zig").Point;

const stdout = std.io
    .getStdOut()
    .writer();
const width = 700;
const height = 700;
const radius = 10;
pub const required_args = 1;

pub fn execute(allocator: std.mem.Allocator, args: [][]const u8) !void {
    // Mark: points file
    const points = try file.json([]Point, allocator, args[0]);
    defer allocator.free(points);

    // Mark: conversion
    try generate(&points, stdout);
}

pub fn generate(points: *const []Point, output: std.fs.File.Writer) !void {
    try output.print("<svg xmlns=\"http://www.w3.org/2000/svg\" background-color=\"white\">\n", .{});
    try output.print("<rect width=\"{}\" height=\"{}\" fill=\"white\"></rect>\n", .{ width + 20, height + 20 });

    for (points.*) |point| {
        const x = @as(u32, point.x) * width / 255 + 10;
        const y = @as(u32, point.y) * height / 255 + 10;

        const colour = if (point.group) |group| switch (group) {
            0 => "red",
            1 => "green",
            else => "black",
        } else "black";

        try output.print("<g><circle class=\"circle\" cx=\"{}\" cy=\"{}\" r=\"{}\" fill=\"{s}\"></circle></g>\n", .{
            x,
            y,
            radius,
            colour });
    }

    try output.print("</svg>\n", .{});
}
