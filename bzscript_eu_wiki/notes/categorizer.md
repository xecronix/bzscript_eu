# 🌳 BZScript AST Construction Phase Plan

This document defines the second phase of BZScript source processing: transforming a **flat list of `BZToken`s** into a structured **Abstract Syntax Tree (AST)**. This AST can be used for execution, optimization, or serialization to alternate runtimes.

---

## 📦 Inputs and Outputs

### ✅ Input:

* Flat list of `BZToken`s
* Each token has type: `literal`, `resolvable`, or `action`
* Each token has `factory_id`, `source_line`, `source_column`, and `tokens[]` (possibly empty)

### 📤 Output:

* Hierarchical AST tree rooted in top-level expressions
* Each node is a `BZToken` with populated `tokens[]` field forming its child nodes
* Structure reflects syntactic and semantic nesting

---

## 🧭 AST Construction Goals

1. **Preserve original source order**
2. **Enforce operator precedence and associativity**
3. **Form composite tokens for grouped expressions**
4. **Assign parent-child relationships using `tokens[]` and optional `parent_ref`**
5. **Detect scope (e.g. function blocks, conditionals)**
6. **Support future AST export and runtime portability**

---

## 🛠️ Phase Breakdown

### **Phase 1: Group Resolution**

* Identify tokens like `#(`, `$(`, `%(`, `@(` and group their content until matching `)`
* Construct a single `BZToken` of type `resolvable`, with appropriate `factory_id` (`group_number`, etc.)
* Place enclosed tokens in `tokens[]`

### **Phase 2: Function Call Construction**

* For tokens that follow a pattern like:

  ```
  [resolvable] [group_x]
  ```

  e.g., `print $(...)`, `numstr #(x+1)`
* Form a new `action` node (e.g., `call`)
* Move function name and group as child tokens into the call

### **Phase 3: Operator Precedence Resolution**

* Traverse token stream to resolve operations in correct order:

  * `^` (right-associative)
  * `*`, `/`
  * `+`, `-`
  * Comparisons: `==`, `!=`, `>`, `<`, etc.
  * Assignment `=` (rightmost binding)
* For each match:

  * Form new `action` token (e.g., `add`, `subtract`, `compare_eq`)
  * Set `tokens[]` to left and right operands
  * Replace subrange with new token

### **Phase 4: Assignment Folding**

* Detect assignment patterns like:

  ```
  [resolvable] = [expression]
  ```
* Create new `action` node (`assign`)
* Attach left and right as children

### **Phase 5: Flow Control Structuring**

* Detect block-forming keywords:

  * `if`, `elseif`, `else`, `endif`
  * `while`, `wend`
  * `fun`, `end`
* Match starts and ends, then group body tokens into `tokens[]`
* Resulting AST node is of type `action`, with `factory_id` matching the block keyword

---

## 🧠 AST Design Principles

* **Minimal types**: The AST relies only on `literal`, `resolvable`, and `action`
* **Behavior is in `factory_id`**: AST building does not interpret meaning — only structure
* **Tokens contain tokens**: The tree is recursive, formed purely from `BZToken` nesting
* **No premature evaluation**: All evaluation or reduction happens post-AST

---

## 💾 AST Serialization

ASTs can be serialized to disk for reuse:

* Format: JSON, S-expression, or a custom compact form
* Can be reloaded to bypass tokenization/categorization
* Portable across VM implementations (e.g., native interpreter, Dart runtime, etc.)

---

## ✅ Summary

1. The tokenizer produces a **flat list** of typed tokens.
2. The AST builder transforms this list into a **structured token tree**, obeying language rules.
3. AST is fully self-descriptive and does not require source code or tokenizer to be re-run.
4. This design supports future enhancements like:

   * Runtime switching
   * Debug visualization
   * Macro expansion
   * Static analysis
