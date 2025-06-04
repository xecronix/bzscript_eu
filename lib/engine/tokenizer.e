-- tokenizer.e
include bztoken.e
include std/sequence.e
include ezbzll1.e
include ast_token.e

enum _symbol_name, _symbol_factory_str

integer line_num = 1
integer col_num = 1

sequence tokens = {}
sequence _symbols = {}
sequence _keywords = {}
sequence _paired = {}

-- this function calls the is_symbol function.
-- is symbol looks up _symbols in a map and if it's
-- found returns the index to the symbol in the map.
-- using the maps we need to build a token 
-- and add it to tokens.  Then, we need to move stream
-- index by lenght of the symbol str - 1.  So, a 1 char
-- symbol move the index by 1-1=0.  A two char symbox 2-1=1.
-- Using logic here means that if one day we have a 3 char symbol
-- the logic wont change.

function build_token_from_symbol()
    -- boiler plate for this functions so far.
    sequence buf = ""
    sequence token_start = current()
    sequence t_name = token_start[_name]
    sequence next_token = new_empty_ast_token()
    sequence t_next
    integer reduced = 0
    
    if has_more() then
        next_token = look_next()
    end if
    t_next = next_token[_name]
    -- set up done.
    
    integer symidx = is_symbol(t_name, t_next)
    sequence symbol = _symbols[symidx]
    --enum _symbol_name, _symbol_factory_str
    buf = symbol[_symbol_name]
    sequence sym_fac_str = symbol[_symbol_factory_str]
    
    for i = 1 to length(buf)-1 do
        next() -- move the index
    end for
    -- boiler plate for exiting these functions.
    if length(buf) then
        token_start[_name] = buf
        token_start[_kind] = BZKIND_ACTION
        token_start[_factory_request_str] = sym_fac_str
        -- well reduced will always be true now.  I abused the buf earlier.
        -- hmm... If I need this to have meaning i'd better fix it. 
        -- Or, if I don't, ditch it.
        reduced = 1 
    end if
    tokens = ast_list_append(tokens, token_start)
    return reduced
end function 

function build_token_from_literal_num()
    sequence buf = ""
    integer reduced = 0
    sequence token_start = current()
    integer dot_found = 0
    sequence digits = {"0","1","2","3","4","5","6","7","8","9"}
    
    if equal(token_start[_name], ".") then
        buf = "."
        next()
        dot_found = 1
    end if
    
    while 1 do
        sequence token = current()
        sequence t_name = token[_name]
        sequence next_token = new_empty_ast_token()
        sequence t_next
        if (has_more()) then
            next_token = look_next()
        end if
        t_next = next_token[_name]
        
        if equal(t_next, ".") then
            if (dot_found = 1) then
                -- this is probably an error.
                -- we should do better than just exit!!
                exit
            else
                dot_found = 1
                buf = sprintf ("%s%s", {buf, t_name})                    
            end if
        elsif find(t_name, digits) then -- we should be guarunteed at this point but.. check anyway
            buf = sprintf ("%s%s", {buf, t_name})
        end if
                    
        -- how do we get out of this loop?
        
        -- exit when the next thing is not a digit or condtionally a dot.
        if ( dot_found = 1 ) then
            -- we have a dot alredy.  whatever comes next needs to be a digit.
            if find(t_next, digits) = 0 then 
                exit
            end if
        -- dots are still allowed.  let 'em in the stream 
        -- stop if not a dot or a digit.  We'll deal with - _symbols later.
        elsif is_digit_or_dot(t_next) = 0 then
            exit 
        end if
        
        -- exit if there are no more tokens.
        if (has_more()) then
            next()
        else
            exit
        end if
    end while
    
    if length(buf) then
        token_start[_name] = "__BZ__NUMBER__"
        token_start[_kind] = BZKIND_LITERAL
        token_start[_factory_request_str] = "literal_num"
        token_start[_value] = buf
        reduced = 1
    end if
    tokens = ast_list_append(tokens, token_start)
    return reduced
end function

function build_token_from_word()
    -- boiler plate for this functions so far.
    sequence buf = ""
    sequence token_start = current()
    integer reduced = 0
    
    -- main loop
    while 1 do
        sequence token = current()
        sequence t_name = token[_name]
        sequence next_token = new_empty_ast_token()
        sequence t_next
        if (has_more()) then
            next_token = look_next()
        end if
        t_next = next_token[_name]
        -- exit when the next token is a symbol or space
        if (is_symbol(t_name, t_next)) then
            -- because we're not going to handle this token move back
            -- we couldn't use typical peek logic because the next tokens
            -- might need to be look at as a pair.
            back()
            exit
        elsif (is_whitespace(t_name)) then
            -- Because _symbols could be pairs
            -- we didn't use peek logic for spaces.
            back()
            exit
        else
            buf = sprintf("%s%s", {buf, t_name})
        end if
                        
        -- exit if there are no more tokens.
        if (has_more()) then
            next()
        else
            exit
        end if
        
    end while
    
    -- boiler plate for exiting these functions.
    if length(buf) then
        token_start[_name] = buf
        token_start[_kind] = BZKIND_ACTION
        token_start[_value] = "__WORD__"
        token_start[_factory_request_str] = "" -- NOT YET.  We still need one more pass for context.
        reduced = 1 
    end if
    tokens = ast_list_append(tokens, token_start)
    return reduced
