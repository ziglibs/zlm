const std = @import("std");
const math = @import("zlm.zig");
const assert = std.debug.assert;

const math_f32 = math.as(f32);

const vec2 = math_f32.vec2;
const vec3 = math_f32.vec3;
const vec4 = math_f32.vec4;
const quat = math_f32.quat;

const Vec2 = math_f32.Vec2;
const Vec3 = math_f32.Vec3;
const Vec4 = math_f32.Vec4;
const Quat = math_f32.Quat;

const Mat3 = math_f32.Mat3;
const Mat4 = math_f32.Mat4;

test "default generic is f32" {
    const T = @TypeOf(vec2(1, 2).x);
    try std.testing.expectEqual(T, f32);
}

test "as()" {
    const math_u64 = math.as(u64);
    const T = @TypeOf(math_u64.vec2(3, 4).x);
    try std.testing.expectEqual(T, u64);
}

test "constructors" {
    const v2 = vec2(1, 2);
    assert(v2.x == 1);
    assert(v2.y == 2);

    const v3 = vec3(1, 2, 3);
    assert(v3.x == 1);
    assert(v3.y == 2);
    assert(v3.z == 3);

    const v4 = vec4(1, 2, 3, 4);
    assert(v4.x == 1);
    assert(v4.y == 2);
    assert(v4.z == 3);
    assert(v4.w == 4);
}

test "vec2 arithmetics" {
    const a = vec2(2, 1);
    const b = vec2(1, 2);

    assert(std.meta.eql(Vec2.add(a, b), vec2(3, 3)));
    assert(std.meta.eql(Vec2.sub(a, b), vec2(1, -1)));
    assert(std.meta.eql(Vec2.mul(a, b), vec2(2, 2)));
    assert(std.meta.eql(Vec2.div(a, b), vec2(2, 0.5)));
    assert(std.meta.eql(Vec2.scale(a, 2.0), vec2(4, 2)));

    assert(Vec2.dot(a, b) == 4.0);

    assert(Vec2.length2(a) == 5.0);
    assert(Vec2.length(a) == std.math.sqrt(5.0));
    assert(Vec2.length(b) == std.math.sqrt(5.0));
}

test "vec3 arithmetics" {
    const a = vec3(2, 1, 3);
    const b = vec3(1, 2, 3);

    assert(std.meta.eql(Vec3.add(a, b), vec3(3, 3, 6)));
    assert(std.meta.eql(Vec3.sub(a, b), vec3(1, -1, 0)));
    assert(std.meta.eql(Vec3.mul(a, b), vec3(2, 2, 9)));
    assert(std.meta.eql(Vec3.div(a, b), vec3(2, 0.5, 1)));
    assert(std.meta.eql(Vec3.scale(a, 2.0), vec3(4, 2, 6)));

    assert(Vec3.dot(a, b) == 13.0);

    assert(Vec3.length2(a) == 14.0);
    assert(Vec3.length(a) == std.math.sqrt(14.0));
    assert(Vec3.length(b) == std.math.sqrt(14.0));

    assert(std.meta.eql(Vec3.cross(vec3(1, 2, 3), vec3(-7, 8, 9)), vec3(-6, -30, 22)));
}

test "vec4 arithmetics" {
    const a = vec4(2, 1, 4, 3);
    const b = vec4(1, 2, 3, 4);

    assert(std.meta.eql(Vec4.add(a, b), vec4(3, 3, 7, 7)));
    assert(std.meta.eql(Vec4.sub(a, b), vec4(1, -1, 1, -1)));
    assert(std.meta.eql(Vec4.mul(a, b), vec4(2, 2, 12, 12)));
    assert(std.meta.eql(Vec4.div(a, b), vec4(2, 0.5, 4.0 / 3.0, 3.0 / 4.0)));
    assert(std.meta.eql(Vec4.scale(a, 2.0), vec4(4, 2, 8, 6)));

    assert(Vec4.dot(a, b) == 28.0);

    assert(Vec4.length2(a) == 30.0);
    assert(Vec4.length(a) == std.math.sqrt(30.0));
    assert(Vec4.length(b) == std.math.sqrt(30.0));
}

test "vec3 <-> vec4 interop" {
    const v = vec3(1, 2, 3);
    const pos = vec4(1, 2, 3, 1);
    const dir = vec4(1, 2, 3, 0);

    assert(std.meta.eql(Vec3.toAffinePosition(v), pos));
    assert(std.meta.eql(Vec3.toAffineDirection(v), dir));

    assert(std.meta.eql(Vec3.fromAffinePosition(pos), v));
    assert(std.meta.eql(Vec3.fromAffineDirection(dir), v));
}

// TODO: write tests for mat2, mat3

