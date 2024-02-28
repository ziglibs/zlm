const std = @import("std");

pub fn build(b: *std.Build) void {
    _ = b.addModule("zlm", .{
        .root_source_file = .{ .path = "src/zlm.zig" },
    });

    const test_exe = b.addTest(.{
        .root_source_file = .{ .path = "src/test.zig" },
    });

    const test_run = b.addRunArtifact(test_exe);

    b.getInstallStep().dependOn(&test_run.step);
}
