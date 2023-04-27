
const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    const e = b.addExecutable("classifier", "Sources/main.zig");
    e.setTarget(b.standardTargetOptions(.{}));
    e.setBuildMode(b.standardReleaseOptions());
    e.install();

    const runc = e.run();
    runc.step.dependOn(b.getInstallStep());
    if (b.args) |args| runc.addArgs(args);

    const runs = b.step("run", "Execute the classifier CLI binary");
    runs.dependOn(&runc.step);

    const testc = b.addTest("Sources/neuron/trainer.zig");
    const tests = b.step("test", "Tests the trainer component");
    tests.dependOn(&testc.step);
}