// zig fmt: off
test "mat4 arithmetics" {
    const id = Mat4.identity;

    const mat = Mat4{
        .fields = [4][4]f32{
            // zig fmt: off
            [4]f32{  1,  2,  3,  4 },
            [4]f32{  5,  6,  7,  8 },
            [4]f32{  9, 10, 11, 12 },
            [4]f32{ 13, 14, 15, 16 },
            // zig-fmt: on
        },
    };

    const mat_mult_by_mat_by_hand = Mat4{
        .fields = [4][4]f32{
            // zig fmt: off
            [4]f32{ 90, 100, 110, 120 },
            [4]f32{ 202, 228, 254, 280 },
            [4]f32{ 314, 356, 398, 440 },
            [4]f32{ 426, 484, 542, 600 },
            // zig-fmt: on
        },
    };

    const mat_transposed = Mat4{
        .fields = [4][4]f32{
            [4]f32{ 1, 5, 9, 13 },
            [4]f32{ 2, 6, 10, 14 },
            [4]f32{ 3, 7, 11, 15 },
            [4]f32{ 4, 8, 12, 16 },
        },
    };

    const mat_a = Mat4{
        .fields = [4][4]f32{
            [4]f32{ 1, 2, 3, 1 },
            [4]f32{ 2, 3, 1, 2 },
            [4]f32{ 3, 1, 2, 3 },
            [4]f32{ 1, 2, 3, 1 },
        },
    };

    const mat_b = Mat4{
        .fields = [4][4]f32{
            [4]f32{ 3, 2, 1, 3 },
            [4]f32{ 2, 1, 3, 2 },
            [4]f32{ 1, 3, 2, 1 },
            [4]f32{ 3, 2, 1, 3 },
        },
    };

    const mat_a_times_b = Mat4{
        .fields = [4][4]f32{
            [4]f32{ 13, 15, 14, 13 },
            [4]f32{ 19, 14, 15, 19 },
            [4]f32{ 22, 19, 13, 22 },
            [4]f32{ 13, 15, 14, 13 },
        },
    };

    const mat_b_times_a = Mat4{
        .fields = [4][4]f32{
            [4]f32{ 13, 19, 22, 13 },
            [4]f32{ 15, 14, 19, 15 },
            [4]f32{ 14, 15, 13, 14 },
            [4]f32{ 13, 19, 22, 13 },
        },
    };

    // make sure basic properties are not messed up
    assert(std.meta.eql(Mat4.mul(id, id), id));
    assert(std.meta.eql(Mat4.mul(mat, id), mat));
    assert(std.meta.eql(Mat4.mul(id, mat), mat));

    assert(std.meta.eql(Mat4.mul(mat, mat), mat_mult_by_mat_by_hand));
    assert(std.meta.eql(Mat4.mul(mat_a, mat_b), mat_a_times_b));
    assert(std.meta.eql(Mat4.mul(mat_b, mat_a), mat_b_times_a));

    assert(std.meta.eql(Mat4.transpose(mat), mat_transposed));
}
// zig fmt: on

test "vec4 transform" {
    const mat = Mat4{
        .fields = [4][4]f32{
            // zig fmt: off
            [4]f32{ 1, 2, 3, 4 },
            [4]f32{ 5, 6, 7, 8 },
            [4]f32{ 9, 10, 11, 12 },
            [4]f32{ 13, 14, 15, 16 },
            // zig-fmt: on
        },
    };

    const transform = Mat4{
        .fields = [4][4]f32{
            // zig fmt: off
            [4]f32{ 2, 0, 0, 0 },
            [4]f32{ 0, 2, 0, 0 },
            [4]f32{ 0, 0, 2, 0 },
            [4]f32{ 10, 20, 30, 1 },
            // zig-fmt: on
        },
    };

    const vec = vec4(1, 2, 3, 4);

    assert(std.meta.eql(Vec4.transform(vec, mat), vec4(90, 100, 110, 120)));
    assert(std.meta.eql(Vec4.transform(vec4(1, 2, 3, 1), transform), vec4(12, 24, 36, 1)));
    assert(std.meta.eql(Vec4.transform(vec4(1, 2, 3, 0), transform), vec4(2, 4, 6, 0)));
}

test "vec2 swizzle" {
    assert(std.meta.eql(vec4(0, 1, 1, 2), vec2(1, 2).swizzle("0x1y")));
    assert(std.meta.eql(vec2(2, 1), vec2(1, 2).swizzle("yx")));
}

test "vec3 swizzle" {
    assert(std.meta.eql(vec4(1, 1, 2, 3), vec3(1, 2, 3).swizzle("xxyz")));
    assert(std.meta.eql(vec2(3, 3), vec3(1, 2, 3).swizzle("zz")));
}

test "vec4 swizzle" {
    assert(std.meta.eql(vec4(3, 4, 2, 1), vec4(1, 2, 3, 4).swizzle("zwyx")));
    assert(std.meta.eql(@as(f32, 3), vec4(1, 2, 3, 4).swizzle("z")));
}

test "vec2 format" {
    try std.testing.expectFmt("vec2(1.00, 2.00)", "{f}", .{vec2(1, 2)});
}

test "vec3 format" {
    try std.testing.expectFmt("vec3(1.00, 2.00, 3.00)", "{f}", .{vec3(1, 2, 3)});
}

