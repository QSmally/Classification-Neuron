
const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    const e = b.addExecutable("classifier", "Sources/main.zig");
    e.setTarget(b.standardTargetOptions(.{}));
    e.setBuildMode(b.standardReleaseOptions());
    e.install();
}
