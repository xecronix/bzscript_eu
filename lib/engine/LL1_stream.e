-- LL1_stream.e
namespace LL1
include std/eumem.e
include std/io.e
include std/pretty.e
include ../shared/constants.e
include ../utils/logger.e
--
-- Internal layout for LL(1) stream
--
enum
    __TYPE__,           -- must be first
    LL1_INDEX,    -- current position
    LL1_DATA,     -- full token list
    LL1_DATALEN,   -- This is so the we don't need to calculate this repeatedly 
    __MYSIZE__          -- must be last

constant LL1_ID = "LL1$T54yhwe%^%$^$@3yjhw@$%^"
constant NULL = 0

public type LL1(atom ptr)
    if eumem:valid(ptr, __MYSIZE__) then
        if equal(eumem:ram_space[ptr][__TYPE__], LL1_ID) then
            return 1
        end if
    end if
    return 0
end type

constant SIZEOF_LL1 = __MYSIZE__

--
-- Create a new LL1 token stream
--
public function new(sequence tokens)
    logger(DEBUG, "Creating a new LL1 stream")
    integer datalen = length(tokens)
    return eumem:malloc({LL1_ID, 1, tokens, datalen, SIZEOF_LL1})
end function

--
-- Get the current token and stay put.
--
public function current(LL1 ptr)
    object token = eumem:ram_space[ptr][LL1_DATA][eumem:ram_space[ptr][LL1_INDEX]]
    return token
end function

--
-- Get the next token and advance
--
public function next(LL1 ptr)
    if not has_more(ptr) then return NULL end if
    eumem:ram_space[ptr][LL1_INDEX] += 1
    object token = eumem:ram_space[ptr][LL1_DATA][eumem:ram_space[ptr][LL1_INDEX]]
    return token
end function

--
-- Peek ahead (no index change)
--
public function look_next(LL1 ptr)
    if not has_more(ptr) then return NULL end if
    integer peekIdx = eumem:ram_space[ptr][LL1_INDEX]
    peekIdx += 1
    return eumem:ram_space[ptr][LL1_DATA][peekIdx]
end function

--
-- Recall previous token (no index change)
--
public function recall(LL1 ptr)
    integer idx = eumem:ram_space[ptr][LL1_INDEX]
    if idx <= 1 then return NULL end if
    return eumem:ram_space[ptr][LL1_DATA][idx - 1]
end function

--
-- Move back one token and return it
--
public function back(LL1 ptr)
    integer idx = eumem:ram_space[ptr][LL1_INDEX]
    if idx <= 1 then return NULL end if
    eumem:ram_space[ptr][LL1_INDEX] -= 1
    return eumem:ram_space[ptr][LL1_DATA][idx - 1]
end function

--
-- Are there tokens remaining to the right?
--
public function has_more(LL1 ptr)
    return eumem:ram_space[ptr][LL1_DATALEN] > eumem:ram_space[ptr][LL1_INDEX]
end function

--
-- Are there tokens remaining to the left?
--
public function has_less(LL1 ptr)
    return eumem:ram_space[ptr][LL1_INDEX] > 1
end function

--
-- Free the LL1 stream from RAM space
--
public function free(LL1 ptr)
    logger(DEBUG, "free the LL1 parser")
    eumem:free(ptr)
    return 1
end function
