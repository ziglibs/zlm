const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    _ = b.addModule("zlm", .{
        .root_source_file = b.path("src/zlm.zig"),
        .target = target,
        .optimize = optimize,
    });

    const test_exe = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/test.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    const test_run = b.addRunArtifact(test_exe);

    b.getInstallStep().dependOn(&test_run.step);
}
