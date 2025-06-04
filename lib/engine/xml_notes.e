-- ast_to_xml.e
-- Exports an AST token and its children to XML

public function ast_to_xml(TAstToken token)
    sequence s = ""
    s &= "<?xml version=\"1.0\"?>\n"
    s &= internal_ast_to_xml(token, 0)
    return s
end function

function indent(integer level)
    return repeat(' ', level * 2)
end function

function escape_text(object value)
    if atom(value) and value = NULL then
        return ""
    elsif sequence(value) then
        return value
    else
        return sprintf("%s", {value})
    end if
end function

function internal_ast_to_xml(TAstToken token, integer level)
    sequence s = ""
    sequence pad = indent(level)

    s &= pad & sprintf("<ast kind=\"%d\" name=\"%s\" line=\"%d\" col=\"%d\" factory=\"%s\">\n", {
        token[_kind],
        escape_text(token[_name]),
        token[_line_num],
        token[_col_num],
        escape_text(token[_factory_request_str])
    })

    s &= indent(level+1) & sprintf("<value><![CDATA[%s]]></value>\n", {
        escape_text(token[_value])
    })

    s &= indent(level+1) & "<children>\n"
    if sequence(token[_ast_tokens]) then
        for i = 1 to length(token[_ast_tokens]) do
            s &= internal_ast_to_xml(token[_ast_tokens][i], level + 2)
        end for
    end if
    s &= indent(level+1) & "</children>\n"

    s &= pad & "</ast>\n"
    return s
end function


-- Deserialize XML into an AST token tree
public function xml_to_ast_token(sequence xml)
    sequence parsed = parse_xml(xml)
    return build_ast_from_node(parsed[2])
end function

-- Internal recursive helper
function build_ast_from_node(sequence node)
    TAstToken token = repeat(NULL, __MYSIZE__)

    token[_kind] = to_number(node[2]["kind"])
    token[_line_num] = to_number(node[2]["line"])
    token[_col_num] = to_number(node[2]["col"])
    token[_factory_request_str] = node[2]["factory"]

    for i = 1 to length(node[3]) do
        sequence child = node[3][i]
        if child[1] = "name" then
            token[_name] = child[3]
        elsif child[1] = "value" then
            token[_value] = child[3]
        elsif child[1] = "tokens" then
            sequence subnodes = child[3]
            for j = 1 to length(subnodes) do
                token[_ast_tokens] &= build_ast_from_node(subnodes[j])
            end for
        end if
    end for

    return token
end function

