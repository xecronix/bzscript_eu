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
sequence _fun_stack = {} 
sequence _xml = {}

enum _group, _language, _function, _sign, 
    _exponent, _multdiv, _addsub, 
    _bool, _logic, _assign, _leaf, _delimiter,
    _terminator, _ptypes
    
sequence _openers = {"group_open", "sequence_open"}
sequence _closers = {"group_close", "sequence_close"}
    
    
function pop_stack()

    sequence ast = _fun_stack[length(_fun_stack)]
    _fun_stack = remove(_fun_stack, length(_fun_stack))
    return ast
end function     

function push_stack(TAstToken ast)
    _fun_stack = ast_list_append(_fun_stack,ast)
    return length(_fun_stack)
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

function op_addsub(sequence expression)
    init(expression)
    sequence new_expression = {}

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

function op_math(TAstToken parent, sequence expression)
    parent = add_child(parent, parse_expression(expression))
    return parent
end function

--TODO Important :This needs to reduce to a single node.
function op_sequence(TAstToken parent, sequence ast_tokens)
    sequence expression = {}
    -- the parent token for this node is the first token in the sequence
    integer i = 0

    while i < length(ast_tokens) do
        i += 1
        TAstToken ast_token = ast_tokens[i]
        if equal(ast_token[_factory_request_str], "group_open") then
            -- slurp up all the tokens until the closing token
            -- then call op_sequence again
            -- dont forget to bookend the sequence with matching pairs
            -- it's going to return an TAstToken.  Add it to parent.
        
        elsif equal(ast_token[_factory_request_str], "group_close") then
            -- if we have an expression to parse go ahead and do that.
            -- add the parse result to the parent
            -- the return the parent
                
        elsif equal(ast_token[_factory_request_str], "delimiter") then
            -- parse the expression we've been gathering up
            -- add the parse result to the parent
            -- set expression to {} there might be more tokens to gather up

        else
            expression = ast_list_append(expression, ast_token)
        end if
    end while
    return 0
end function

-- This reduces groups out of an expression.
function op_group(sequence expression)
    sequence new_expression = {} -- the reduced expression: the whole point if this function
    integer restart_reduction = 0
    integer i = 0
    while  i < length(expression) do
        i += 1
        TAstToken t = expression[i]
        if find(t[_factory_request_str], _openers) then
            -- at this point we know t isn't some random token
            -- it's a node opening token.  I'm tempted to rename it
            -- now.  I guess I'm overwhelmed with temptation.
            TAstToken parent = t
            parent[_factory_request_str] = "node_open"
            integer end_pos = locate_closer(expression, i)
            sequence exp_frag = {}
            
            i += 1 -- skip the opener aka parent.
            while i < end_pos do
                exp_frag = ast_list_append(exp_frag, expression[i])
                i+=1
            end while
            
            -- exp_frag should be the expression except the opening and closing
            -- token. we're not putting the open tag in there becuase we mutated
            -- it and gave it "node_open". The mutation was needed so we don't
            -- end up in an endless loop. 
            
            -- Let's find out how to route this 
            -- token is "math" or "not math" aka -> sequence
            TAstToken group
            if equal(parent[_value], token_hint(_math)) then
                group = op_math(parent, exp_frag)
            else
                group = op_sequence(parent, exp_frag)
            end if
          
            new_expression = ast_list_append(new_expression, group)
            --slurp up the rest of the expression
            -- i is setting on the closing ) of the expression we sent to the op
            -- we don't want it.
            while i < length(expression) do
                i+=1 -- on the first loop we smite the close )
                new_expression = ast_list_append(new_expression, expression[i])
            end while
            
            -- and finally... the little dance 
            -- we did some reductions, we need to start all over until
            -- there are no more reductions.
            expression = new_expression
            new_expression = {}
            i = 0            
        else
            new_expression = ast_list_append(new_expression, t)
        end if
    end while
    return new_expression
end function

function parse_expression(sequence expression)
--enum  _group,      _language,   _function, _sign, 
     -- _exponent,   _multdiv,    _addsub, 
     -- _bool,       _logic,      _assign,  _leaf ,
     -- _delimiter,  _terminator, _ptypes

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
    
    puts(1,"parse_expression: we're leaving parse_expression.  \n")
    print_ast_token(expression[1])
    
    return expression[1]
end function

function make_ast_loop(TAstToken parent, sequence ast_tokens)
    integer i = 0
    sequence expression = {}
    
    --TODO:: I'm cheating here.  I know the input
    -- will start and end with {} for now
    -- but, it wont be that way for much longer.
   
    while i < length(ast_tokens) do
        i += 1
        TAstToken ast_token = ast_tokens[i]
        if equal(ast_token[_factory_request_str], "block_open") then
            make_ast_loop(ast_token, slice(ast_tokens, 2)) -- TODO:: this needs to be smarter.  get the code between matching {}
        elsif equal(ast_token[_factory_request_str], "block_close") then
            return parent
        elsif equal(ast_token[_factory_request_str], "expression_end") then
            TAstToken reduced_t = parse_expression(expression)                                         
            parent = add_child(parent, reduced_t)
            expression = {}
        else
            expression = ast_list_append(expression, ast_token)
        end if
    end while
    return 0
end function

function find_closing_symbol(sequence open_symbol)
    sequence closing_sym = ""
    for i = 1 to length(language:paired) do
        sequence p = language:paired[i]
        if equal(p[1], open_symbol) then
            closing_sym = p[2]
            exit
        end if
    end for
    return closing_sym
end function

function locate_closer(sequence expression, integer start)
    integer pos = start
    TAstToken match_this_token = expression[pos]
    sequence open_sym = match_this_token[_name]
    sequence close_sym = find_closing_symbol(open_sym)
    
    if length(close_sym) = 0 then
        printf(1, "locate_closer: Could not find closing symbol for token:[%s] on line:[%d], col:[%d]", {open_sym,
            match_this_token[_line_num],
            match_this_token[_col_num]})
        abort(1)
    end if

    integer nest_level = 0
    integer stop = length(expression) + 1
    while pos < stop do
        TAstToken t = expression[pos] 
        sequence current_sym = t[_name]
        if equal(current_sym, open_sym) then
            nest_level+=1
        elsif equal(current_sym, close_sym) then
            nest_level-=1
        end if

        if nest_level = 0 then
            return pos
        end if
        pos += 1
    end while
    printf(1, "locate_closer: Could not find symbol. Looked for closing symbol for token:[%s] on line:[%d], col:[%d]", {open_sym,
        match_this_token[_line_num],
        match_this_token[_col_num]})
    abort(1)
    
end function
    
public function make_ast(sequence ast_tokens)
    TAstToken root = new_empty_ast_token()
    root[_name] = "__ast_token_root__"
    root = make_ast_loop(root, ast_tokens)
    return root    
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
    --input = "{(5+(3+7));}"
    --input = "{((5+(3+7)));}"
    --input ="{((((#x+1)*2)));"
    input ="{#n=((((#x+1)*2)-((3/(#y+4))+5)));}"
    tokens = make_tokens(input, symbols, keywords, paired)
    tokens = group_tokens(input, tokens, symbols, keywords, paired)
    puts(1, "Bulding AST...\n")
    ast = make_ast(tokens)
    --pretty_print(1, ast)
    printf(1, "input: \n\n%s\n\nOutput\n\n",{input})
    print_ast_token(ast)
    puts(1,"Program finish Successfully.  (Or at least it didn't crash.  :) )\n")
    return 0
end function 

test_ast_e()


