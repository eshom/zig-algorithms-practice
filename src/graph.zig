const std = @import("std");
const queue = @import("queue.zig");
const HashMap = std.StringHashMap([]const []const u8);
const t = std.testing;

const Graph = struct {
    nodes: HashMap,
    allocator: std.mem.Allocator,

    fn deinit(self: *Graph) void {
        self.nodes.deinit();
    }
};

test "Graph" {
    var graph = Graph{.nodes = HashMap.init(t.allocator), .allocator = t.allocator};
    defer graph.deinit();

    const item = [_][]const u8{"alice", "bob", "claire"};

    try graph.nodes.put("one key", &item);

    std.debug.print("\"{s}\" -> {s}\n", .{"one key", graph.nodes.get("one key").?});
    try t.expectEqualDeep(&item, graph.nodes.get("one key").?);
}

fn endsWithM(name: []const u8) bool {
    return if (name[name.len - 1] == 'm') true else false;
}

fn bfs(graph: *const Graph, start_key: []const u8, find: fn ([]const u8) bool) !bool {
    var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa = general_purpose_allocator.allocator();
    var arena_instance = std.heap.ArenaAllocator.init(gpa);
    defer arena_instance.deinit();
    const arena = arena_instance.allocator();

    var search_queue = try queue.Queue([]const u8, 100).init(arena);

    var searched = std.StringHashMap(void).init(arena);
    defer searched.deinit();
    defer search_queue.deinit();

    const start_names = graph.nodes.get(start_key) orelse return false;

    for (start_names) |name| {
        try search_queue.enqueue(name);
    }

    var step_count: usize = 0;

    while (search_queue.size != 0) {
        const person = try search_queue.dequeue();

        var already_searched = false;
        var keys = searched.keyIterator();
        while (keys.next()) |key| {
            already_searched = if (std.mem.eql(u8, person, key.*)) true else false;
        }

        if (!already_searched) {
            if (find(person)) {
                std.debug.print("Found {s}! Steps: {d}\n", .{person, step_count});
                return true;
            } else {
                const neighbor_names = graph.nodes.get(person) orelse continue;
                for (neighbor_names) |name| {
                    try search_queue.enqueue(name);
                }
            }
        }
        step_count += 1;
    }

    std.debug.print("BFS over, found no one :-( search steps: {d}\n", .{step_count});
    return false;
}

test "breadth-first search" {
    const me = [_][]const u8{"alice", "bob"};
    const alice = [_][]const u8{"tiff"};
    const tiff = [_][]const u8{"sam", "peter", "slick"};
    const sam = [_][]const u8{};
    const peter = [_][]const u8{};
    const slick = [_][]const u8{"peter"};
    const bob = [_][]const u8{"jake"};
    const jake = [_][]const u8{"me", "alice", "karen"};
    const karen = [_][]const u8{};

    const people = [_][]const []const u8{&me, &alice, &tiff, &sam, &peter, &slick, &bob, &jake, &karen};
    const people_k = [_][]const u8{"me", "alice", "tiff", "sam", "peter", "slick", "bob", "jake", "karen"};

    var graph = Graph{.nodes = HashMap.init(t.allocator), .allocator = t.allocator};
    defer graph.deinit();

    for (people, people_k) |pl, k| {
        try graph.nodes.put(k, pl);
    }

    std.debug.print("Starting from 'me': ", .{});
    var found = try bfs(&graph, "me", endsWithM);
    try t.expect(found);
    std.debug.print("Starting from 'karen': ", .{});
    found = try bfs(&graph, "karen", endsWithM);
    try t.expect(!found);
    std.debug.print("Starting from 'tiff': ", .{});
    found = try bfs(&graph, "tiff", endsWithM);
    try t.expect(found);
    std.debug.print("Starting from 'slick': ", .{});
    found = try bfs(&graph, "slick", endsWithM);
    try t.expect(!found);
}
