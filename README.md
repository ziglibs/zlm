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
// using `as(f32)` to specify precision of fields
const math = @import("zlm").as(f32);

/// Accelerate the given velocity `v` by `a` over `t`.
fn accelerate(v: math.Vec3, a: math.Vec3, t: f32) math.Vec3 {
  return v.add(a.scale(t));
}
```
