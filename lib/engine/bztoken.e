-- bztoken.e

namespace bztoken
include std/sequence.e
include std/io.e
include std/console.e
include std/error.e

-- internal storage
sequence _bz_tokens = {}
integer _token_count = 0


-- token field indexes
constant
    _kind                = 1,
    _name                = 2,
    _source_line_num     = 3,
    _source_col_num      = 4,
    _value               = 5,
    _tokens              = 6,
    _factory_request_str = 7,
    _token_id            = 8,
    _ant_factory_ref     = 9,
    _ant_ref             = 10,
    _parent_ref          = 11

constant NULL = 0
-- kind enums
public constant
    BZKIND_RESOLVABLE = 1024,
    BZKIND_LITERAL    = 1025,
    BZKIND_ACTION     = 1026

public function new(integer kind, sequence name, integer line, integer col, 
                    object value, sequence factory_request_str)
    _token_count += 1
    sequence token = {
        kind,
        name,
        line,
        col,
        value,
        {}, -- child tokens
        factory_request_str,
        _token_count,
        0, -- ant_factory
        0, -- ant_ref
        0  -- parent_ref
    }
    _bz_tokens &= {token}
    return _token_count -- token ID
end function

public function get(integer id, integer field)
    return _bz_tokens[id][field]
end function

public procedure set(integer id, integer field, object val)
    _bz_tokens[id][field] = val
end procedure

public function get_id(integer id)
    return get(id, _token_id)
end function

public function get_kind(integer id)
    return get(id, _kind)
end function

public function get_children(integer id)
    return get(id, _tokens)
end function

public function get_parent_ref(integer id)
    return get(id, _parent_ref)
end function

public function to_xml(integer me)
    sequence s = ""

    -- Add XML header
    s &= "<?xml version=\"1.0\"?>\n"

    -- Then append the token tree
    s &= internal_to_xml(me)

    return s
end function

-- Private recursive helper
function internal_to_xml(integer me)
    sequence s = ""

    s &= sprintf("<bztoken kind=\"%d\" source_line=\"%d\" source_col=\"%d\" factory=\"%s\" id=\"%d\">\n", {
        _bz_tokens[me][_kind],
        _bz_tokens[me][_source_line_num],
        _bz_tokens[me][_source_col_num],
        _bz_tokens[me][_factory_request_str],
        _bz_tokens[me][_token_id]
    })

    s &= sprintf("  <name><![CDATA[%s]]></name>\n", { _bz_tokens[me][_name] })

    object val = _bz_tokens[me][_value]
    if atom(val) and val = NULL then
        s &= "  <value />\n"
    else
        s &= sprintf("  <value><![CDATA[%s]]></value>\n", { val })
    end if

    s &= "  <tokens>\n"
    sequence children = _bz_tokens[me][_tokens]
    for i = 1 to length(children) do
        s &= internal_to_xml(children[i])
    end for
    s &= "  </tokens>\n"

    s &= "</bztoken>\n"
    return s
end function

public procedure free(integer id)
    sequence kids = get_children(id)
    for i = 1 to length(kids) do
        free(kids[i])
    end for
    _bz_tokens[id] = repeat(0, 11)
end procedure

public function add_new(integer parent_id, integer kind, sequence name, integer line, integer col, object value, sequence factory_request_str)
    integer child_id = new(kind, name, line, col, value, factory_request_str)
    set(child_id, _parent_ref, parent_id)

    sequence kids = get_children(parent_id)
    kids &= {child_id}
    set(parent_id, _tokens, kids)

    return child_id
end function
