const std = @import("std");

const raylibFlags = &[_][]const u8{
    "-std=gnu99",
    "-DPLATFORM_DESKTOP",
    "-DGL_SILENCE_DEPRECATION",
    "-fno-sanitize=undefined", // https://github.com/raysan5/raylib/issues/1891
};

pub fn build(b: *std.build.Builder) !void {
    var sources = std.ArrayList([]const u8).init(b.allocator);

    // Search for all C/C++ files in `src` and add them
    {
        var dir = try std.fs.cwd().openDir("./src", .{ .iterate = true });

        var walker = try std.fs.walkPath(b.allocator, "./src");
        defer walker.deinit();

        const allowed_exts = [_][]const u8{ ".c", ".cpp", ".cxx", ".c++", ".cc" };
        while (try walker.next()) |entry| {
            const ext = std.fs.path.extension(entry.basename);
            const include_file = for (allowed_exts) |e| {
                if (std.mem.eql(u8, ext, e))
                    break true;
            } else false;
            if (include_file) {
                // we have to clone the path as walker.next() or walker.deinit() will override/kill it
                try sources.append(b.dupe(entry.path));
            }
        }
    }

    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("my_game", null);
    exe.setTarget(target);
    exe.setBuildMode(mode);

    exe.addCSourceFiles(sources.items, &[_][]const u8{});
    exe.addCSourceFile("./raylib/src/rcore.c", raylibFlags);
    exe.addCSourceFile("./raylib/src/raudio.c", raylibFlags);
    exe.addCSourceFile("./raylib/src/rshapes.c", raylibFlags);
    exe.addCSourceFile("./raylib/src/rtext.c", raylibFlags);
    exe.addCSourceFile("./raylib/src/rtextures.c", raylibFlags);
    exe.addCSourceFile("./raylib/src/utils.c", raylibFlags);
    exe.addCSourceFile("./raylib/src/rglfw.c", raylibFlags);

    exe.linkLibC();
    exe.addIncludeDir("./include");
    exe.addIncludeDir("./raylib/src/external/glfw/include");

    switch (exe.target.toTarget().os.tag) {
        .windows => {
            exe.linkSystemLibrary("gdi32");
            exe.linkSystemLibrary("opengl32");
            exe.linkSystemLibrary("winmm");
            exe.addIncludeDir("./raylib/src/external/glfw/deps/mingw");
        },
        .linux => {
            exe.linkSystemLibrary("GL");
            exe.linkSystemLibrary("rt");
            exe.linkSystemLibrary("dl");
            exe.linkSystemLibrary("m");
            exe.linkSystemLibrary("X11");
        },
        else => {
            @panic("Unsupported OS");
        },
    }
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
