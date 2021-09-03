const std = @import("std");

pub const specializeOn = @import("zlm-generic.zig").specializeOn;

/// Converts degrees to radian
pub fn toRadians(deg: anytype) @TypeOf(deg) {
    return std.math.pi * deg / 180.0;
}

/// Converts radian to degree
pub fn toDegrees(rad: anytype) @TypeOf(rad) {
    return 180.0 * rad / std.math.pi;
}

// export all vectors by-default to f32
usingnamespace specializeOn(f32);
