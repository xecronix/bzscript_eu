-- language.e
    
public sequence symbols = {
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
    {"&&", "logic_and"}, {"||", "logic_or"},
    {",", "delimiter"},
    {"//", "__STRIP__"},
    {"`", "__STRIP__"}, {"``", "__STRIP__"}
}

public sequence keywords = {
    {"fun", "fun"}, {"let", "let"},
    {"if", "if"}, {"else", "else"}, {"elseif", "elseif"},
    {"do", "do_loop"}, {"break", "break"}, {"continue", "continue"},
    {"return", "return"}, {"print", "print"}
}

public sequence paired = {
    {"(", {")"}},
    {"{", {"}"}},
    {"[", {"]"}}
}
