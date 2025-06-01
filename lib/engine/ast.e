-- file ast.e
with trace
include ezbzll1.e 
include ast_token.e  -- for the money!! This has been the target all along.
include tokenizer.e  -- for the ast_token
include bztklite.e
include std/io.e 
include std/sequence.e     
include ast_token.e
include std/pretty.e
include language.e

sequence _tokens = {}
sequence _stack = {} 
sequence _grp_stack = {}
sequence _xml = {}

enum _group, _language, _function, _sign, 
    _exponent, _multdiv, _addsub, 
    _bool, _logic, _assign, _leaf, _delimiter,
    _terminator, _ptypes
    
sequence _openers = {"group_open", "array_open"}
sequence _closers = {"group_close", "array_close"}
    
    
function pop_stack()

    sequence ast = _stack[length(_stack)]
    _stack = remove(_stack, length(_stack))
    return ast
end function     

function push_stack(TAstToken ast)
    _stack = ast_list_append(_stack,ast)
    return length(_stack)
end function

function pop_grp_stack()
    sequence ast = _grp_stack[length(_grp_stack)]
    _grp_stack = remove(_grp_stack, length(_grp_stack))
    return ast
end function     

function push_grp_stack(TAstToken ast)
    _grp_stack = ast_list_append(_grp_stack,ast)
    return 0
end function

function print_expression(sequence expression)
    sequence names = {}
    integer i = 0 
    while i < length(expression) do
        i += 1
        object t = expression[i]
        if sequence(t) and length(t) >= _name then
            names = ast_list_append(names, t[_name])
        else
            names = ast_list_append(names, "<invalid>")
        end if
    end while

    sequence line = ""
    if length(names) then
        line = join(names, " ")
    end if 
    printf(1, "Expression:\n%s\n", {line})
    return 0
end function


function child_on_left()
    TAstToken parent = current()
    -- if (has_less()) then
        parent = add_child(parent, recall())    -- flying lose here 
    -- end if
    return parent
end function 

function child_on_right()
    TAstToken parent = current()
    --if (has_more()) then
        parent = add_child(parent, look_next())   -- flying lose here  TODO ERROR CHECK
    --end if
    return parent
end function 

function child_on_both_sides()
    TAstToken parent = current()
    -- if (has_less() and has_more()) then
        parent = add_child(parent, recall())      -- flying lose here 
        parent = add_child(parent, look_next())   -- flying lose here  TODO ERROR CHECK
    --end if
     return parent
end function

function op_assign(sequence expression)
    init(expression)
    sequence new_expression = {}
    while 1 do
        TAstToken ast_token = current()
        if find(ast_token[_factory_request_str], {"assignment",
            "increase_by", "subtract_by", "multiply_by", "divide_by"}) then
            new_expression = remove(new_expression, length(new_expression))
            ast_token = child_on_both_sides()
            next()
        elsif find(ast_token[_factory_request_str], {"increment","decrement"}) then
            new_expression = remove(new_expression, length(new_expression))
            ast_token = child_on_left()
        end if
        new_expression = ast_list_append(new_expression, ast_token)

        if (has_more()) then
            next()
        else
            exit
        end if
    end while
    return new_expression
end function

function op_logic(sequence expression)
    init(expression)
    integer len = length(expression)
    sequence new_expression = {}
    integer loop_count = 0
    while 1 do
        loop_count += 1
        TAstToken ast_token = current()
        if find(ast_token[_factory_request_str], {"logic_and", "logic_or"}) then
            new_expression = remove(new_expression, length(new_expression))
            ast_token = child_on_both_sides()
            next()
        end if
        new_expression = ast_list_append(new_expression,ast_token)

        if (has_more()) then
            next()
        else
            exit
        end if
    end while
    return new_expression
end function    

function op_bool(sequence expression)
    init(expression)
    integer len = length(expression)
    sequence new_expression = {}
    integer loop_count = 0
    while 1 do
        loop_count += 1
        sequence ast_token = current()
        if find(ast_token[_factory_request_str], {"num_compare_eq", "num_compare_not_eq",
            "num_compare_great", "num_compare_less",
            "num_compare_great_eq", "num_compare_less_eq"}) then
            new_expression = remove(new_expression, length(new_expression))
            ast_token = child_on_both_sides()
            next()
        end if
        new_expression = ast_list_append(new_expression,ast_token)

        if (has_more()) then
            next()
        else
            exit
        end if
    end while
    return new_expression
end function    

function op_delimiter(sequence expression)
    init(expression)
    integer len = length(expression)
    sequence new_expression = {}
    integer loop_count = 0
    while 1 do
        loop_count += 1
        TAstToken ast_token = current()
        if find(ast_token[_factory_request_str], {"delimiter"}) then
            --drop it on the floor we dont need it anymore.
        else
            new_expression = ast_list_append(new_expression,ast_token)
            -- hopefully we'll never be here either.
        end if

        if (has_more()) then
            next()
        else
            exit
        end if
    end while
    return new_expression
