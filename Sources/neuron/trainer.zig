
const std = @import("std");
const Point = @import("point.zig").Point;

var gen = std.rand.DefaultPrng.init(69420);

pub const Trainer = struct {

    max_iterations: u32,
    weights: [3]f64,

    pub fn init_random(max_iter: u32) Trainer {
        const weights: [3]f64 = .{
            gen.random().float(f64),
            gen.random().float(f64),
            gen.random().float(f64) };
        return Trainer.init(max_iter, weights);
    }

    pub fn init(max_iter: u32, weights: [3]f64) Trainer {
        return .{
            .max_iterations = max_iter,
            .weights = weights };
    }

    pub fn train(self: *Trainer, points: []const Point) u32 {
        var convergence = false;
        var iterations: u32 = 0;

        while (!convergence and iterations < self.max_iterations) {
            const index = gen
                .random()
                .uintLessThan(usize, points.len);
            const point = points[index];

            self.mutate_offset_from(point);
            iterations += 1;
            convergence = true;

            for (points) |list_point| {
                if (list_point.group_from(self.weights) != list_point.group)
                    convergence = false;
            }
        }

        return iterations;
    }

    pub fn mutate_offset_from(self: *Trainer, point: Point) void {
        if (point.group) |group| {
            const set = point.set();
            const prediction = point.prediction(self.weights);
            const err = @intToFloat(f64, group) - prediction;

            for (self.weights) |weight, index|
                self.weights[index] = weight + err * set[index];
        }
    }
};

test "random set" {
    const trainer = Trainer.init_random(1024);
    try std.testing.expect(trainer.weights[0] >= 0 and trainer.weights[0] <= 1);
    try std.testing.expect(trainer.weights[1] >= 0 and trainer.weights[1] <= 1);
    try std.testing.expect(trainer.weights[2] >= 0 and trainer.weights[2] <= 1);
}

test "train set of 2 points" {
    var trainer = Trainer.init_random(1024);
    const points = [_]Point {
        .{ .x = 0, .y = 0, .group = 1 },
        .{ .x = 255, .y = 255, .group = 0 } };
    const iters = trainer.train(&points);

    try std.testing.expect(iters < trainer.max_iterations);
    try std.testing.expectEqual(points[0].group_from(trainer.weights), points[0].group orelse 255);
    try std.testing.expectEqual(points[1].group_from(trainer.weights), points[1].group orelse 255);
}

test "train set of 8 points" {
    var trainer = Trainer.init_random(1024);
    const points = [_]Point {
        .{ .x = 0, .y = 9, .group = 1 },
        .{ .x = 1, .y = 5, .group = 0 },
        .{ .x = 3, .y = 1, .group = 0 },
        .{ .x = 3, .y = 10, .group = 1 },
        .{ .x = 5, .y = 1, .group = 0 },
        .{ .x = 10, .y = 5, .group = 1 },
        .{ .x = 4, .y = 6, .group = 1 },
        .{ .x = 10, .y = 2, .group = 0 } };
    const iters = trainer.train(&points);

    try std.testing.expect(iters < trainer.max_iterations);
    try std.testing.expectEqual(points[0].group_from(trainer.weights), points[0].group orelse 255);
    try std.testing.expectEqual(points[1].group_from(trainer.weights), points[1].group orelse 255);
    try std.testing.expectEqual(points[2].group_from(trainer.weights), points[2].group orelse 255);
    try std.testing.expectEqual(points[3].group_from(trainer.weights), points[3].group orelse 255);
    try std.testing.expectEqual(points[4].group_from(trainer.weights), points[4].group orelse 255);
    try std.testing.expectEqual(points[5].group_from(trainer.weights), points[5].group orelse 255);
    try std.testing.expectEqual(points[6].group_from(trainer.weights), points[6].group orelse 255);
    try std.testing.expectEqual(points[7].group_from(trainer.weights), points[7].group orelse 255);
}

test "train set of impossible points" {
    var trainer = Trainer.init_random(1024);
    const points = [_]Point {
        .{ .x = 0, .y = 0, .group = 1 },
        .{ .x = 10, .y = 10, .group = 0 },
        .{ .x = 20, .y = 20, .group = 1 } };
    const iters = trainer.train(&points);

    try std.testing.expect(iters == trainer.max_iterations);
}
