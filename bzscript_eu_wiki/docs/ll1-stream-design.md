## 📄 `LL1_Stream_Design.md`


# 🧠 LL1 Stream Design (Backed by Euphoria Memory Model)

## 🧾 Source
Based on this foundational doc:
🔗 [Pass By Reference OOP Style – openeuphoria.org](https://openeuphoria.org/wiki/view/Pass%20By%20Reference%20OOP%20Style.wc)

Originally written by Ronald Weidner (Me 😂)
Reused to power the BZScript tokenizer/parser stream logic.

---

## 🧱 What is an LL1 Stream?

LL1 is a **pointer-based token stream structure** built using `eumem`, with the following goals:

- Simulate **pass-by-reference**
- Enable **pointer-safe object semantics**
- Enforce **type boundaries** via ID matching
- Support **stream navigation operations** (next, back, peek, recall)
- Be durable and memory-safe without a garbage collector

---

## 💡 Why Use It?

- **True object-like behavior** in Euphoria
- **Fast iteration** across tokenized sequences
- **Safe memory contract** (`LL1(ptr)` enforces shape)
- Zero-copy stream mutation and position tracking
- Clean separation of structure and logic

---

## 🔐 Structure

```euphoria
enum
    __TYPE__,
    LL1_INDEX,
    LL1_DATA,
    __MYSIZE__
````

Every stream is a memory-allocated boxed array containing:

* A unique ID (`LL1_ID`)
* A stream index (1-based)
* A sequence of tokens
* Structural size for validation

---

## 🔧 Public API

| Function         | Purpose                                |
| ---------------- | -------------------------------------- |
| `LL1:new()`      | Create a new stream                    |
| `LL1:next()`     | Advance and return token               |
| `LL1:current()`  | Return current token without advancing |
| `LL1:peek()`     | Look ahead (without moving)            |
| `LL1:recall()`   | Look behind (without moving)           |
| `LL1:back()`     | Move back and return prior token       |
| `LL1:has_more()` | Check if more tokens to the right      |
| `LL1:has_less()` | Check if any tokens to the left        |
| `LL1:free()`     | Manually free the stream (required)    |

---

## ⚠️ Responsibility

You, the caller, must:

* Not pass `NULL` to `LL1:free()` or any typed `LL1` function
* Manage stream lifecycle (free after use)
* Never use a pointer after freeing it

---

## ✅ Example

```euphoria
sequence tokens = {"A", "B", "C"}
atom stream = LL1:new(tokens)

? LL1:peek(stream)     -- B
? LL1:next(stream)     -- B
? LL1:recall(stream)   -- A
LL1:free(stream)
```

---

## 🧠 Insight

This pattern is flexible enough to power:

* Parsers
* Tokenizers
* Evaluators
* Even VM instruction streams

It's lightweight, memory-aware, and can evolve into a fully introspectable debug-traceable interface.

---

```

---