end function

-- stip the leading and trailing backtick 
-- collapse chars to a single token
function build_token_from_literal_str()
    sequence buf = ""
    integer reduced = 0
    
    -- first strip the leading backtick by ignoring
    -- it before entering into the main loop..
    if (has_more()) then 
        -- I guess I could have validated the current 
        -- tokens was actually a backtick.  We're flying 
        -- loose and lucky now!  
        next()
    end if
    sequence t_start = current()
    
    -- main loop.  We're looking for double backticks and a closing
    -- backtick.
    while 1 do 
        sequence token = current()
        sequence t_name = sprintf("%s",token[_name])
        sequence next_token = new_empty_ast_token()
        sequence t_next 
        if has_more() then
            next_token = look_next()
        end if
        t_next = sprintf("%s",next_token[_name])
        
        if equal(t_name,"`") then
            -- we found an escaped backtick
            if equal(t_next,"`") then
                buf = sprintf("%s%s", {buf, t_name})
                next() -- consume the backtick and move on
            else
                -- found the closing backtick
                exit 
            end if
        else
            buf = sprintf("%s%s", {buf, t_name})
        end if
        
        if (has_more()) then
            next()
        else
            exit
        end if
    end while
    
    if length(buf) then
        t_start[_name] = "__BZ__STRING__"
        t_start[_kind] = BZKIND_LITERAL
        t_start[_factory_request_str] = "literal_str"
        t_start[_value] = buf
        reduced = 1
    end if
    
    tokens = ast_list_append(tokens, t_start)
    return reduced
end function

-- _symbols can be either 1 or 2 chars long.  this 
-- function will take to chars and determine if the 
-- combined chars make up a valid bzscript symbol
-- or if the the first arg is a valid bzscript symbol
-- by it's self.  If it is a bzscript symbol, it 
-- returns the index in the map used to look up _symbols.
function is_symbol(sequence char, sequence next_char)
   sequence aggstr = sprintf("%s%s", {char, next_char})
    -- look for 2 char _symbols
    integer i = 1
    while i <= length(_symbols) do
        sequence s = _symbols[i][1]
        if equal(aggstr, s) then
            return i
        end if
        i += 1
    end while
    
    -- none found. look for one char _symbols
    i = 1
    while i <= length(_symbols) do
        sequence s = _symbols[i][1]
        if equal(char, s) then
            return i
        end if
        i += 1
    end while
    return 0
end function

function is_digit_or_dot(sequence c)
    return find(c, {"0","1","2","3","4","5","6","7","8","9", "."} )
end function

-- usually, whitespace includes new lines.  But, in 
-- the tokenizer I'm dealing with newlines and spaces (or tabs)
-- separatly.  The distinction matters. Today... for now.
function is_whitespace(sequence c)
    return find(c, {" ","\t"})
end function 

function skip_comments()
    if equal(sprintf("%s%s", {current(), look_next()}), "\\") then
        while has_more() do
            sequence c = sprintf("%s", current())
                while (has_more()) do
                    c = sprintf("%s", look_next())
                    if find(c,{"\n", "\r"}) then
                        if find(c, {"\r"}) then
                            next() -- move to the windows char
                        end if
                        next() -- move to the newline char
                        line_num += 1
                        col_num = 1
                        return 1 -- comments skipped.
                    end if
                end while
        end while
    end if
    return 0 -- no comments skipped.    
end function

function print_token_stream()
    integer i = 1
    puts(1,"Dumping Token Stream to STDOUT:\n")
    while i <= length(tokens) do
        sequence token = tokens[i]
        if token[_kind] != -1 then
        -- enum _kind, _name, _line_num, _col_num, _value, _factory_request_str
            printf(1, "kind: %d name: %s line: %d col: %d value: %s factory request str: %s\n",
             {token[_kind], token[_name], token[_line_num],
             token[_col_num], token[_value], token[_factory_request_str]})
        end if
        i += 1
    end while
    return 0
end function


