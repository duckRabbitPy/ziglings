// zig run ./playground/play.zig

//  zig build-exe playground/play.zig -femit-bin=./playground/play_executable
//  ./playground/play_executable

const std = @import("std");

const MappedSiteData = struct {
    Id: ?[]const u8,
    Site: ?[]const u8,
    City: ?[]const u8,
    Region: ?[]const u8,
    Country: ?[]const u8,
    Timezone: ?[]const u8,
};

const CustomError = error{
    FailedToMap,
    HeaderNotFound,
    OutOfMemory,
};

const HeaderMapping = struct {
    externalHeader: []const u8,
    internalField: []const u8,
};

fn mapColumnsFromHeaders(
    headers: []const []const u8,
    rows: []const []const []const u8,
    allocator: std.mem.Allocator,
    headerMappings: []const HeaderMapping,
) CustomError![]MappedSiteData {
    var headerPositions = std.StringHashMap(usize).init(allocator);
    defer headerPositions.deinit();

    for (headers, 0..) |header, i| {
        try headerPositions.put(header, i);
    }

    for (headerMappings) |hmap| {
        if (!headerPositions.contains(hmap.externalHeader)) {
            std.debug.print("Unrecognised Header! Header '{s}' not found in data\n", .{hmap.externalHeader});
            return CustomError.HeaderNotFound;
        }
    }

    // Allocate memory for the array of mapped data (one per row)
    var mappedRows = try allocator.alloc(MappedSiteData, rows.len);
    errdefer allocator.free(mappedRows);

    for (rows, 0..) |row, i| {
        var mappedData = MappedSiteData{
            .Id = null,
            .Site = null,
            .City = null,
            .Region = null,
            .Country = null,
            .Timezone = null,
        };

        for (headerMappings) |hmap| {
            // Get the column position of this external header in the input data
            if (headerPositions.get(hmap.externalHeader)) |pos| {
                if (std.mem.eql(u8, "Id", hmap.externalHeader)) {
                    // map the column to the internal field
                    mappedData.Id = row[pos];
                } else if (std.mem.eql(u8, "Site", hmap.internalField)) {
                    // map the column to the internal field
                    mappedData.Site = row[pos];
                } else if (std.mem.eql(u8, "City", hmap.internalField)) {
                    mappedData.City = row[pos];
                } else if (std.mem.eql(u8, "Region", hmap.internalField)) {
                    mappedData.Region = row[pos];
                } else if (std.mem.eql(u8, "Country", hmap.internalField)) {
                    mappedData.Country = row[pos];
                } else if (std.mem.eql(u8, "Timezone", hmap.internalField)) {
                    mappedData.Timezone = row[pos];
                }
            }
        }

        mappedRows[i] = mappedData;
    }

    return mappedRows;
}

const UnMappedData = struct {
    Headers: []const []const u8,
    Rows: []const []const []const u8,
};

fn getUnMappedData() UnMappedData {
    const row1 = &[_][]const u8{
        "3c58afe2-0029-4f9a-8e78-2a8060c19305",
        "London",
        "United Kingdom",
        "Royal Oak",
        "Europe/London",
        "Greater London",
    };
    const row2 = &[_][]const u8{
        "5b8f3c4e-0a2d-4f9a-8e78-2a8060c19305",
        "New York",
        "United States",
        "Central Park",
        "America/New_York",
        "New York",
    };
    const row3 = &[_][]const u8{
        "ef23a0ff-db39-41b9-9a6b-0bb35d9d5e74",
        "Paris",
        "France",
        "Eiffel Tower",
        "Europe/Paris",
        "Île-de-France",
    };

    return UnMappedData{
        .Headers = &[_][]const u8{ "uuid", "Town", "Nation", "Site Location", "TZ", "Area" },
        .Rows = &[_][]const []const u8{ row1, row2, row3 },
    };
}

const Integration = struct {
    uuid: []const u8,
    name: []const u8,
    version: []const u8,
    headerMappings: []const HeaderMapping,
};

fn getIntegration() Integration {
    const integrationHeaderMappings = [_]HeaderMapping{
        .{ .externalHeader = "uuid", .internalField = "Id" },
        .{ .externalHeader = "Site Location", .internalField = "Site" },
        .{ .externalHeader = "Town", .internalField = "City" },
        .{ .externalHeader = "Area", .internalField = "Region" },
        .{ .externalHeader = "Nation", .internalField = "Country" },
        .{ .externalHeader = "TZ", .internalField = "Timezone" },
    };
    return Integration{
        .uuid = "123e4567-e89b-12d3-a456-426614174000",
        .name = "Integration Name",
        .version = "1.0.0",
        .headerMappings = &integrationHeaderMappings,
    };
}

pub fn main() CustomError!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const integration1 = getIntegration();

    const unmapped = getUnMappedData();

    const mappedRows = try mapColumnsFromHeaders(
        unmapped.Headers,
        unmapped.Rows,
        allocator,
        integration1.headerMappings,
    );
    defer allocator.free(mappedRows);

    std.debug.print("Mapped Data for {d} rows:\n", .{mappedRows.len});

    for (mappedRows, 0..) |mapped, i| {
        std.debug.print("\nRow {d}:\n", .{i + 1});
        if (mapped.Site) |site| std.debug.print("Site: {s}\n", .{site});
        if (mapped.City) |city| std.debug.print("City: {s}\n", .{city});
        if (mapped.Region) |region| std.debug.print("Region: {s}\n", .{region});
        if (mapped.Country) |country| std.debug.print("Country: {s}\n", .{country});
        if (mapped.Timezone) |Timezone| std.debug.print("Timezone: {s}\n", .{Timezone});
    }
}
