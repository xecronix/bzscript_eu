# 📘 Symbols and Keywords Reference

---

## 🔣 Symbols and Meanings

| Symbol | Meaning                  | Ant                        |
|--------|--------------------------|----------------------------|
| !      | No return value          | silent                     |
| +      | Addition or Sign         | add or positive       |
| -      | Subtraction or Sign      | subtract or negative    |
| *      | Multiplication           | multiply   |
| /      | Division                 | divide     |
| ^      | Raise to Power           | exponent   |
| (      | Math group               | group_math |
| @      | Array variable           | var_array  |
| $      | String variable          | var_string |
| %      | List variable            | var_list   |
| #      | Number variable          | var_number |
| @(     | Group Resolves to Array  | group_array| 
| $(     | Group Resolves to String | group_string| 
| %(     | Group Resolves to List   | group_list| 
| #(     | Group Resolves to Number | group_number| 
| )      | Close group              | group_close|
| ,      | Seperator                | silent   |
| //     | comment                  | <stripped during tokenization> |
| `      | Begin/end string         | <stripped during tokenization> |
| ``     | Escape tick              | <replaced during tokenization> |
| +=     | Increase number value by | increase_by|
| -=     | Decrease number value by | subtract_by|
| *=     | Multiply number value by | multiply_by|
| /=     | Divde number value by    | divide_by |
| ++     | Increase by 1            | increment|
| --     | Decrease by 1            | decrement|
| =      | Assignment               | assignment |
|==      | Is identical number value| num_compare_eq |
|>=      | Is greater or equal      | num_compare_great_eq |
|<=      | Is identical number value| num_compare_less_eq|
|!=      | Is identical number value| num_compare_not_eq |
|>       | Is greater number value  | num_compare_great|
|<       | Is less number value     | num_compare_less|
|[       | Array indexing open      | Not sure yet        |
|]       | Array index close        | Not sure yet  |
|{       | List index open          | Not sure yet |    
|]       | list index close         | Not sure yet  |
|[]      | Empty Array              | create_arr|
|{}      | Empty list               | create_list|

---

## 🗝️ Keywords and Meanings

| Keyword  | Meaning                    | Ant           |
|----------|----------------------------|---------------|
| if       | Branching conditional      | if            |
| elseif   | Branching conditional      | elseif        |
| else     | Default conditional        | else          |
| endif    | End of conditional block   | end_if        |
| when     | Conditional trigger        | when          |
| while    | Loop construct             | while         |
| wend     | End of while loop          | end_while     |
| print    | Output to console          | print         |
| fun      | Function declaration       | fun           |
| end      | End of block or function   | end_fun       |
| break    | Exit current loop          | break         |
| continue | Skip to next loop cycle    | continue      |
| strcat   | Glue 2 strings together    | strcat        |
| strf     | Insert strings into string | strf          |
| printf   | String format and print    | printf        |
| strequal | Compare string values for equality| strequal|
