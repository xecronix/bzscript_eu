# 🧠 BZScript Tokenizer Phase Plan

The goal of the tokenizer is to transform raw source code into a 
**flat stream of `BZToken`s**, where each token includes 
positional data, symbolic identity, and preparation for functional 
routing.

---

## ✅ Tokenizer Phases

### **Operation 1: Seed Characters**
- Split every character into a single `BZToken`
- Each token captures:
  - `line` and `column` position
  - `name` = character
  - `functionId` = `_BZ_NULL_`
- Spacing is preserved

---

### **Operation 2: Combine 2-Char Tokens**
- Look at each token and the one to its right:
  - If the combined characters form a valid 2-character token (e.g., `==`, `!=`, `<=`):
    - Append the right token’s name to the left
    - Update the left token with the combined name
    - Skip the next token
  - Else, copy the token as-is to the new stream
- 🔁 This phase **preserves line/column metadata**
- ⚠️ Leave `_BZ_NULL_` tokens in the stream
- 🔧 Special Rule: Replace ` with __BZ_BACKTICK__ for string processing later

---

### **Operation 3: Strip Comments**
- Detect comment tokens (e.g., `--`)
- Replace entire comment section with a single `__BZ_NULL__` token

---

### **Operation 4: Gather Digits**
- Combine adjacent digit tokens into literal number tokens

---

### **Operation 5: Handle Unary Operators**
- Recognize cases like `-5` or `+x`
- Distinguish unary from binary using token context
- numbers are represented by a single token.  every token has the 
- ability to have multiple parts.  

---

### **Operation 6: Handle Decimal Points**
- Merge sequences like `5 . 2` into `5.2`
- Requires left and right tokens to be numeric

---

### **Operation 7: Assign Symbol Function IDs**
- Tokens like `+`, `-`, `*`, `=`, `(`, `)` are mapped to their internal `functionId`s
- Example: `"+"` → `_BZ_ADD_`

---

### **Operation 8: Handle Literal Strings**
- Group backtick-enclosed content into a single token:
  - Start: `` ` ``
  - End: `` ` ``
  - Double backticks are treated as literal backticks via `__BZ_BACKTICK__`

---

### **Operation 9: Gather Words**
- Merge alphabetic character runs into word tokens
- Example: `p r i n t` → `"print"`

---

### **Operation 10: Identify Variable Names**
- If a token appears **after** a sigil (`$`, `%`, `@`, `#`), mark it as a variable
- Update `functionId` accordingly

---

### **Operation 11: Identify Function Calls**
- Remaining unclassified words:
  - If matched to an Ant, assign its `functionId`
  - If unknown, default to `call`

---

### **Operation 12: Strip Whitespace**
- Remove remaining `_BZ_NULL_` tokens
- Whitespace and comments are no longer needed

---

### **Operation 13: Final Sanity Pass**
- Confirm all tokens now have:
  - A valid `type`
  - A valid `functionId`
  - No placeholders like `__BZ_BACKTICK__` or `__BZ_NULL__`

---

## 🚀 Final Result

You now have a **clean, fully typed token stream**  
→ Ready for categorization  
→ Ready for grouping  
→ Ready to build the AST

---
