# zlm
Zig linear mathemathics library.

Current provides the following types:

- `Vec2`
- `Vec3`
- `Vec4`
- `Mat2`
- `Mat3`
- `Mat4`

The library is currently built around the OpenGL coordinate system and is fully generic on the basic data type.

## Example

```zig
const math = @import("zlm");

// Use this namespace to get access to a Vec3 with f16 fields instead of f32
const math_f16 = math.specializeOn(f16);

/// Accelerate the given velocity `v` by `a` over `t`.
fn accelerate(v: math.Vec3, a: math.Vec3, t: f32) math.Vec3 {
  return v.add(a.scale(t));
}
```