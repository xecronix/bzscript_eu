-- bztklite.e
-- this is a mini scripting language a little like C

with trace
include tokenizer.e
include ezbzll1.e
include std/io.e
include std/sequence.e
include ast_token.e
include language.e

sequence _stack    = {}
sequence _symbols  = {}
sequence _keywords = {}
sequence _paired   = {}
sequence _tokens   = {}



-- Safe hint lookup function
public function token_hint(integer hint_idx)
    for i = 1 to length(value_hints) do
        if value_hints[i][1] = hint_idx then
            return value_hints[i][2]
        end if
    end for
    return ""
end function

-- TODO I'm going to want this for matching pairs
-- I'm going to want this for matching pairs
public function is_open_pair(sequence str)
    integer found = 0
    for i = 1 to length(language:paired) do
        sequence p = language:paired[i]
        if equal(p[1], str) then
            found = 1
            exit
        end if
    end for
    return found
end function 

-- I'm going to want this for matching pairs
public function is_closing_pair(sequence str)
    integer found = 0
    for i = 1 to length(language:paired) do
        sequence p = language:paired[i]
        if equal(p[2], str) then
            found = 1
            exit
        end if
    end for
    return found
end function 

function is_keyword(sequence char)
    integer i = 1
    while i <= length(_keywords) do
        sequence k = _keywords[i][_keyword_name]
        if equal(char, k) then
            return i
        end if
        i += 1
    end while
    return 0
end function

