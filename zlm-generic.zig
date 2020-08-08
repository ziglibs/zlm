const std = @import("std");

/// Makes all vector and matrix types generic against Real
pub fn specializeOn(comptime Real: type) type {
    return struct {
        /// Helper for the swizzle operator.
        /// Returns the type fitting the number of swizzle elements
        fn SwizzleTypeByElements(comptime i: usize) type {
            return switch (i) {
                1 => Real,
                2 => Vec2,
                3 => Vec3,
                4 => Vec4,
                else => @compileError("Swizzle can take up to 4 elements!"),
            };
        }

        /// Returns a type mixin for a vector type implementing all component-wise operations.
        /// Reduces the amount of duplicated code by a lot
        fn VectorMixin(comptime Self: type) type {
            return struct {
                /// adds all components from `a` with the components of `b`.
                pub fn add(a: Self, b: Self) Self {
                    var result: Self = undefined;
                    inline for (@typeInfo(Self).Struct.fields) |fld| {
                        @field(result, fld.name) = @field(a, fld.name) + @field(b, fld.name);
                    }
                    return result;
                }

                /// subtracts all components from `a` with the components of `b`.
                pub fn sub(a: Self, b: Self) Self {
                    var result: Self = undefined;
                    inline for (@typeInfo(Self).Struct.fields) |fld| {
                        @field(result, fld.name) = @field(a, fld.name) - @field(b, fld.name);
                    }
                    return result;
                }

                /// multiplies all components from `a` with the components of `b`.
                pub fn mul(a: Self, b: Self) Self {
                    var result: Self = undefined;
                    inline for (@typeInfo(Self).Struct.fields) |fld| {
                        @field(result, fld.name) = @field(a, fld.name) * @field(b, fld.name);
                    }
                    return result;
                }

                /// divides all components from `a` by the components of `b`.
                pub fn div(a: Self, b: Self) Self {
                    var result: Self = undefined;
                    inline for (@typeInfo(Self).Struct.fields) |fld| {
                        @field(result, fld.name) = @field(a, fld.name) / @field(b, fld.name);
                    }
                    return result;
                }

                /// multiplies all components by a scalar value.
                pub fn scale(a: Self, b: Real) Self {
                    var result: Self = undefined;
                    inline for (@typeInfo(Self).Struct.fields) |fld| {
                        @field(result, fld.name) = @field(a, fld.name) * b;
                    }
                    return result;
                }

                /// returns the dot product of two vectors.
                /// This is the sum of products of all components.
                pub fn dot(a: Self, b: Self) Real {
                    var result: Real = 0;
                    inline for (@typeInfo(Self).Struct.fields) |fld| {
                        result += @field(a, fld.name) * @field(b, fld.name);
                    }
                    return result;
                }

                /// returns the magnitude of the vector.
                pub fn length(a: Self) Real {
                    return std.math.sqrt(a.length2());
                }

                /// returns the squared magnitude of the vector.
                pub fn length2(a: Self) Real {
                    return Self.dot(a, a);
                }

                /// returns either a normalized vector (`length() = 1`) or `zero` if the vector
                /// has length 0.
                pub fn normalize(vec: Self) Self {
                    var len = vec.length();
                    return if (len != 0.0)
                        vec.scale(1.0 / vec.length())
                    else
                        Self.zero;
                }

                /// swizzle vector fields into a new vector type.
                /// swizzle("xxx") will return a Vec3 with three times the x component.
                /// swizzle will return a vector or scalar type with the same number of components as the
                /// `components` string.
                /// `components` may be any sequence of `x`, `y`, `z`, `w`, `0` and `1`.
                /// The letters will be replaced by the corresponding component, the digits will be replaced
                /// by the corresponding literal value.
                ///
                /// Examples:
                /// - `vec4(1,2,3,4).swizzle("wzyx") == vec4(4, 3, 2, 1)`
                /// - `vec4(1,2,3,4).swizzle("xyx") == vec3(1,2,1)`
                /// - `vec2(1,2).swizzle("xyxy") == vec4(1,2,1,2)`
                /// - `vec2(3,4).swizzle("xy01") == vec4(3, 4, 0, 1)`
                ///
                pub fn swizzle(self: Self, comptime components: []const u8) SwizzleTypeByElements(components.len) {
                    const T = SwizzleTypeByElements(components.len);
                    var result: T = undefined;

                    if (components.len > 1) {
                        const fieldorder = "xyzw";
                        inline for (components) |c, i| {
                            const slice = components[i .. i + 1];
                            const temp = if (comptime std.mem.eql(u8, slice, "0"))
                                0
                            else if (comptime std.mem.eql(u8, slice, "1"))
                                1
                            else
                                @field(self, components[i .. i + 1]);
                            @field(result, switch (i) {
                                0 => "x",
                                1 => "y",
                                2 => "z",
                                3 => "w",
                                else => @compileError("this should not happen"),
                            }) = temp;
                        }
                    } else if (components.len == 1) {
                        result = @field(self, components);
                    } else {
                        @compileError("components must at least contain a single field!");
                    }

                    return result;
                }

                /// returns a new vector where each component is the minimum of the components of the input vectors.
                pub fn componentMin(a: Self, b: Self) Self {
                    var result: Self = undefined;
                    inline for (@typeInfo(Self).Struct.fields) |fld| {
                        @field(result, fld.name) = std.math.min(@field(a, fld.name), @field(b, fld.name));
                    }
                    return result;
                }

                /// returns a new vector where each component is the maximum of the components of the input vectors.
                pub fn componentMax(a: Self, b: Self) Self {
                    var result: Self = undefined;
                    inline for (@typeInfo(Self).Struct.fields) |fld| {
                        @field(result, fld.name) = std.math.max(@field(a, fld.name), @field(b, fld.name));
                    }
                    return result;
                }
            };
        }

        /// 2-dimensional vector type.
        pub const Vec2 = extern struct {
            const Self = @This();

            x: Real,
            y: Real,

            pub const zero = Self.new(0, 0);
            pub const one = Self.new(1, 1);
            pub const unitX = Self.new(1, 0);
            pub const unitY = Self.new(0, 1);

            usingnamespace VectorMixin(Self);

            pub fn new(x: Real, y: Real) Self {
                return Self{
                    .x = x,
                    .y = y,
                };
            }

            pub fn format(value: Self, comptime fmt: []const u8, options: std.fmt.FormatOptions, stream: anytype) !void {
                try stream.print("vec2({d:.2}, {d:.2})", .{ value.x, value.y });
            }

            fn getField(vec: Self, comptime index: comptime_int) Real {
                switch (index) {
                    0 => return vec.x,
                    1 => return vec.y,
                    else => @compileError("index out of bounds!"),
                }
            }

            /// multiplies the vector with a matrix.
            pub fn transform(vec: Self, mat: Mat2) Self {
                var result = zero;
                inline for ([_]comptime_int{ 0, 1 }) |i| {
                    result.x += vec.getField(i) * mat.fields[0][i];
                    result.y += vec.getField(i) * mat.fields[1][i];
                }
                return result;
            }
        };

        /// 3-dimensional vector type.
        pub const Vec3 = extern struct {
            const Self = @This();

            x: Real,
            y: Real,
            z: Real,

            pub const zero = Self.new(0, 0, 0);
            pub const one = Self.new(1, 1, 1);
            pub const unitX = Self.new(1, 0, 0);
            pub const unitY = Self.new(0, 1, 0);
            pub const unitZ = Self.new(0, 0, 1);

            usingnamespace VectorMixin(Self);

            pub fn new(x: Real, y: Real, z: Real) Self {
                return Self{
                    .x = x,
                    .y = y,
                    .z = z,
                };
            }

            pub fn format(value: Self, comptime fmt: []const u8, options: std.fmt.FormatOptions, stream: anytype) !void {
                try stream.print("vec3({d:.2}, {d:.2}, {d:.2})", .{ value.x, value.y, value.z });
            }

            /// calculates the cross product. result will be perpendicular to a and b.
            pub fn cross(a: Self, b: Self) Self {
                return Self{
                    .x = a.y * b.z - a.z * b.y,
                    .y = a.z * b.x - a.x * b.z,
                    .z = a.x * b.y - a.y * b.x,
                };
            }

            /// converts the vector from an homogeneous position (w=1).
            pub fn toAffinePosition(a: Self) Vec4 {
                return Vec4{
                    .x = a.x,
                    .y = a.y,
                    .z = a.z,
                    .w = 1.0,
                };
            }

            /// converts the vector from an homogeneous direction (w=0).
            pub fn toAffineDirection(a: Self) Vec4 {
                return Vec4{
                    .x = a.x,
                    .y = a.y,
                    .z = a.z,
                    .w = 0.0,
                };
            }

            pub fn fromAffinePosition(a: Vec4) Self {
                return Vec3{
                    .x = a.x / a.w,
                    .y = a.y / a.w,
                    .z = a.z / a.w,
                };
            }

            pub fn fromAffineDirection(a: Vec4) Self {
                return Vec3{
                    .x = a.x,
                    .y = a.y,
                    .z = a.z,
                };
            }

            /// multiplies the vector with a matrix.
            pub fn transform(vec: Self, mat: Mat3) Self {
                var result = zero;
                inline for ([_]comptime_int{ 0, 1, 2 }) |i| {
                    result.x += vec.getField(i) * mat.fields[0][i];
                    result.y += vec.getField(i) * mat.fields[1][i];
                    result.z += vec.getField(i) * mat.fields[2][i];
                }
                return result;
            }

            /// transforms a homogeneous position.
            pub fn transformPosition(vec: Self, mat: Mat4) Self {
                return fromAffinePosition(vec.toAffinePosition().transform(mat));
            }

            /// transforms a homogeneous direction.
            pub fn transformDirection(vec: Self, mat: Mat4) Self {
                return fromAffineDirection(vec.toAffineDirection().transform(mat));
            }

            fn getField(vec: Self, comptime index: comptime_int) Real {
                switch (index) {
                    0 => return vec.x,
                    1 => return vec.y,
                    2 => return vec.z,
                    else => @compileError("index out of bounds!"),
                }
            }
        };

        /// 4-dimensional vector type.
        pub const Vec4 = extern struct {
            const Self = @This();

            x: Real,
            y: Real,
            z: Real,
            w: Real,

            pub const zero = Self.new(0, 0, 0, 0);
            pub const one = Self.new(1, 1, 1, 1);
            pub const unitX = Self.new(1, 0, 0, 0);
            pub const unitY = Self.new(0, 1, 0, 0);
            pub const unitZ = Self.new(0, 0, 1, 0);
            pub const unitW = Self.new(0, 0, 1, 0);

            usingnamespace VectorMixin(Self);

            pub fn new(x: Real, y: Real, z: Real, w: Real) Self {
                return Self{
                    .x = x,
                    .y = y,
                    .z = z,
                    .w = w,
                };
            }

            pub fn format(value: Self, comptime fmt: []const u8, options: std.fmt.FormatOptions, stream: anytype) !void {
                try stream.print("vec4({d:.2}, {d:.2}, {d:.2}, {d:.2})", .{ value.x, value.y, value.z, value.w });
            }

            /// multiplies the vector with a matrix.
            pub fn transform(vec: Self, mat: Mat4) Self {
                var result = zero;
                inline for ([_]comptime_int{ 0, 1, 2, 3 }) |i| {
                    result.x += vec.getField(i) * mat.fields[i][0];
                    result.y += vec.getField(i) * mat.fields[i][1];
                    result.z += vec.getField(i) * mat.fields[i][2];
                    result.w += vec.getField(i) * mat.fields[i][3];
                }
                return result;
            }

            fn getField(vec: Self, comptime index: comptime_int) Real {
                switch (index) {
                    0 => return vec.x,
                    1 => return vec.y,
                    2 => return vec.z,
                    3 => return vec.w,
                    else => @compileError("index out of bounds!"),
                }
            }
        };

        /// 2 by 2 matrix type.
        pub const Mat2 = extern struct {
            fields: [2][2]Real, // [row][col]

            /// identitiy matrix
            pub const identity = Self{
                .fields = [2]Real{
                    [2]Real{ 1, 0 },
                    [2]Real{ 0, 1 },
                },
            };
        };

        /// 3 by 3 matrix type.
        pub const Mat3 = extern struct {
            fields: [3][3]Real, // [row][col]

            /// identitiy matrix
            pub const identity = Self{
                .fields = [3]Real{
                    [3]Real{ 1, 0, 0 },
                    [3]Real{ 0, 1, 0 },
                    [3]Real{ 0, 0, 1 },
                },
            };
        };

        /// 4 by 4 matrix type.
        pub const Mat4 = extern struct {
            pub const Self = @This();
            fields: [4][4]Real, // [row][col]

            /// zero matrix.
            pub const zero = Self{
                .fields = [4][4]Real{
                    [4]Real{ 0, 0, 0, 0 },
                    [4]Real{ 0, 0, 0, 0 },
                    [4]Real{ 0, 0, 0, 0 },
                    [4]Real{ 0, 0, 0, 0 },
                },
            };

            /// identitiy matrix
            pub const identity = Self{
                .fields = [4][4]Real{
                    [4]Real{ 1, 0, 0, 0 },
                    [4]Real{ 0, 1, 0, 0 },
                    [4]Real{ 0, 0, 1, 0 },
                    [4]Real{ 0, 0, 0, 1 },
                },
            };

            pub fn format(value: Self, comptime fmt: []const u8, options: std.fmt.FormatOptions, stream: anytype) !void {
                try stream.writeAll("mat4{");

                inline for ([_]comptime_int{ 0, 1, 2, 3 }) |i| {
                    const row = value.fields[i];
                    try stream.print(" ({d:.2} {d:.2} {d:.2} {d:.2})", .{ row[0], row[1], row[2], row[3] });
                }

                try stream.writeAll(" }");
            }

            /// performs matrix multiplication of a*b
            pub fn mul(a: Self, b: Self) Self {
                var result: Self = undefined;
                inline for ([_]comptime_int{ 0, 1, 2, 3 }) |row| {
                    inline for ([_]comptime_int{ 0, 1, 2, 3 }) |col| {
                        var sum: Real = 0.0;
                        inline for ([_]comptime_int{ 0, 1, 2, 3 }) |i| {
                            sum += a.fields[row][i] * b.fields[i][col];
                        }
                        result.fields[row][col] = sum;
                    }
                }
                return result;
            }

            /// transposes the matrix.
            /// this will swap columns with rows.
            pub fn transpose(a: Self) Self {
                var result: Self = undefined;
                inline for ([_]comptime_int{ 0, 1, 2, 3 }) |row| {
                    inline for ([_]comptime_int{ 0, 1, 2, 3 }) |col| {
                        result.fields[row][col] = a.fields[col][row];
                    }
                }
                return result;
            }

            // taken from GLM implementation

            /// Creates a look-at matrix.
            /// The matrix will create a transformation that can be used
            /// as a camera transform.
            /// the camera is located at `eye` and will look into `direction`.
            /// `up` is the direction from the screen center to the upper screen border.
            pub fn createLook(eye: Vec3, direction: Vec3, up: Vec3) Self {
                const f = direction.normalize();
                const s = Vec3.cross(up, f).normalize();
                const u = Vec3.cross(f, s);

                var result = Self.identity;
                result.fields[0][0] = s.x;
                result.fields[1][0] = s.y;
                result.fields[2][0] = s.z;
                result.fields[0][1] = u.x;
                result.fields[1][1] = u.y;
                result.fields[2][1] = u.z;
                result.fields[0][2] = f.x;
                result.fields[1][2] = f.y;
                result.fields[2][2] = f.z;
                result.fields[3][0] = -Vec3.dot(s, eye);
                result.fields[3][1] = -Vec3.dot(u, eye);
                result.fields[3][2] = -Vec3.dot(f, eye);
                return result;
            }

            /// Creates a look-at matrix.
            /// The matrix will create a transformation that can be used
            /// as a camera transform.
            /// the camera is located at `eye` and will look at `center`.
            /// `up` is the direction from the screen center to the upper screen border.
            pub fn createLookAt(eye: Vec3, center: Vec3, up: Vec3) Self {
                return createLook(eye, Vec3.sub(center, eye), up);
            }

            // taken from GLM implementation

            /// creates a perspective transformation matrix.
            /// `fov` is the field of view in radians,
            /// `aspect` is the screen aspect ratio (width / height)
            /// `near` is the distance of the near clip plane, whereas `far` is the distance to the far clip plane.
            pub fn createPerspective(fov: Real, aspect: Real, near: Real, far: Real) Self {
                std.debug.assert(std.math.fabs(aspect - 0.001) > 0);

                const tanHalfFovy = std.math.tan(fov / 2);

                var result = Self.zero;
                result.fields[0][0] = 1.0 / (aspect * tanHalfFovy);
                result.fields[1][1] = 1.0 / (tanHalfFovy);
                result.fields[2][2] = far / (far - near);
                result.fields[2][3] = 1;
                result.fields[3][2] = -(far * near) / (far - near);
                return result;
            }

            /// creates a rotation matrix around a certain axis.
            pub fn createAngleAxis(axis: Vec3, angle: Real) Self {
                var cos = std.math.cos(angle);
                var sin = std.math.sin(angle);
                var x = axis.x;
                var y = axis.y;
                var z = axis.z;

                return Self{
                    .fields = [4][4]Real{
                        [4]Real{ cos + x * x * (1 - cos), x * y * (1 - cos) - z * sin, x * z * (1 - cos) + y * sin, 0 },
                        [4]Real{ y * x * (1 - cos) + z * sin, cos + y * y * (1 - cos), y * z * (1 - cos) - x * sin, 0 },
                        [4]Real{ z * x * (1 * cos) - y * sin, z * y * (1 - cos) + x * sin, cos + z * z * (1 - cos), 0 },
                        [4]Real{ 0, 0, 0, 1 },
                    },
                };
            }

            /// creates matrix that will scale a homogeneous matrix.
            pub fn createScale(scale: Real) Self {
                return Self{
                    .fields = [4][4]Real{
                        [4]Real{ scale, 0, 0, 0 },
                        [4]Real{ 0, scale, 0, 0 },
                        [4]Real{ 0, 0, scale, 0 },
                        [4]Real{ 0, 0, 0, 1 },
                    },
                };
            }

            /// creates matrix that will translate a homogeneous matrix.
            pub fn createTranslationXYZ(x: Real, y: Real, z: Real) Self {
                return Self{
                    .fields = [4][4]Real{
                        [4]Real{ 1, 0, 0, 0 },
                        [4]Real{ 0, 1, 0, 0 },
                        [4]Real{ 0, 0, 1, 0 },
                        [4]Real{ x, y, z, 1 },
                    },
                };
            }

            /// creates matrix that will scale a homogeneous matrix.
            pub fn createTranslation(v: Vec3) Self {
                return Self{
                    .fields = [4][4]Real{
                        [4]Real{ 1, 0, 0, 0 },
                        [4]Real{ 0, 1, 0, 0 },
                        [4]Real{ 0, 0, 1, 0 },
                        [4]Real{ v.x, v.y, v.z, 1 },
                    },
                };
            }

            /// creates an orthogonal projection matrix.
            /// `left`, `right`, `bottom` and `top` are the borders of the screen whereas `near` and `far` define the
            /// distance of the near and far clipping planes.
            pub fn createOrthogonal(left: Real, right: Real, bottom: Real, top: Real, near: Real, far: Real) Self {
                var result = Self.identity;
                result.fields[0][0] = 2 / (right - left);
                result.fields[1][1] = 2 / (top - bottom);
                result.fields[2][2] = 1 / (far - near);
                result.fields[3][0] = -(right + left) / (right - left);
                result.fields[3][1] = -(top + bottom) / (top - bottom);
                result.fields[3][2] = -near / (far - near);
                return result;
            }

            /// Batch matrix multiplication. Will multiply all matrices from "first" to "last".
            pub fn batchMul(items: []const Self) Self {
                if (items.len == 0)
                    return Self.identity;
                if (items.len == 1)
                    return items[0];
                var value = items[0];
                var i: usize = 1;
                while (i < items.len) : (i += 1) {
                    value = value.mul(items[i]);
                }
                return value;
            }
        };

        /// constructs a new Vec2.
        pub fn vec2(x: Real, y: Real) Vec2 {
            return Vec2.new(x, y);
        }

        /// constructs a new Vec3.
        pub fn vec3(x: Real, y: Real, z: Real) Vec3 {
            return Vec3.new(x, y, z);
        }

        /// constructs a new Vec4.
        pub fn vec4(x: Real, y: Real, z: Real, w: Real) Vec4 {
            return Vec4.new(x, y, z, w);
        }
    };
}
