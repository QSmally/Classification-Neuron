
const std = @import("std");

pub fn json(comptime format: type, allocator: std.mem.Allocator, path: []const u8) !format {
    return json_from(format, allocator, std.fs.cwd(), path);
}

pub fn json_from(comptime format: type, allocator: std.mem.Allocator, path: std.fs.Dir, subpath: []const u8) !format {
    const string = try path.readFileAlloc(allocator, subpath, 4096);
    defer allocator.free(string);

    var parse_stream = std.json.TokenStream.init(string);
    const parsed_type = try std.json.parse(format, &parse_stream, .{ .allocator = allocator });
    return parsed_type;
}