-- *Params*
-- raw_source: is used to provide context for debugging output and/or helpful user error messages.
-- tokens: are a sequence of token generically grouped and ready for meaning. see notes below.
-- symbols: all the symbols for a bztklite language
-- keywords: all the keywords for a bztklite language
-- paired: used for validation of properly open/closed blocked statements/constructs  {}, (), [].  
-- *Descr*
-- What we have now is a group of tokens that have some meaning as tokens but not meaning
-- relative to the language we're writing.  for example {"$", "first_name"} might be 2 tokens in
-- the stream... side by side.  What we want is {"$first_name"} to be known as a variable.  Other
-- such meanings are needed.  {"("} for example.  Is this a grouping for math? Are we defining a
-- function?  Maybe we're calling a function?  Eventually, an Ant worker could figure this out, but
-- we can do it now, ONCE, and save the Ant the trouble.  We'll use the token[_value] like data for
-- Ants to use.  These values could be:  "__FUN_DEF__", "__FUN_CALL__", "__MATH__" etc.  I'm sure
-- others will popup.  Hopefully, I'll remember to update this comment, but, if I don't check for
-- a sequence at the top of this file called value_hints.  I'll go make it right now.  Done.
public function group_tokens(sequence raw_source, sequence tokens, 
    sequence symbols, sequence keywords, sequence paired)
    
    _symbols = symbols
    _keywords = keywords
    _paired = paired
    _tokens = {} -- <-- not a mistake... make sure it's empty... this is what we're building.
    ezbzll1:init(tokens)
    
            
    while 1 do
        sequence token = current()
        sequence next_token = new_empty_ast_token()
        sequence prev_token = new_empty_ast_token()
        
        if (has_more()) then
            next_token = look_next()        
        end if
        
        if (length(_tokens)) then
            prev_token = _tokens[length(_tokens)]
        end if
        
        sequence token_name = token[_name] -- easy to view in debugger
        
        if equal(token[_kind], BZKIND_LITERAL) then
            -- if the token is a literal... add to _tokens
            _tokens = append(_tokens, token)            
            
        elsif find(token[_name], {"$", "#", "@"}) then
            -- else if the token is a sigil the thing that follows 
            -- is a var name. fuse and add to tokens
            token[_name] = sprintf("%s%s", {token[_name], next_token[_name]})
            _tokens = append(_tokens, token)
            next()
            
        elsif equal(token[_name], "-") then 
            -- if the thing before me is not a number, or a varible that's a number
            -- or the close of a function... then I'm a negative sign.
            if equal(prev_token[_name], "__BZ__NUMBER__" ) = 0 and
                equal(prev_token[_factory_request_str], "var_number" ) = 0  and
                equal(prev_token[_factory_request_str], "group_close" ) = 0 then 
                
                token[_factory_request_str] = "negative"
            end if
            
            _tokens = append(_tokens, token)
            
        elsif equal(token[_name], "+") then 
            -- if the thing before me is not a number, or a varible that's a number
            -- or the close of a function... then I'm a negative sign.
            if equal(prev_token[_name], "__BZ__NUMBER__" ) = 0 and
                equal(prev_token[_factory_request_str], "var_number" ) = 0  and
                equal(prev_token[_factory_request_str], "group_close" ) = 0 then 
                
                token[_factory_request_str] = "positive"
            end if
            
            _tokens = append(_tokens, token)
            
        elsif is_keyword(token[_name]) then
            integer keyword_idx = is_keyword(token[_name])
            sequence keyword_map = _keywords[keyword_idx]
            
            sequence factory_str = keyword_map[_keyword_factory_str]
            sequence hint = token_hint(_bz_keyword)
            
            token[_factory_request_str] = factory_str
            token[_value] = hint
            
            _tokens = append(_tokens, token)
            
        elsif equal(prev_token[_name], "fun") then
            -- this is a function def
            token[_value] = token_hint(_fun_def)
            token[_factory_request_str] = "fun_def"
            _tokens = append(_tokens, token)
            
        elsif equal(token[_name], "(") then
            if equal(prev_token[_value], token_hint(_bz_keyword)) or
                equal(prev_token[_value], token_hint(_fun_call))  then
                
                token[_value] = token_hint(_fun_call_group)
            elsif equal(prev_token[_value], token_hint(_fun_def)) then
                token[_value] = token_hint(_fun_def_group)
            else
                token[_value] = token_hint(_math)
            end if
        
        
            _tokens = append(_tokens, token)  
        
        elsif length(token[_factory_request_str]) then
            -- token has a factory request str add to tokens. it's a symbol.
            -- Also, this symbol is considered recognizable soley by the
            -- factory_request_str.  Any symbol that needs further clarity 
            -- should be handled above this elsif.
            --
            -- For example - might be negative or it might be minus
            -- ( might be for a function call or maybe math
            _tokens = append(_tokens, token)
            
        else
            -- user function
            token[_value] = token_hint(_fun_call)
            token[_factory_request_str] = "fun_call"
            _tokens = append(_tokens, token)
        end if
        
        if (equal(next(), 0)) then
            exit
        end if
    end while  
    
    return _tokens  
end function



function test_bztklite_e()

    sequence input = join( {"fun begin(){",
        "let #x = 0;",
        "let #y = (0 + 1);",
        "do {",
        "    #y = 0 ;",
        "    fake_fun(#x, #y);",
        "    if (#x == 5) {",
        "        print (`halfway done\\n`)            ;",
        "    } ",
        "    do {",
        "        let @counts = [#x+1, #y+1] ;",
        "        printf( `Outer Loop:                  ##\\nInner Loop: ##\\n`, @counts) ;",
        "        #y += 1;",
        "        if(#y == 5) {break        ;            } ",
        "    } ",
        "    #x += 1 ",
        "    if(#x == 10) {break;} ",
        "} ",
        "return #x;",
        "} "}, "\n")
    
--    input = join( {"fun begin(){",
--        "    let #tax = .07;",
--        "    let #cost = 10;",
--        "    let #total = #cost + #cost * #tax;",
--       "    print($total);",
--      "}"}, "\n")


    sequence tokens = make_tokens(input, symbols, keywords, paired)
    tokens = group_tokens(input, tokens, symbols, keywords, paired)
    -- sequence ast = make_ast(tokens)
    return 0
end function 

--test_bztklite_e()

