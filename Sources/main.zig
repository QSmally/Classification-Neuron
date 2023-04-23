
const std = @import("std");

const stdout_ = std.io
    .getStdOut()
    .writer();
var buffer = std.io.bufferedWriter(stdout_);
const stdout = buffer.writer();

pub fn main() !void {
    try stdout.print("Hello world!\n", .{});
    try buffer.flush();
}
