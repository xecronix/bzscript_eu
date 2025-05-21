# BZScript (bzscript\_eu)

**BZScript** is an experimental interpreter framework and language runtime designed with a focus on explicit tree structures, semantic categorization, and runtime scope modeling. Written in **OpenEuphoria**, the project explores concepts like flat tokenization, AST-based scoping, and XML-based serialization.

> **Philosophy:** *Structure is meaning. Execution is depth-first. Truth lives in the tree.*

---

## 📦 Project Layout

```plaintext
lib/                  # Engine and utility modules
  └── engine/         # Core logic: tokenizer, LL1 stream, categorizer (WIP)
  └── utils/          # Logging, formatting, constants

bzscript_eu_wiki/      # Documentation, notes, and design specs
  └── notes/          # Categorization, token types, scoping
  └── waypoints/      # Daily development logs

tests/                # Manual and future automated tests
scripts/              # Sample BZScript programs
```

---

## 🚀 Features

* 🔠 **Flat tokenizer model** — converts raw source to sequential `BZToken` stream with line/column metadata
* 🌳 **Tree-based AST** — categorizer builds hierarchical token tree based on structure and operator precedence
* 📄 **BZToken ↔ XML round-trip** — ASTs can be saved, inspected, reloaded, or executed across runtimes
* 🧠 **No runtime stack needed** — scope and ancestry are embedded via `parent_ref`
* 🪵 **Modular logger** (`bzlog.e`) — supports trace/debug/info/error levels with timestamps

---

## ✅ Getting Started

### 1. Clone the repo:

```bash
git clone https://github.com/xecronix/bzscript_eu.git
cd bzscript_eu
```

### 2. Run Logger Test

```bash
eui logger-manual-test.ex
```

Outputs to `logger_test.log` with varying log levels.

### 3. View Documentation

Start with:

* `bzscript_eu_wiki/notes/notes_on_bztoken.md`
* `bzscript_eu_wiki/notes/categorizer.md`
* `bzscript_eu_wiki/docs/ll1-stream-design.md`

---

## 📚 Wiki Highlights

* **Categorization**: Understand how the meaning of tokens changes based on structural context
* **F•PEMDAS•BL**: Operator precedence system (Function, Parentheses, Exponentiation... Logic)
* **Scoping by Tree**: Variables resolve through tree ancestry — no stack required
* **Tokenizer Phase Plan**: Full breakdown of 13 tokenizer passes

---

## 🛠️ Tools and Tech

* Language: [OpenEuphoria](https://openeuphoria.org/)
* Text Encoding: UTF-8
* Test Execution: Manual scripts in `tests/`

---

## 📅 Project Status

**\[ACTIVE]** — Project is under active development. See `bzscript_eu_wiki/waypoints/` for progress logs.

Next Major Milestones:

* [ ] AST Builder validation
* [ ] XML serializer & deserializer
* [ ] Basic runtime evaluator (experimental)
* [ ] Unit tests for tokenizer and categorizer

---

## 🙏 Credits

Built by **Ronald Weidner** (@xecronix) with creative contributions from Orion (SDE).

---

## 📄 License

TBD – License will be defined after core scaffolding is complete.

---

> *"The tokenizer sees the pieces. The categorizer gives them meaning. The tree makes them real."*