end function 


-- TODO... this is dead code.. it should be removed.
function op_leaf(sequence expression)
    
    if (length(expression) = 0) then
        return expression
    end if
    
    init(expression)
    integer len = length(expression)
    sequence new_expression = {}
    
    while 1 do
        TAstToken ast_token = current()
        if find(ast_token[_factory_request_str], {"var_number", "var_string",
            "literal_num", "literal_str"}) then
            
            ---what... do nothing... why
        end if
        new_expression = ast_list_append(new_expression,ast_token)
        if (has_more()) then
            next()
        else
            exit
        end if
    end while
    puts(1, "op_leaf: new_expression\n")
    print_expression(new_expression)
    return new_expression
end function    

function op_addsub(sequence expression)
    init(expression)
    sequence new_expression = {}
    puts(1, "op_addsub:  let's see what the expression is before the crash????\n")
    print_ast_token_list(expression)
    while 1 do
        TAstToken ast_token = current()
        if find(ast_token[_factory_request_str], {"add", "subtract"}) then
            new_expression = remove(new_expression, length(new_expression))
            ast_token = child_on_both_sides()
            next()
        end if
        new_expression = ast_list_append(new_expression,ast_token)

        if (has_more()) then
            next()
        else
            exit
        end if
    end while
    return new_expression
end function    

function op_multdiv(sequence expression)
    init(expression)
    integer len = length(expression)
    sequence new_expression = {}
    while 1 do
        TAstToken ast_token = current()
        if find(ast_token[_factory_request_str], {"multiply", "divide"}) then
            new_expression = remove(new_expression, length(new_expression))
            ast_token = child_on_both_sides()
            next()
        end if
        new_expression = ast_list_append(new_expression,ast_token)

        if (has_more()) then
            next()
        else
            exit
        end if
    end while
    return new_expression
end function    

function op_exponent(sequence expression)
    init(expression)
    integer len = length(expression)
    sequence new_expression = {}
    while 1 do
        TAstToken ast_token = current()
        if find(ast_token[_factory_request_str], {"exponent"}) then
            new_expression = remove(new_expression, length(new_expression))
            ast_token = child_on_both_sides()
            next()
        end if
        new_expression = ast_list_append(new_expression,ast_token)

        if (has_more()) then
            next()
        else
            exit
        end if
    end while
    return new_expression
end function    

function op_sign(sequence expression)
    init(expression)
    sequence new_expression = {}
    while 1 do
        TAstToken ast_token = current()
        if find(ast_token[_factory_request_str], {"negative", "positive"}) then
            ast_token = child_on_right()
            next()
        end if
        new_expression = ast_list_append(new_expression,ast_token)

        if (has_more()) then
            next()
        else
            exit
        end if
    end while
    return new_expression
end function    

-- TODO
function op_function(sequence expression)
    return expression
end function    

-- TODO
function op_language(sequence expression)
    return expression
end function    

function block_open(TAstToken ast_token)
    integer len_of_stack  = push_stack(ast_token)  
    return len_of_stack
end function

function block_close(TAstToken ast_token)
    TAstToken child = pop_stack()
    TAstToken parent = pop_stack()
    parent = add_child(parent, child)
    push_stack(parent)    
    return 0
end function

-- OK... so I don't know how to do this using a stack... but I can 
-- derive a way to do this without one.  Instead of looking for opening groups... 
-- iterate over the list looking for closing groups.

-- start loop
-- start stitching together a reduced stream
-- find closing )
-- backup up and capture stream fragment to opening (
-- send stream fragment to parse
-- add parse results to reduced stream.
-- drop the closing )
-- append the rest of the original stream after ) to reduced stream
-- original stream = reduced stream
-- reduced stream = ""
-- restart process until no more reductions are made.

-- Reviewed and cleaned-up version of op_group with comments and corrections
function op_group(sequence expression)
    init(expression)
    sequence new_expression = {}
    integer restart_reduction = 0
    while  1 do
        TAstToken ast_token = current()
        restart_reduction = 0
    
        if equal(ast_token[_factory_request_str], "group_close") then
            integer close_pos = stream_pos()

            -- Rewind to the matching group_open
            integer stop = 0
            while stop = 0 do
                TAstToken t = back()
                if equal(t[_factory_request_str], "group_open") then
                    stop = 1
                    t[_factory_request_str] = "node_open"
                    new_expression[length(new_expression)] = t                    
                else
                    new_expression = remove(new_expression, length(new_expression))
                end if
            end while
            -- Capture the sub-expression between ( and )
            sequence exp_frag = {}
            integer has_delimiter = 0
            while stream_pos() < close_pos - 1 do
                exp_frag = ast_list_append(exp_frag, next())
                TAstToken frag_t = current()
                if equal(frag_t[_factory_request_str], "delimiter") then
                  has_delimiter = 1
                end if
            end while
            
            
            -- TODO: deal with commas in the stream. already detected
            -- via has_delimiter flag.
            
            _grp_stack = {}
            parse_expression(exp_frag, 1) -- mutates the LL1 stream
            init(expression, close_pos)   -- move to the ')'
            
            TAstToken reduced_token = pop_grp_stack()

            TAstToken parent = new_expression[length(new_expression)]
            parent = add_child(parent, reduced_token)
            new_expression[length(new_expression)] = parent

            -- Append remainder of the stream
            while has_more() do
                new_expression = ast_list_append(new_expression, next())
            end while
            
            restart_reduction = 1
            expression = new_expression
            new_expression = {}
            init(expression)

        else
            new_expression = ast_list_append(new_expression, ast_token)
        end if

        if has_more() then
            -- in the above loop we set continue_reduction to 1
            -- and reset the ezbzll1 stream.  the stream is already
            -- primed and ready.  don't move it.
            if restart_reduction = 0 then
                next()
            end if
        else
            exit
        end if
    end while

    return new_expression