test "vec4 format" {
    try std.testing.expectFmt("vec4(1.00, 2.00, 3.00, 4.00)", "{f}", .{vec4(1, 2, 3, 4)});
}

test "mat4 format" {
    const mat = Mat4{
        .fields = [4][4]f32{
            // zig fmt: off
            [4]f32{ 1,  2,  3,  4 },
            [4]f32{ 5,  6,  7,  8 },
            [4]f32{ 9,  10, 11, 12 },
            [4]f32{ 13, 14, 15, 16 },
            // zig-fmt: on
        },
    };
    try std.testing.expectFmt("mat4{ (1.00 2.00 3.00 4.00) (5.00 6.00 7.00 8.00) (9.00 10.00 11.00 12.00) (13.00 14.00 15.00 16.00) }", "{f}", .{mat});
}

test "quat constructor" {
    const q = quat(1, 2, 3, 4);
    assert(q.x == 1);
    assert(q.y == 2);
    assert(q.z == 3);
    assert(q.w == 4);
}

test "quat identity" {
    const id = Quat.identity;
    assert(id.x == 0);
    assert(id.y == 0);
    assert(id.z == 0);
    assert(id.w == 1);
}

test "quat length" {
    const q = quat(1, 2, 3, 4);
    assert(Quat.length2(q) == 30.0);
    assert(Quat.length(q) == std.math.sqrt(30.0));
}

test "quat normalize" {
    const q = quat(0, 0, 0, 2);
    const n = Quat.normalize(q);
    assert(n.x == 0);
    assert(n.y == 0);
    assert(n.z == 0);
    assert(n.w == 1);
}

test "quat conjugate" {
    const q = quat(1, 2, 3, 4);
    const c = Quat.conjugate(q);
    assert(c.x == -1);
    assert(c.y == -2);
    assert(c.z == -3);
    assert(c.w == 4);
}

test "quat mul identity" {
    const q = quat(1, 2, 3, 4);
    const id = Quat.identity;

    const q_times_id = Quat.mul(q, id);
    const id_times_q = Quat.mul(id, q);

    assert(std.meta.eql(q_times_id, q));
    assert(std.meta.eql(id_times_q, q));
}

test "quat mul" {
    const a = quat(1, 2, 3, 4);
    const b = quat(5, 6, 7, 8);

    const result = Quat.mul(a, b);

    // Quaternion multiplication by hand:
    // w = 4*8 - 1*5 - 2*6 - 3*7 = 32 - 5 - 12 - 21 = -6
    // x = 4*5 + 1*8 + 2*7 - 3*6 = 20 + 8 + 14 - 18 = 24
    // y = 4*6 - 1*7 + 2*8 + 3*5 = 24 - 7 + 16 + 15 = 48
    // z = 4*7 + 1*6 - 2*5 + 3*8 = 28 + 6 - 10 + 24 = 48
    assert(result.x == 24);
    assert(result.y == 48);
    assert(result.z == 48);
    assert(result.w == -6);
}

test "quat fromAxisAngle" {
    const pi = std.math.pi;

    // 180 degree rotation around Z axis
    const q = Quat.fromAxisAngle(vec3(0, 0, 1), pi);

    // sin(pi/2) = 1, cos(pi/2) = 0
    try std.testing.expectApproxEqAbs(@as(f32, 0), q.x, 1e-6);
    try std.testing.expectApproxEqAbs(@as(f32, 0), q.y, 1e-6);
    try std.testing.expectApproxEqAbs(@as(f32, 1), q.z, 1e-6);
    try std.testing.expectApproxEqAbs(@as(f32, 0), q.w, 1e-6);
}

test "quat rotateVec3" {
    const pi = std.math.pi;

    // 90 degree rotation around Z axis
    const q = Quat.fromAxisAngle(vec3(0, 0, 1), pi / 2.0);
    const v = vec3(1, 0, 0);
    const rotated = Quat.rotateVec3(q, v);

    // Rotating (1,0,0) by 90 degrees around Z should give (0,1,0)
    try std.testing.expectApproxEqAbs(@as(f32, 0), rotated.x, 1e-6);
    try std.testing.expectApproxEqAbs(@as(f32, 1), rotated.y, 1e-6);
    try std.testing.expectApproxEqAbs(@as(f32, 0), rotated.z, 1e-6);
}

test "quat slerp" {
    const id = Quat.identity;
    const q = quat(0, 0, 0.7071068, 0.7071068); // ~90 degrees around Z

    // slerp at t=0 should give first quaternion
    const s0 = Quat.slerp(id, q, 0);
    assert(Quat.approxEqAbs(s0, id, 1e-6));

    // slerp at t=1 should give second quaternion
    const s1 = Quat.slerp(id, q, 1);
    assert(Quat.approxEqAbs(s1, q, 1e-6));
}

test "quat format" {
    try std.testing.expectFmt("quat(1.00, 2.00, 3.00, 4.00)", "{f}", .{quat(1, 2, 3, 4)});
}
