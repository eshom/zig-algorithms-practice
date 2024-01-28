const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "algorithms_practice",
        .root_source_file = .{ .path = "src/search.zig" },
        .target = target,
        .optimize = optimize,
    });

    // This declares intent for the executable to be installed into the
    // standard location when the user invokes the "install" step (the default
    // step when running `zig build`).
    b.installArtifact(exe);

    // This *creates* a Run step in the build graph, to be executed when another
    // step is evaluated that depends on it. The next line below will establish
    // such a dependency.
    const run_cmd = b.addRunArtifact(exe);

    // By making the run step depend on the install step, it will be run from the
    // installation directory rather than directly from within the cache directory.
    // This is not necessary, however, if the application depends on other installed
    // files, this ensures they will be present and in the expected location.
    run_cmd.step.dependOn(b.getInstallStep());

    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc`
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // This creates a build step. It will be visible in the `zig build --help` menu,
    // and can be selected like this: `zig build run`
    // This will evaluate the `run` step rather than the default, which is "install".
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // Creates a step for unit testing. This only builds the test executable
    // but does not run it.

    // Search algorithms
    const lib_unit_tests_search = b.addTest(.{
        .root_source_file = .{ .path = "src/search.zig" },
        .target = target,
        .optimize = optimize,
    });

    //Sorting algorithms
    const lib_unit_tests_sort = b.addTest(.{
        .root_source_file = .{ .path = "src/sort.zig" },
        .target = target,
        .optimize = optimize,
    });

    //Recursion-focused algorithms
    const lib_unit_tests_recur = b.addTest(.{
        .root_source_file = .{ .path = "src/recursion.zig" },
        .target = target,
        .optimize = optimize,
    });

    // Stack implementation
    const lib_unit_tests_stack = b.addTest(.{
        .root_source_file = .{ .path = "src/stack.zig" },
        .target = target,
        .optimize = optimize,
    });

    // Hashmap implementation
    const lib_unit_tests_hashmap = b.addTest(.{
        .root_source_file = .{ .path = "src/hashmap.zig" },
        .target = target,
        .optimize = optimize,
    });

    const run_lib_unit_tests_search = b.addRunArtifact(lib_unit_tests_search);
    const run_lib_unit_tests_sort = b.addRunArtifact(lib_unit_tests_sort);
    const run_lib_unit_tests_recur = b.addRunArtifact(lib_unit_tests_recur);
    const run_lib_unit_tests_stack = b.addRunArtifact(lib_unit_tests_stack);
    const run_lib_unit_tests_hashmap = b.addRunArtifact(lib_unit_tests_hashmap);

    const exe_unit_tests_search = b.addTest(.{
        .root_source_file = .{ .path = "src/search.zig" },
        .target = target,
        .optimize = optimize,
    });

    const exe_unit_tests_sort = b.addTest(.{
        .root_source_file = .{ .path = "src/sort.zig" },
        .target = target,
        .optimize = optimize,
    });

    const exe_unit_tests_recur = b.addTest(.{
        .root_source_file = .{ .path = "src/recursion.zig" },
        .target = target,
        .optimize = optimize,
    });

    const exe_unit_tests_stack = b.addTest(.{
        .root_source_file = .{ .path = "src/stack.zig" },
        .target = target,
        .optimize = optimize,
    });

    const exe_unit_tests_hashmap = b.addTest(.{
        .root_source_file = .{ .path = "src/hashmap.zig" },
        .target = target,
        .optimize = optimize,
    });


    const run_exe_unit_tests_search = b.addRunArtifact(exe_unit_tests_search);
    const run_exe_unit_tests_sort = b.addRunArtifact(exe_unit_tests_sort);
    const run_exe_unit_tests_recur = b.addRunArtifact(exe_unit_tests_recur);
    const run_exe_unit_tests_stack = b.addRunArtifact(exe_unit_tests_stack);
    const run_exe_unit_tests_hashmap = b.addRunArtifact(exe_unit_tests_hashmap);

    // Similar to creating the run step earlier, this exposes a `test` step to
    // the `zig build --help` menu, providing a way for the user to request
    // running the unit tests.
    const test_step_search = b.step("test-search", "Run unit tests search algorithms");
    test_step_search.dependOn(&run_lib_unit_tests_search.step);
    test_step_search.dependOn(&run_exe_unit_tests_search.step);

    const test_step_sort = b.step("test-sort", "Run unit tests sort algorithms");
    test_step_sort.dependOn(&run_lib_unit_tests_sort.step);
    test_step_sort.dependOn(&run_exe_unit_tests_sort.step);

    const test_step_recur = b.step("test-recursion", "Run unit tests recursion algorithms");
    test_step_recur.dependOn(&run_lib_unit_tests_recur.step);
    test_step_recur.dependOn(&run_exe_unit_tests_recur.step);

    const test_step_stack = b.step("test-stack", "Run unit tests stack algorithms");
    test_step_stack.dependOn(&run_lib_unit_tests_stack.step);
    test_step_stack.dependOn(&run_exe_unit_tests_stack.step);

    const test_step_hashmap = b.step("test-hashmap", "Run unit tests hashmap algorithms");
    test_step_hashmap.dependOn(&run_lib_unit_tests_hashmap.step);
    test_step_hashmap.dependOn(&run_exe_unit_tests_hashmap.step);
}
