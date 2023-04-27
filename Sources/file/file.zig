
const std = @import("std");

pub fn json(comptime format: type, allocator: std.mem.Allocator, path: []const u8) !format {
    const string = try std.fs.
        cwd()
        .readFileAlloc(allocator, path, 4096);
    defer allocator.free(string);

    var parse_stream = std.json.TokenStream.init(string);
    const parsed_type = try std.json.parse(format, &parse_stream, .{ .allocator = allocator });
    return parsed_type;
}
