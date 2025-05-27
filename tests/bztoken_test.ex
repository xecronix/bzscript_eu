-- bztoken_test.ex (updated for sequence-based bztoken)

include std/unittest.e
include std/sequence.e
include ../lib/engine/bztoken.e

procedure test_multiple_children()
    integer root = bztoken:new(BZKIND_RESOLVABLE, "#f", 1, 1, "root", "assign")
    integer child1 = bztoken:add_new(root, BZKIND_LITERAL, "5", 1, 2, 5, "")
    integer child2 = bztoken:add_new(root, BZKIND_LITERAL, "6", 1, 3, 6, "")

    sequence kids = bztoken:get_children(root)
    test_equal("Two children added", length(kids), 2)
    test_not_equal("IDs are unique", bztoken:get_id(child1), bztoken:get_id(child2))

    -- Cleanup
    bztoken:free(root)
end procedure

procedure test_parent_pointer()
    integer root = bztoken:new(BZKIND_RESOLVABLE, "#x", 1, 1, 0, "assign")
    integer child = bztoken:add_new(root, BZKIND_LITERAL, "42", 2, 1, 42, "")
    integer parent = bztoken:get_parent_ref(child)

    test_equal("Child has correct parent", bztoken:get_id(parent), bztoken:get_id(root))

    -- Cleanup
    bztoken:free(root)
end procedure

procedure test_deep_recursion()
    integer depth = 10
    integer root = bztoken:new(BZKIND_RESOLVABLE, "root", 1, 1, 0, "group")

    integer current = root
    for i = 1 to depth do
        printf(1, "Creating depth %d\n", i)
        current = bztoken:add_new(current, BZKIND_RESOLVABLE, sprintf("node%d", i), i+1, 1, sprintf("value%d", i), "group")
    end for

    -- Traverse down to the deepest node
    integer walker = root
    integer count = 0
    while length(bztoken:get_children(walker)) > 0 do
        sequence kids = bztoken:get_children(walker)
        walker = kids[1]
        count += 1
    end while

    test_equal("Deep recursion built correctly", count, depth)

    sequence xml = bztoken:to_xml(root)
    puts(1, "Token Tree (XML):\n")
    puts(1, xml & "\n")

    -- Cleanup
    bztoken:free(root)
end procedure

-- Run all tests
test_multiple_children()
test_parent_pointer()
test_deep_recursion()
test_report()
