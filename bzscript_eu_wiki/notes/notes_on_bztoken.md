Here's a clean, consolidated spec for `BZToken` based on your memory (and enhancements we've discussed over time):

---

## 🧾 **`BZToken` Specification (v1)**

```plaintext
BZToken {
    type          : atom        -- Token category (e.g., NUMBER, IDENTIFIER, OPERATOR, GROUP)
    name          : string      -- Exact characters from the source (e.g., "+", "x", "#(")
    value         : object      -- Parsed value or payload (e.g., 42, "hello", NULL)
    source_line   : integer     -- Line number in the original source
    source_column : integer     -- Column number in the original source
    tokens        : sequence    -- List of child tokens (used for composite types)
    factory_id    : string      -- Handler responsible for reducing or dispatching this token (e.g., "number_group_open")
    parent_ref    : BZToken     -- Optional back-reference to parent token (nullable)
}

```

## 🧱 Example Token Instances

### 📌 A simple number:

```euphoria
{
    type: NUMBER,
    name: "literal_number",
    value: 42,
    source_line: 3,
    source_column: 12,
    tokens: {}
}
```

---

### ➕ An operator:

```euphoria
{
    type: OPERATOR,
    name: "+",
    value: NULL,
    source_line: 3,
    source_column: 14,
    tokens: {}
}
```

---

### 🧮 A composite number (e.g., "-5.7")

```euphoria
{
    type: NUMBER,
    name: "composite_number",
    value: -5.7,
    source_line: 4,
    source_column: 7,
    tokens: {
        { type: SIGN, name: "-", value: -1 },
        { type: DIGITS, name: "57", value: 57 },
        { type: DECIMAL, name: ".", value: 1 } -- one decimal digit
    }
}
```

---

## 💡 Suggestions for v2

If you keep evolving `BZToken`, here's what you might later consider adding:

* `token_id` or `uuid` (for debugging references)
* `parent_ref` (optional, for AST linkage)
* `origin` enum (e.g., user\_input, macro\_expansion, auto\_generated)
* `evaluated` boolean (whether it's been reduced/processed)

---

Let me know if you want this spec formalized in a `.md`, `.json`, or `euphoria` type format.