-- In this pass were going to collapse tokens formed
-- from individual characters into grouped word-like 
-- tokens.  {"f","u","n"} becomes {"fun}" 
-- {"$","("} becomes {"$("}
-- 
-- We also start assigning things like BZKIND_RESOLVABLE
-- BZKIND_ACTION, BZKIND_LITERAL to symbolic tokens and literals
-- Also for symbolic tokens, we can assign the factory_request_str
--
-- In the end we're trying to build a stream of tokens each look like an 
-- envelope that contains enough info about a TBzToken to make a true TBzToken
-- The "envelope" is a sequence that mirrors the constructor of a TBzToken:
-- enum _kind, _name, _line_num, _col_num, _value, _factory_request_str

function token_first_pass()
    integer made_reduction = 0
    while 1 do
        sequence token = current()
        sequence next_token = new_empty_ast_token()
        if has_more() then
            next_token = look_next()
        end if
        sequence t_name = sprintf("%s", {token[_name]})
        sequence t_next = sprintf("%s", {next_token[_name]})
        
        if is_whitespace(t_name) then
            -- we'll clean out the spaces in a final pass later.
            -- leave them in for readability for now.
            tokens = ast_list_append(tokens, token) 
        
        elsif equal("`", t_name) then
            made_reduction = build_token_from_literal_str()
         
        elsif is_digit_or_dot(t_name) then
            made_reduction = build_token_from_literal_num()
        
        elsif is_symbol(t_name, t_next) then
           made_reduction = build_token_from_symbol()
                
        else
            made_reduction = build_token_from_word()
        end if
          
        -- move the index or exit loop 

        integer more = has_more()
        if more > 0 then
            sequence t = next()
        else
            exit
        end if
    end while
    
    return 0
end function

function strip_spaces_from_stream()
    while 1 do
        sequence token = current()
        object value = token[_value]
        if equal(value, "__DELETE_ME__") = 0 then
            tokens = ast_list_append(tokens, token)
        end if
        if (has_more()) then 
            next()
        else
            exit
        end if
    end while
    
    return 0
end function

function raw_to_token()
    -- this is the first pass.  We're trying to
    -- do the following.

    -- 1. strip comments. Because they are not needed for the AST to come
    -- 2. preserve line and column numbers
    -- 3. create a stream (aka sequence) of tokens to start reducing
    
    while 1 do
        sequence c = sprintf("%s", current())
        integer error = 0
        -- 1 skip some whitespace
        if  is_whitespace(c) then
                sequence token = new_empty_ast_token()
                token[_name] = " "
                token[_line_num] = line_num
                token[_value] = "__DELETE_ME__"
                -- not really needed for the machine... but for the
                -- man, this makes things a little easier to read.
                tokens = ast_list_append(tokens, token) 
            col_num += 1
        -- 2 new lines
        elsif find(c,{"\n", "\r"}) then
            if find(c, {"\r"}) then
                next() -- move to the newline
            end if
            line_num += 1
            col_num = 1
        elsif skip_comments() then
        else
            sequence lastc = sprintf("%s",{recall()})
            if is_whitespace(lastc) or col_num = 1 then
                sequence token = new_empty_ast_token()
                token[_name] = " "
                token[_line_num] = line_num
                token[_value] = "__DELETE_ME__"
                -- not really needed for the machine... but for the
                -- man, this makes things a little easier to read.
                tokens = ast_list_append(tokens, token) 
            end if

            sequence token = new_empty_ast_token()
            token[_name] = c
            token[_line_num] = line_num
            token[_col_num] = col_num
            tokens = ast_list_append(tokens, token)
            col_num += 1
        end if
        if (has_more()) then
            next()
        else
            exit
        end if
    end while
    return 0
end function

public function make_tokens(sequence raw, sequence symbols, sequence keywords, sequence paired)
    -- let's make sure there's some data to work with AND
    -- ************
    -- !!REMEMBER!! Stream Management Rules
    -- functions start with the stream on the first significant position
    -- functions finish with the stream on the last position processed.
    -- The assumption the is the caller will advance the stream. ALWAYS

    -- this is what the language looks like
    _symbols = symbols
    _keywords = keywords
    _paired = paired
    tokens = {}

    ezbzll1:init(raw)
    if has_more() = 0 then
        return tokens
    end if
    
    -- Capture line number, strip comments, reduce excess whitespace 
    raw_to_token()
    
    -- at this point we've stripped comments.
    -- let's start grouping chars together so they have some meaning.
    -- we should only have the following "things" in the stream.  they
    -- are whitespace, literals (str and num), _symbols, 
    -- aggregate _symbols, words
    
    -- well... because we can, let's do this
    
    -- init makes a stream from a copy of tokens and sets the index back to 1
    
    ezbzll1:init(tokens)
    tokens = {}
    token_first_pass()
    
    -- time to do this dance again.
    ezbzll1:init(tokens)
    tokens = {}
    strip_spaces_from_stream()
    
    puts(1,"make_tokens: \n")
    print_token_stream() -- TODO Delete me.
    
    return tokens
end function

