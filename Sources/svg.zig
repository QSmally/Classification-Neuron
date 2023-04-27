
const std = @import("std");
const Point = @import("neuron/point.zig").Point;

pub const required_args = 1;

pub fn execute(allocator: std.mem.Allocator, args: [][]const u8) !void {
    // Mark: points file
    const points_string = try std.fs
        .cwd()
        .readFileAlloc(allocator, args[1], 4096);
    var points_parse_stream = std.json.TokenStream.init(points_string);
    const points = try std.json.parse([]Point, &points_parse_stream, .{ .allocator = allocator });

    allocator.free(points_string);
    defer allocator.free(points);

    // Mark: conversion
    // TODO: Output a file conversion to stdout
}
