include lib/engine/bztoken.e
include std/console.e
include std/filesys.e

procedure run_test()

    -- Create a root token
    TBzToken root = bztoken:new(
        BZKIND_RESOLVABLE,
        "#x",
        1, 5,
        42,
        "assign"
    )

    -- Add a child literal token
    TBzToken child = bztoken:add_new(
        root,
        BZKIND_LITERAL,
        "5",
        1, 8,
        5,
        ""
    )

    -- Validate kind
    if bztoken:get_kind(root) != BZKIND_RESOLVABLE then
        puts(1, "Root kind mismatch\n")
    end if

    if bztoken:get_kind(child) != BZKIND_LITERAL then
        puts(1, "Child kind mismatch\n")
    end if

    -- Validate unique IDs
    if bztoken:get_id(root) = bztoken:get_id(child) then
        puts(1, "Token IDs are not unique\n")
    else
        puts(1, "Token IDs are unique\n")
    end if

    -- Dump XML
    sequence xml = bztoken:to_xml(root)
    puts(1, "Token Tree (XML):\n")
    puts(1, xml & "\n")

    -- Free memory
    bztoken:free(root)

    puts(1, "Test completed.\n")
end procedure

run_test()
