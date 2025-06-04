-- language.e
namespace language

-- Strongly typed hint enums
public enum _fun_call, _fun_def, _fun_call_group, _fun_def_group, _math, _bz_keyword
public enum _keyword_name, _keyword_factory_str

-- Decoupled map: {enum, string}
public sequence value_hints = {
    {_fun_call,              "__FUN_CALL__"        },
    {_fun_def,               "__FUN_DEF__"         },
    {_fun_call_group,        "__FUN_CALL_GROUP__"  },
    {_fun_def_group,         "__FUN_DEF_GROUP__"   },
    {_math,                  "__MATH__"            },
    {_bz_keyword,               "__KEYWORD__"      }
}
    
public sequence symbols = {
    {";", "expression_end"},
    {"@","var_array"}, {"$","var_string"},{"#","var_number"},
    {"(", "group_open"}, {")", "group_close"},
    {"{", "block_open"}, {"}", "block_close"},
    {"[", "sequence_open"}, {"]", "sequence_close"},
    {"+", "add"}, {"-", "subtract"}, {"*", "multiply"}, {"/", "divide"},
    {"^", "exponent"}, {"=", "assignment"},
    {"==", "num_compare_eq"}, {"!=", "num_compare_not_eq"},
    {">", "num_compare_great"}, {"<", "num_compare_less"},
    {">=", "num_compare_great_eq"}, {"<=", "num_compare_less_eq"},
    {"+=", "increase_by"}, {"-=", "subtract_by"},
    {"*=", "multiply_by"}, {"/=", "divide_by"},
    {"++", "increment"}, {"--", "decrement"},
    {"&&", "logic_and"}, {"||", "logic_or"},
    {",", "delimiter"},
    {"//", "__STRIP__"},
    {"`", "__STRIP__"}, {"``", "__STRIP__"}
}

public sequence keywords = {
    {"fun", "fun"}, {"let", "let"},
    {"if", "if"}, {"else", "else"}, {"elseif", "elseif"},
    {"do", "do_loop"}, {"break", "break"}, {"continue", "continue"},
    {"return", "return"}
}

public sequence paired = {
    {"(", ")"},
    {"{", "}"},
    {"[", "]"}
}
