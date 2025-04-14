const std = @import("std");

fn buildSlice(allocator: std.mem.Allocator, size: usize) ![]u8 {
    // Allocate memory for the slice
    const slice = try allocator.alloc(u8, size);

    for (slice, 0..) |*item, index| {
        item.* = @intCast(index % 256);
    }

    return slice;
}

fn checkMemory(allocator_state: std.heap.Check) void {
    switch (allocator_state) {
        .ok => std.debug.print("Memory check: All allocations were freed properly\n", .{}),
        .leak => std.debug.print("Memory check: LEAK DETECTED - Not all allocations were freed\n", .{}),
    }
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const leaked = gpa.deinit();
        checkMemory(leaked);
    }

    const allocator = gpa.allocator();

    // Get command line arguments
    var args_iter = try std.process.argsWithAllocator(allocator);
    defer args_iter.deinit();

    _ = args_iter.next();

    var size: usize = 10; // Default size

    if (args_iter.next()) |arg| {
        size = try std.fmt.parseUnsigned(usize, arg, 10);
    } else {
        std.debug.print("Using default size: {d}\n", .{size});
    }

    // Allocate and initialize the slice
    const slice = try buildSlice(allocator, size);
    // Important: defer the freeing of the slice
    defer allocator.free(slice);

    std.debug.print("Slice with {d} elements:\n", .{slice.len});
    for (slice, 0..) |item, i| {
        std.debug.print("  [{d}]: {d}\n", .{ i, item });
    }
}
