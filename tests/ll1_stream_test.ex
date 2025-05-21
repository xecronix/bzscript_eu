-- File: tests/ll1_stream_test.ex
include std/unittest.e
include std/sequence.e
include std/eumem.e
include ../lib/engine/ll1_stream.e


-- 🧪 Setup & Test Data
sequence test_tokens = {"A", "B", "C"}
atom stream = LL1:new(test_tokens)

-- 🧪 Test peek() does not move the pointer
test_equal("1. current returns first token A", "A", LL1:current(stream))
test_equal("2. peek returns second token B", "B", LL1:peek(stream))

-- 🧪 Test next() advances the pointer
test_equal("3. next returns second token", "B", LL1:next(stream))
test_equal("4. current returns second token", "B", LL1:current(stream))

-- 🧪 Test back() reverses the pointer
test_equal("5. back then next returns 'A' again", "A", LL1:back(stream))
test_equal("6. current returns second token", "A", LL1:current(stream))

-- 🧪 Test recall() gives the previous token
LL1:next(stream) -- move to B
test_equal("7. recall returns 'A'", "A", LL1:recall(stream))
test_equal("8. current returns 'B'", "B", LL1:current(stream))
test_equal("9. peek returns 'C'", "C", LL1:peek(stream))

-- 🧪 Test has_more() and has_less()  -- We should be on B
test_true("10. has_less is true", LL1:has_less(stream))
test_true("11. has_more is true", LL1:has_more(stream))

-- 🧪 Test has_less() from the start  -- We should be on B
test_equal("12. back returns 'A' The start of stream", "A", LL1:back(stream))
test_false("13. has less should be false", LL1:has_less(stream))

-- 🧪 Test has_more() from the end  -- We should be on A
test_equal("14. Test moving forward", "B", LL1:next(stream))
test_equal("15. Test moving forward", "C", LL1:next(stream))
test_false("16. has more should be false", LL1:has_more(stream))
LL1:free(stream)

-- 🧪 Edge Case: Empty stream
atom empty_stream = LL1:new({})
test_false("empty stream has more", LL1:has_more(empty_stream))
test_false("empty stream has less", LL1:has_less(empty_stream))
test_equal("next on empty stream returns 0", 0, LL1:next(empty_stream))
test_equal("peek on empty stream returns 0", 0, LL1:peek(empty_stream))
LL1:free(empty_stream)

-- Done
test_report()

