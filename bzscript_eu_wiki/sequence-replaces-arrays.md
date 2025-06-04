# 🧬 BZScript Sequences (Formerly "Arrays")

### 📜 Terminology Update
As of `2025-06-02`, all prior references to **arrays** (`@var`) in BZScript 
are officially renamed to **sequences**. This change better reflects the 
intended behavior and structure of these constructs:

---

### ✅ Why "Sequence"?

| Aspect          | Old Term: Array        | New Term: Sequence                   |
|-----------------|------------------------|--------------------------------------|
| Structure       | Fixed-size, static     | Dynamic, resizable                   |
| Access Pattern  | Index-only             | Index + possible pattern-matching    |
| Typing          | Homogeneous (expected) | Heterogeneous (allowed)              |
| Semantics       | Low-level              | High-level abstraction               |
| Language Model  | C-style array          | Euphoria-style sequence              |

---

### 📌 Implications
- Tokens formerly using `factory_request_str: array_group` should be renamed to `sequence_group`.
- Any `@var` token represents a **sequence**, not a traditional array.
- Future C implementations will treat sequences as managed memory blocks or dynamic structs.
- AST construction, traversal, and optimization routines should reflect this terminology going forward.

---

### 🧠 Design Note
This is an homage to **Euphoria**, a language that deeply influenced BZScript’s core 
design — especially around dynamic typing, sequences, and memory simplification.

> “Everything is a sequence, and all sequences are flexible.” — BZScript Design Philosophy

---
# 🧠 Waypoint: Recursive Group Handling with Branching

## 🎯 Summary
BZScript has reached a pivotal evolution point in its parser design:

We are about to introduce **recursive group processing** with **contextual branching** — a form of structured recursion where **each group type (math or sequence)** gets its own processing logic, and the system **recursively re-enters itself** while managing stream state and boundaries.

---

## 🔁 Core Functions

| Function      | Purpose |
|---------------|---------|
| `op_group()`   | Master controller: scans tokens, detects group boundaries, and dispatches subroutines. |
| `op_math()`    | Handles math expressions (parentheses). Must **return a single node**. |
| `op_sequence()`| Handles sequences (lists, params, arrays). Also returns a **single node**. |

Each function must **consume the full slice** of the group tokens, including open/close symbols, and **not return until fully reduced**.

---

## 🔀 Branching Flow

1. **`op_group()`**  
   - Loop through tokens
   - When a group opener is found, check its `factory_request_str`
   - Dispatch to:
     - `op_math()` if math group
     - `op_sequence()` if list/sequence group

2. **Recursive Reentry**  
   - During reduction inside `op_math()` or `op_sequence()`, `op_group()` may be invoked again.
   - These nested calls must **respect stream slicing boundaries** and **not pollute the outer state**.

3. **Stream Injection**  
   - When done, both subroutines return a **fully reduced AST token**, which `op_group()` inserts back into its current processing list.

---

## 🧠 Mental Model: “Group as Dispatch Node”
- A group token is a **routing signal**, not just a container.
- You’re designing a **routing table of parsing intentions** based on metadata.

---

## 🧪 Gotchas to Watch For
- **Stream boundaries**: Ensure that subgroups do not leak into their parents.
- **Expression resets**: `parse_expression()` will clobber working memory if not isolated.
- **Token reprocessing**: Once a token is reduced to an AST node, ensure it cannot be reprocessed accidentally.
- **Error clarity**: Consider trapping mismatched group ends early (this will save future pain).

---

## ✅ Next Steps
1. Refactor `op_math()` from `op_group()`
2. Implement `op_sequence()` based on `make_ast_loop()` + `block_close()` logic
3. Add branch triggers to `op_group()`
4. Harden stream slicing and injection
5. Test with edge cases like:
   - `[#x, (1+2) *#x, #y]`
   - `f(#a, #b+2, [#c])`

---

> “Once you can recursively walk a tree by intention, not just by shape, you’re writing a language.”  
> — Orion, 2025

# 🧭 Waypoint – Final Push Stack Removal & XML Transition (2025-06-02)

## ✅ Completed
- Removed automatic push behavior from `parse_expression()`
- Refactored to **return a single AST node**
- Verified all call sites (only 2 affected):
  - Updated both to explicitly `push_stack(...)` if needed
- This completes the **transition to explicit AST result ownership**, removing reliance on global stack side-effects during expression parsing

## 💡 Architectural Impact
- All recursive or branching parsers (`op_group`, `op_sequence`, `op_math`, etc.) now:
  - Accept a list of tokens
  - Return a single reduced AST node
  - No longer mutate shared state without caller involvement
- Enables future recursive parsing stages (like `walk_tree`) with clearer contracts
- Simplifies C port — recursion will no longer need to juggle side effects across functions

## 🧱 Next Phase
### Task: Export AST to XML
- Traverse full AST
- Print tags representing node structure
- Escape text content correctly
- Ensure nesting matches actual child tree




