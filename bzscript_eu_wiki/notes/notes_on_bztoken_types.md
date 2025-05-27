
# 🧬 BZToken Structure & Typing Model

This page defines the internal structure of a `BZToken` and outlines the core type system used during tokenization and AST construction in BZScript.

---

## 📦 BZToken Structure

```euphoria
BZToken {
    type          : atom        -- Token category (e.g., RESOVABLE, LITERAL, ACTION)
    name          : string      -- Exact characters from the source (e.g., "+", "x", "#(")
    value         : object      -- Parsed value or payload (e.g., 42, "hello", NULL)
    source_line   : integer     -- Line number in the original source
    source_column : integer     -- Column number in the original source
    tokens        : sequence    -- List of child tokens (used for composite types)
    factory_id    : string      -- Handler responsible for reducing or dispatching this token (e.g., "number_group_open")
    parent_ref    : BZToken     -- Optional back-reference to parent token (nullable)
}
````
parent_ref is a runtime-only field used for scope, navigation, and evaluation. It is never serialized.
Hierarchy is preserved through nesting (tokens[] in memory, child <token> nodes in XML).

---

### 🧾 Sample Token

```euphoria
{
    type: VAR_NUMBER,
    name: "#x",
    value: NULL, 
    source_line: <some line>,
    source_column: <some col>,
    factory_id: "var_number",
    tokens: {
        {
            type: NUMBER,
            name: "-5",
            value: -5,
            source_line: <some line>,
            source_column: <some col>,
            factory_id: "number",
            tokens: {}
        }
    }
}
```

This shows a `VAR_NUMBER` token referencing a `NUMBER` literal (`-5`) as its payload.

---

## 🧪 Type System

BZToken’s `type` field defines the structural role of the token in the AST. There are **only three root types**, which simplifies both token generation and AST traversal.

```plaintext
type
├── resolvable
├── literal
└── action
```

### 🔁 `resolvable`

Tokens that require runtime evaluation or reference resolution.

| Subtype        | Description                     |
| -------------- | ------------------------------- |
| `function`     | Callable entity                 |
| `group_num`    | Math expression group `#(...)`  |
| `group_array`  | Array-producing group `@(...)`  |
| `group_list`   | List-producing group `%(...)`   |
| `group_string` | String-producing group `$(...)` |
| `var_num`      | Number variable `#x`            |
| `var_array`    | Array variable `@arr`           |
| `var_list`     | List variable `%lst`            |
| `var_string`   | String variable `$s`            |

---

### 🧱 `literal`

Tokens that are already fully resolved and don’t require further interpretation.

| Subtype  | Description         |
| -------- | ------------------- |
| `number` | Numeric literal     |
| `string` | Quoted string value |

---

### ⚙️ `action`

Tokens that perform an operation, transformation, or dispatch during evaluation.

This includes:

* Operators (`+`, `-`, `*`, `=`)
* Group open/close markers
* Keywords with control flow behavior

---

## 🧵 Flat Token Stream Example

Consider the following source:

```euphoria
#x = -5
print $(numstr #(#x + 10))
```

The **flat token list** (as produced by the tokenizer) might look like:

```plaintext
#x      → resolvable
=       → action
-5      → literal
print   → resolvable
$(      → action
numstr  → resolvable
#(      → action
#x      → resolvable
+       → action
10      → literal
)       → action
)       → action
```

---

## 🧠 Design Clarification

This design assumes:

* The **tokenizer does not construct the AST**, but instead produces a **flat list** of `BZToken` objects.
* **Structure** (such as grouping, precedence, and parent-child relationships) is handled in a **second pass**, possibly by an AST builder or dispatcher.
* The token's `factory_id` defines **what logic (Ant)** should process that token — it's **behavioral**, not structural.

---

## ✅ Conclusion

* **Only 3 top-level types** are needed for AST construction: `resolvable`, `literal`, and `action`.
* All other semantic behavior is attached via `factory_id`, not `type`.
* A **flat token list** is still the correct approach for your tokenizer. It keeps structure simple and defers complexity to the parsing/reduction stage.
* You’re building a language where **structure is declarative** and **meaning is procedural** — a powerful and clean design.

