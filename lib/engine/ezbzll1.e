-- file ezbzll1.e
-- simplified LL1 _stream 
-- usage init to add a sequence and reset an internal index (pointer)
-- has_more() 1 if pointer is not at the end of the sequence else 0
-- has_less() 1 if pointer is not at the beginning of sequence else 0
-- next() advance pointer and return the next item in the sequence
-- look_next() return the next item in the sequence without advancing
-- back() move pointer back to the previous item in the sequence and return the item
-- recall() return the previous item in the sequence without moving the pointer
-- current() The current sequence element being pointed to by the index
-- _stream_pos() which sequence index current() will return.
-- init(sequence _stream, integer init_pos = 1) This is the squeence the 
-- 		above will use until it is reinitiallized.  **WARNING** calling init
--		will cause you to lose progress on previous _stream work.  If you need
-- 		to work on more than one steam at a time use LL1.e instead
-- free() sets the internal sequence to {} and the pointer to 0

namespace ezbzll1
include std/io.e

sequence _stream = {}
integer _stream_idx = 0
integer _stream_len = 0


public function init(sequence stream, integer init_pos = 1)
    _stream = {}
	_stream = stream
	_stream_idx = init_pos
	_stream_len = length(_stream)
	
	return 0
end function

public function free()
    _stream = {}
    _stream_idx = 0
    return 0
end function

public function stream_len()
    return _stream_len
end function

public function has_more()
    return _stream_idx < _stream_len
end function

public function stream_pos()
    return _stream_idx
end function

public function has_less()
    return _stream_idx > 1
end function

public function current()
    return _stream[_stream_idx]
end function 

public function next()
    if has_more() then
        _stream_idx += 1
        return _stream[_stream_idx]
    end if
    return 0
end function 

public function back()
    if has_less() then
        _stream_idx -= 1
        return _stream[_stream_idx]
    end if
    return 0
end function 

public function look_next()
    if (has_more()) then
        return _stream[_stream_idx + 1]
    end if
    return 0
end function

public function recall()
    if (has_less()) then
        return _stream[_stream_idx - 1]
    end if 
    return 0
end function