end function

function parse_expression(sequence expression, integer is_group = 0)
--enum  _group,      _language,   _function, _sign, 
     -- _exponent,   _multdiv,    _addsub, 
     -- _bool,       _logic,      _assign,  _leaf ,
     -- _delimiter,  _terminator, _ptypes
     
     -- by the time _terminator is hit the expression should
     -- already be reduced.  This is really just a way
     -- that could be used to not fail.  We'll see if
     -- I actaully do that. I'd almost rather the failure
     -- than to keep going on in a bad or unknown state.
     -- I think I need another one of these for arrays vars.
     -- those seem like an implicite group. We'll see when
     -- I get there.

    integer prec = 1
    while prec < _ptypes do
            if prec = _group then
                expression = op_group(expression)
            elsif prec = _language then
                expression = op_language(expression)
            elsif prec = _function then
                expression = op_function(expression)
            elsif prec = _sign then
                expression = op_sign(expression)
            elsif prec = _exponent then
                expression = op_exponent(expression)
            elsif prec = _multdiv then
                expression = op_multdiv(expression)
            elsif prec = _addsub then
                expression = op_addsub(expression)
            elsif prec = _bool then
                expression = op_bool(expression)
            elsif prec = _logic then
                expression = op_logic(expression)
            elsif prec = _assign then
                expression = op_assign(expression)
            end if
        prec += 1
       
    end while
    
    if is_group then
        printf(1, "stack len = %d\n", {length(_stack)})
        push_grp_stack(expression[1])
    else
        
        sequence ast = pop_stack()
        ast = add_child(ast, expression[1])
        printf(1, "stack len = %d\n", {push_stack(ast)})
    end if

    return 0
end function

function make_ast_loop(sequence ast_tokens)
    integer i = 0
    sequence expression = {}
    while i < length(ast_tokens) do
        i += 1
        TAstToken ast_token = ast_tokens[i]
        if equal(ast_token[_factory_request_str], "block_open") then
            block_open(ast_token)
        elsif equal(ast_token[_factory_request_str], "block_close") then
            block_close(ast_token)
        elsif equal(ast_token[_factory_request_str], "expression_end") then
            parse_expression(expression)
            expression = {}
        else
            expression = ast_list_append(expression, ast_token)
        end if
    end while
    return 0
end function
    
public function make_ast(sequence ast_tokens)
    TAstToken root = new_empty_ast_token()
    root[_name] = "__ast_token_root__"
    push_stack(root)
    
    make_ast_loop(ast_tokens)
    
    return pop_stack()
end function

function test_ast_e()

    sequence tokens
    sequence ast
    sequence input
    --input = "{#y = #x ^ 5;#z = #y >= .7;#a = #b *#z;}"
    --tokens = make_tokens(input, symbols, keywords, paired)
    --tokens = group_tokens(input, tokens, symbols, keywords, paired)
    --ast = make_ast(tokens)
    --print_ast_token(ast)
    
    --input = "{#y = (5+#x) * 12000;}"
    --tokens = make_tokens(input, symbols, keywords, paired)
    --tokens = group_tokens(input, tokens, symbols, keywords, paired)
    --ast = make_ast(tokens)
    --print_ast_token(ast)
    
    --input = "{(1);}"
    --input = "{#x= (5 +7) * (#e / 6);}"
    --input = "{#x= ((222 + #x),444,777 * #y);}"
    --input = "{#a = (1 + 2)+ (3 * (4 + #b)+ #c);}"
    input ="{#n = ((((#x + 1) * 2) - ((3 / (#y + 4)) + 5)));}"
    tokens = make_tokens(input, symbols, keywords, paired)
    tokens = group_tokens(input, tokens, symbols, keywords, paired)
    ast = make_ast(tokens)
    --pretty_print(1, ast)
    printf(1, "input: \n\n%s\n\nOutput\n\n",{input})
    print_ast_token(ast)
    puts(1,"Program finish Successfully.  (Or at least it didn't crash.  :) )\n")
    return 0
end function 

test_ast_e()


