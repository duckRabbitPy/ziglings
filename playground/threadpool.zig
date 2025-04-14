const std = @import("std");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    var pool: std.Thread.Pool = undefined;
    try pool.init(std.Thread.Pool.Options{ .allocator = allocator, .n_jobs = 5 });
    defer pool.deinit();

    // Spawn 4 threads with different increments
    try pool.spawn(work, .{3});
    try pool.spawn(work, .{5});
    try pool.spawn(work, .{7});
    try pool.spawn(work, .{10000}); // should finish first
}

fn work(inc: u32) void {
    std.debug.print("Start Inc = {d}\n", .{inc});
    var total: u32 = 0;
    var i: u32 = 0;
    while (i < 100000) : (i += 1) {
        total += inc;
    }
    std.debug.print("Total = {d}, Inc = {d}\n", .{ total, inc });
}
