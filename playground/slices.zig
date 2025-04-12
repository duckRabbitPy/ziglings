const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var cyclesArg: u32 = 20;

    // Get command line arguments
    var args = try std.process.argsWithAllocator(allocator);
    defer args.deinit();

    _ = args.next();

    // Parse cycles argument if provided
    if (args.next()) |cycles_arg| {
        // parse up to u32 but only support u12
        cyclesArg = try std.fmt.parseInt(u32, cycles_arg, 10);
    } else {
        std.debug.print("Using default cycles: {d}\n", .{cyclesArg});
    }

    if (cyclesArg < 1) {
        std.debug.print("Cycles must be greater than 0.\n", .{});
        return;
    }

    if (cyclesArg > 4095) {
        std.debug.print("Cycles must be less than or equal to 4095.\n", .{});
        return;
    }

    var cycles: u12 = @intCast(cyclesArg);
    printWave(&cycles);
}

fn printWave(cycles: *u12) void {
    const wavesegments = [_][]const u8{
        "~~~~~",
        "~~~~",
        "~~~",
        "~~",
        "~",
        "~~",
        "~~~",
        "~~~~",
        "~~~~~",
    };

    var waves = cycles.* * wavesegments.len;

    const middle = wavesegments.len / 2;
    var growing = true;
    var current_length: u8 = 0;

    while (waves > 0) {
        drawWave(current_length, middle, &wavesegments);
        current_length = updateWaveLength(current_length, middle, &growing);
        waves -= 1;
    }
}

fn drawWave(length: u8, middle: usize, wavesegments: *const [9][]const u8) void {
    for (0..length) |wavelength| {
        const front_idx = middle - wavelength;
        const back_idx = middle + wavelength;

        printWaveSegment(front_idx, wavesegments);
        printWaveSegment(back_idx, wavesegments);
    }
    if (length == 1) {
        std.debug.print("\n", .{});
        std.debug.print("{s}", .{wavesegments[middle]});
        return;
    }
    std.debug.print("\n", .{});
}

fn printWaveSegment(index: usize, wavesegments: *const [9][]const u8) void {
    if (index < wavesegments.len) {
        std.debug.print("{s}", .{wavesegments[index]});
    }
}

fn updateWaveLength(current_length: u8, middle: usize, growing: *bool) u8 {
    var new_length = current_length;

    if (growing.*) {
        new_length += 1;
        if (new_length >= middle) {
            growing.* = false;
        }
    } else {
        if (new_length > 0) {
            new_length -= 1;
        }
        if (new_length == 0) {
            growing.* = true;
        }
    }

    return new_length;
}
