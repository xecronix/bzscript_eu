-- bztklite.e
-- this is a mini scripting language a little like C

with trace
include tokenizer.e
include bztoken.e
include ezbzll1.e
include std/io.e
include std/sequence.e

sequence _stack    = {}
sequence _symbols  = {}
sequence _keywords = {}
sequence _paired   = {}
sequence _tokens   = {}

-- Strongly typed hint enums
enum _fun_call, _fun_def, _fun_call_group, _fun_def_group, _fun_user, _math, _bz_keyword
enum _keyword_name, _keyword_factory_str

-- Decoupled map: {enum, string}
sequence value_hints = {
    {_fun_call,              "__FUN_CALL__"        },
    {_fun_def,               "__FUN_DEF__"         },
    {_fun_call_group,        "__FUN_CALL_GROUP__"  },
    {_fun_def_group,           "__FUN_DEF_GROUP__"   },
    {_fun_user, "__FUN_USER__"},
    {_math,                  "__MATH__"            },
    {_bz_keyword,               "__KEYWORD__"         }
}

-- Safe hint lookup function
function token_hint(integer hint_idx)
    for i = 1 to length(value_hints) do
        if value_hints[i][1] = hint_idx then
            return value_hints[i][2]
        end if
    end for
    return ""
end function

-- TODO I'm going to want this for matching pairs
function push(sequence word)
return 1
end function 

-- TODO I'm going to want this for matching pairs
function pop()
return 1
end function

-- TODO I'm going to want this for matching pairs
function is_open_pair(sequence str)
return 1
end function 

-- TODO I'm going to want this for matching pairs
function is_closing_pair(sequence str)
return 1
end function

-- TODO I'm going to want this for matching pairs
function is_valid_closing_pair(sequence str)
return 1
end function

function is_keyword(sequence char)
  -- none found. look for one char _symbols
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

function print_token_stream()
    integer i = 1
    puts(1,"Dumping Token Stream to STDOUT:\n")
    while i <= length(_tokens) do
        sequence token = _tokens[i]
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
        sequence next_token = new_empty_envelope()
        sequence prev_token = new_empty_envelope()
        
        if (has_more()) then
            next_token = look_next()        
        end if
        
        if (has_less()) then
            prev_token = recall()        
        end if
        
        
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
            
        elsif length(token[_factory_request_str]) then
            -- token has a factory request str add to tokens. it's a symbol.
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
            _tokens = append(_tokens, token)
            
        else
            -- user function
            token[_value] = token_hint(_fun_user)
            _tokens = append(_tokens, token)
        end if
        
        if (equal(next(), 0)) then
            exit
        end if
    end while  
    
    ezbzll1:init(_tokens)
    _tokens = {} 
    
    while 1 do
        sequence token = current()
        sequence next_token = new_empty_envelope()
        sequence prev_token = new_empty_envelope()
        
        if (has_more()) then
            next_token = look_next()        
        end if
        
        if (has_less()) then
            prev_token = recall()        
        end if
        
        if equal(token[_name], "(") then
            if equal(prev_token[_value], token_hint(_bz_keyword)) or
                equal(prev_token[_value], token_hint(_fun_call)) or
                equal(prev_token[_value], token_hint(_fun_user)) then
                
                token[_value] = token_hint(_fun_call_group)
            elsif equal(prev_token[_value], token_hint(_fun_def)) then
                token[_value] = token_hint(_fun_def_group)
            else
                token[_value] = token_hint(_math)
            end if
        end if
        
        _tokens = append(_tokens, token)        
    
        if (equal(next(), 0)) then
            exit
        end if
    end while
    
    
    puts(1, "pass 2\n\n") 
    print_token_stream()
    return _tokens  
end function



function main()

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
        "    if(x == 10) {break;} ",
        "} ",
    "} "}, "\n")
    
    --input = "#x"
    
    sequence symbols = {
    {";", "expression_end"},
    {"@","var_array"}, {"$","var_string"},{"#","var_number"},
    {"(", "group_open"}, {")", "group_close"},
    {"{", "block_open"}, {"}", "block_close"},
    {"[", "array_open"}, {"]", "array_close"},
    {"+", "add"}, {"-", "subtract"}, {"*", "multiply"}, {"/", "divide"},
    {"^", "exponent"}, {"=", "assignment"},
    {"==", "num_compare_eq"}, {"!=", "num_compare_not_eq"},
    {">", "num_compare_great"}, {"<", "num_compare_less"},
    {">=", "num_compare_great_eq"}, {"<=", "num_compare_less_eq"},
    {"+=", "increase_by"}, {"-=", "subtract_by"},
    {"*=", "multiply_by"}, {"/=", "divide_by"},
    {"++", "increment"}, {"--", "decrement"},
    {",", "param_delimiter"},
    {"//", "__STRIP__"},
    {"`", "__STRIP__"}, {"``", "__STRIP__"}
}

sequence keywords = {
    {"fun", "fun"}, {"let", "let"},
    {"if", "if"}, {"else", "else"}, {"elseif", "elseif"},
    {"do", "do_loop"}, {"break", "break"}, {"continue", "continue"},
    {"return", "return"}, {"print", "print"},{"printf", "printf"}
}

sequence paired = {
    {"(", {")"}},
    {"{", {"}"}},
    {"[", {"]"}}
}

    sequence tokens = make_tokens(input, symbols, keywords, paired)
    tokens = group_tokens(input, tokens, symbols, keywords, paired)
    return 0
end function 

main()
