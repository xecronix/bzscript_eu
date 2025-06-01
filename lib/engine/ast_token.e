-- ast_token.e
--  
-- this is our TAstToken structure (let's hide the implementation details) 
--  
public enum  
    __TYPE__, -- must be first value in enum 
    _kind, 
    _name, 
    _line_num, 
    _col_num, 
    _value, 
    _factory_request_str, 
    _ast_tokens,
    __MYSIZE__ -- must be last value in enum 


-- Magic here is we can add remove "Properties" from our data struct 
-- Without needing remember to update this. 
public constant  
    SIZEOF_AST_TOKEN = __MYSIZE__  
 
-- 
-- ID pattern is SOME_NAME_THAT_MAKES_SENSE DOLLAR_SYMBOL SOME_RANDOM_CHARS 
--     
constant 
    AST_TOKEN_ID = "AST_TOKEN_ID$j56y7uw5tDESFWA#@$%^" 
 
constant NULL = 0  
     
-- Awesome Euphoria Feature!  Let's define what a TAstToken looks like. 
public type TAstToken (sequence s) 
    if s[__MYSIZE__] = SIZEOF_AST_TOKEN then 
        if equal(s[__TYPE__], AST_TOKEN_ID) then 
            return 1 
        end if 
    end if 
    return 0 
end type 

public function new_empty_ast_token()
    -- NOTE TO SELF: changes here might mean there were changes to the enum CHECK TOP OF CODE
    -- enum _kind, _name, _line_num, _col_num, _value, _factory_request_str
    sequence token = repeat(0, SIZEOF_AST_TOKEN)
    token[__TYPE__] = AST_TOKEN_ID
    token[_name] = ""
    token[_factory_request_str] = ""
    token[_ast_tokens] = {}
    token[__MYSIZE__] = SIZEOF_AST_TOKEN
    return token
end function

public function print_ast_token(TAstToken token, integer indent = 0)
    -- enum _kind, _name, _line_num, _col_num, _value, _factory_request_str, _ast_tokens
    --sequence indentation = repeat(" ", indent * 3)
    sequence indentation = ""
    for i = 0 to indent * 3 do
        indentation = sprintf("%s%s", {indentation, " "})
    end for
    printf(1, "%skind: %d name: %s line: %d col: %d value: %s factory request str: %s\n",
    {indentation, token[_kind], token[_name], token[_line_num],
    token[_col_num], token[_value], token[_factory_request_str]})
    indent += 1
    
    for i = 1 to length(token[_ast_tokens]) do
        sequence child = token[_ast_tokens][i]
        print_ast_token(child, indent)
    end for
    return 0
end function

public function print_ast_token_list(sequence tokens)
    for i = 1 to length(tokens) do
        print_ast_token(tokens[i])
    end for
    return 0
end function

public function ast_list_append(sequence lst, TAstToken t)
    return append(lst, t)
end function

public function add_child(TAstToken parent, TAstToken child)
    sequence children = parent[_ast_tokens]
    children = append(children, child)
    parent[_ast_tokens] = children
    return parent
end function
