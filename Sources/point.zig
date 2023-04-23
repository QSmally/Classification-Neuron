
const std = @import("std");

pub const Point = struct {

    x: u8,
    y: u8,
    group: ?u8 = null,

    pub fn set(self: Point) [3]f64 {
        // Point set: [d, x, y]
        return .{
            1,
            @intToFloat(f64, self.x) / 255,
            @intToFloat(f64, self.y) / 255 };
    }

    pub fn prediction(self: Point, weights: [3]f64) f64 {
        const point_set = self.set();
        return (point_set[0] * weights[0]) +
            (point_set[1] * weights[1]) +
            (point_set[2] * weights[2]);
    }

    pub fn group_from(self: Point, weights: [3]f64) u8 {
        return if (self.prediction(weights) < 0) 0 else 1;
    }
};

test "min prediction" {
    const point = Point { .x = 255, .y = 255 };
    const prediction = point.group_from(.{ -0.5, -0.5, -0.5 });
    try std.testing.expectEqual(prediction, 0);
}

test "max prediction" {
    const point = Point { .x = 255, .y = 255 };
    const prediction = point.group_from(.{ 0.5, 0.5, 0.5 });
    try std.testing.expectEqual(prediction, 1);
}
