
const std = @import("std");
const file = @import("file/file.zig");
const Point = @import("neuron/point.zig").Point;

const stdout = std.io
    .getStdOut()
    .writer();
const width = 700;
const height = 700;
pub const required_args = 1;

pub fn execute(allocator: std.mem.Allocator, args: [][]const u8) !void {
    // Mark: points file
    const points = try file.json([]Point, allocator, args[0]);
    defer allocator.free(points);

    // Mark: conversion
    try stdout.print("<svg xmlns=\"http://www.w3.org/2000/svg\" background-color=\"white\">\n", .{});
    try stdout.print("<rect width=\"{}\" height=\"{}\" fill=\"white\"></rect>\n", .{ width + 20, height + 20 });

    for (points) |point| {
        const x = @as(u32, point.x) * width / 255 + 10;
        const y = @as(u32, point.y) * height / 255 + 10;

        const colour = if (point.group) |group| switch (group) {
            0 => "red",
            1 => "green",
            else => "black",
        } else "black";

        try stdout.print("<g><circle class=\"circle\" cx=\"{}\" cy=\"{}\" r=\"5\" fill=\"{s}\"></circle></g>\n", .{
            x,
            y,
            colour });
    }

    try stdout.print("</svg>\n", .{});
}
