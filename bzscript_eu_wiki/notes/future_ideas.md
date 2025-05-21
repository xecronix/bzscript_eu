
---

# 🚀 BZScript Vision: General Purpose Language Readiness

As BZScript evolves, it's worth capturing the foundational decisions and future-facing ideas that can support scaling into a general-purpose programming language.

---

## 🧠 Guiding Principles

- **Predictable over permissive**: BZScript favors clarity and consistency over magical behavior.
- **Developer responsibility is intentional**: Mistakes aren't "corrected" by the parser — they're made test-visible.
- **Minimal surface, maximal expression**: Simplicity now enables evolution later.

---

## 🔍 Debugging and Developer Ecosystem

If BZScript ever reaches the general-purpose tier, it **must offer a better developer experience** than many early interpreters (like early Python, Lua, or Euphoria).

### 🛠 Future Debugger Features:
- `step`, `step into`, `step over`
- Watch variable scopes
- Breakpoints (inline or via `debug_here()` call)
- Stack introspection (what function am I in?)
- Optional trace logs with color-coded VM context

**Because you're building your own interpreter**, these features can be implemented *from within* by inspecting the token stream, call stack, and memory model.

---

## 💾 AST Caching & Persistence

Parsing source files every run is inefficient when most files don't change.

### ✅ Idea: Save the AST to disk

- After parsing, write the AST to a `.bzast` file
- Store alongside the source file
- Include a hash of the original file (MD5/SHA1)
- On next run:
  - If source file hasn’t changed → load the AST
  - Else → re-parse and overwrite the cached AST

### 🔁 Benefits:
- Faster cold starts and test cycles
- Enables static analysis without re-parsing
- Sets up potential for partial compilation or JIT interpretation
- Opens the door to tools like:
  - `bz_inspect file.bzast`
  - `bz_ast_diff old.bzast new.bzast`

---

## 🧱 Long-Term Ecosystem Architecture

| Feature         | Direction                          |
|-----------------|-------------------------------------|
| Debugging       | Built into the interpreter loop     |
| AST persistence | Enabled by default in dev mode      |
| Profiling       | Attach timing to each Ant dispatch  |
| Dev tools       | Powered by BuilderZebra or CLI APIs |

---

## 📌 Current Focus

This vision is **on hold until the tokenizer is complete**.  
Tokenizer is **the foundation of the entire stack**, and all future phases (categorization, grouping, AST, reduction, eval) depend on it.

Once the tokenizer is working, we'll revisit:
- `serialize_ast()`
- `debug_step()`
- `persist_ast(filename)`
- `load_ast_if_valid(filename)`

---

> BZScript isn’t just a language — it’s a forge for ideas.  
> Keep it predictable. Make it testable. And build the kind of dev tools you always wished you had.


---
