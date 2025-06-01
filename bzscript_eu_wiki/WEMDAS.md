# 🧠 WEMDAS – BZScript Operator Precedence Model

## 📜 Definition

**WEMDAS** is BZScript's custom operator precedence model, inspired by PEMDAS, but tailored for a sapient-friendly parse engine.

```
W – Wrapping (parentheses or other grouping)
E – Evaluation (truth resolution, assignments)
M – Multiply / Divide
D – Divide (used symbolically, overlaps with M)
A – Add / Subtract
S – Symbol operations (and/or/not, bitwise, comparisons)
```

## 💡 Core Philosophy

- **Grouping comes first.**  
  Wrapping constructs like `(` are explicitly retained as tokens (`node_open`) to encode semantic hints about structure — e.g., math group vs function call.

- **Evaluation isn't just assignment.**  
  WEMDAS treats `=` and logical comparisons (==, !=) as part of evaluation logic, often processed **after** wrapping but **before** core arithmetic.

- **Multiply/Divide precedence matches conventional math**, but without conflating logic and arithmetic.

- **Symbol operators (S)** sit at the lowest level — things like `and`, `or`, `==`, `<`, `>=`, etc., often requiring left/right node resolution first.

---

## 🧪 Example Breakdown

Expression:
```bz
#a = (1 + 2) + (3 * (4 + #b) + #c)
```

### Step-by-step Resolution:
```
1. W: Grouping nodes identified → (1 + 2), (4 + #b), (3 * ...), etc.
2. E: = assignment binds #a to the expression
3. M/D: * resolved before surrounding +’s
4. A: + operations resolved once operands known
5. S: No logical symbols here, but this is where they'd be processed last
```

### Resulting Tree Fragment (Simplified):
```
=
├── #a
└── +
    ├── node (1 + 2)
    └── node (3 * node(4 + #b) + #c)
```

---

## 📘 Notes

- **WEMDAS is enforced in `op_group` + `op_*` family.**
- Designed for **predictability**, **pattern-based parsing**, and **reduction-friendly recursion**.
- May evolve as new token types (e.g., array access, function call, ternary) are introduced.

---

## 🛠️ Status

✅ Implemented  
🧪 Tested on deeply nested expressions  
🔒 Safety checks pending  
📦 Formal grammar in progress (see `language.e`)

## 🌀 Grouping Without a Stack – A Unique BZScript Innovation

Most languages and parsers resolve parentheses, brackets, and other group structures using a **stack-based** model:

- Push on open
- Pop on close
- Hope everything matches up

BZScript takes a different route — one that's more **data-oriented**, **tree-conscious**, and **debuggable**.

---

### ❌ The Traditional Way: Stack-Based Nesting

While efficient, stack-based grouping is:
- Rigid
- Implicit
- Often hard to introspect or repair mid-flight

It doesn't expose much metadata, and error recovery can be painful once the stack's been poisoned.

---

### ✅ The BZ Way: Token-Driven Tree Construction

Instead of pushing/popping tokens, BZScript builds **explicit `group_open` nodes** directly into the AST stream. Each opening token (`(`, `[`, etc.) becomes a **node token** with children. As the stream is walked:

- Tokens are **attached as children** to their owning group
- Closing tokens are **discarded once group resolution completes**
- Groups self-reduce to **semantic nodes** (math, array, function, etc.)

This means the parse tree is always:
- **Transparent** — every group is a node, even mid-resolution
- **Recoverable** — you can inspect and modify it on the fly
- **Extensible** — other group types (e.g. delimiters, list unpacking) can fit into the same model

---

### 🧬 Why It Matters

This model unlocks things that traditional stacks struggle with:
- Hybrid parsing/evaluation (e.g., reduce while you walk)
- Visual debugging (groupings show up as tree branches)
- AST patching and delayed resolution
- Meaningful error reporting tied to actual token nodes

This isn’t just about nesting. It’s about **making the invisible structure visible** — and giving it a role in the reduction flow.

---

### 🔍 In Code

See:
- `op_group` in `ast.e`
- Token metadata like `kind: node_open` from `tokenizer.e`
- Child resolution helpers (`child_on_left`, `child_on_both_sides`, etc.)

---

### 🛠️ Status

- ✅ Stable for `()`
- 🔜 Future: `[]`, `{}`, function calls, list literals
- 🧪 Extensible into other syntax forms (e.g., ternary, pipe, filter expressions)


---

## 🔍 Comparison: Traditional Stack vs BZ Group Nodes

### 🧠 Stack-Based Grouping (Traditional)

```
Input:
  #a = (1 + (2 * 3))

Stack Walk:
  [      ← push (
  +      ← nothing (accumulate)
  [      ← push (
  *      ← nothing
  ]      ← pop (resolve 2 * 3)
  ]      ← pop (resolve 1 + result)

Final Tree (built at pop-time):
  =
  ├── #a
  └── +
      ├── 1
      └── *
          ├── 2
          └── 3
```

**Pros:** fast, memory-efficient  
**Cons:** opaque mid-way, poor error recovery, limited metadata

---

### 🧠 BZScript Group-Node Parsing (No Stack)

```
Input:
  #a = (1 + (2 * 3))

AST Walk:
  group_open(
    add
      ├── literal 1
      └── group_open(
            multiply
              ├── literal 2
              └── literal 3
          )
  )

Final Tree (always visible mid-walk):
  =
  ├── #a
  └── group_open
      └── +
          ├── 1
          └── group_open
              └── *
                  ├── 2
                  └── 3
```

**Pros:**
- Every open group is a node — not just syntax, but data
- Groups can carry metadata (e.g., math, function, array)
- Mid-walk introspection is easy
- Easy to add behavior like `group.reduce()` or `group.patch()`

**Cons:** Slightly more memory per group (token nodes are heavier than stack markers)

---

📌 **In BZScript, grouping is not just structural — it’s semantic.**
The parentheses aren’t just markers, they’re **typed containers** in the tree, ready for introspection, transformation, or reduction.

---

## 🧠 Deep Nesting: Stack vs BZScript Comparison

### Input
```text
#a = ((((#x + 1) * 2) - ((3 / (#y + 4)) + 5)))
```

---

### 📦 Traditional Stack Parser

**Approach:** Push/pop with reduction at close

```
=
├── #a
└── -
    ├── *
    │   ├── +
    │   │   ├── #x
    │   │   └── 1
    │   └── 2
    └── +
        ├── /
        │   ├── 3
        │   └── +
        │       ├── #y
        │       └── 4
        └── 5
```

**Note:** This tree is only visible after the final closing paren. Mid-walk state is opaque and error-prone.

---

### 🌿 BZScript Group-Node Parser (No Stack)

**Approach:** Groupings are typed `node_open` tokens with children

```
=
├── #n
└── node_open
    └── node_open
        └── -
            ├── node_open
            │   └── *
            │       ├── node_open
            │       │   └── +
            │       │       ├── #x
            │       │       └── 1
            │       └── 2
            └── node_open
                └── +
                    ├── node_open
                    │   └── /
                    │       ├── 3
                    │       └── node_open
                    │           └── +
                    │               ├── #y
                    │               └── 4
                    └── 5
```

**Highlights:**
- Each `node_open` corresponds to a parenthesis group
- Walkable at all stages of parsing
- Self-contained groups with reduction metadata
- Behavior can differ based on group type (`math`, `function`, `array`...)

---

### 🔧 Implementation Insight

> Grouping in BZScript isn’t syntactic sugar — it’s **structure with behavior**.  
Each group node knows *why it exists*, what kind it is, and how to reduce itself.  
No stack needed. No invisible state. Just token trees — all the way down.

# 🧩 Addendum: Flattening WEMDAS Group Nodes

## Background

The current AST generated by the WEMDAS engine includes explicit `node_open` tokens for each group in the original expression. These tokens preserve metadata about the original structure, making it possible to:

* Distinguish between group types (e.g., math group vs. array vs. function)
* Control operator precedence through nested structures
* Maintain a traceable structure for debugging, analysis, or educational tools

However, some downstream consumers (e.g., visualizers, optimizers, or interpreters) may prefer a flattened tree where those intermediate nodes are removed once no longer necessary.

---

## ✂️ Flattening Strategy

The goal of flattening is to:

* **Eliminate `node_open` tokens** that merely wrap a single child or a reducible subexpression
* **Promote their child nodes** into the parent AST level

This is purely optional and can be performed as a **post-pass transformation** on the AST.

### Pseudocode Example

```euphoria
function collapse_group_nodes(TAstToken token)
    if token.kind = NODE_OPEN then
        if length(token.children) = 1 then
            return collapse_group_nodes(token.children[1])
        else
            for i = 1 to length(token.children) do
                token.children[i] = collapse_group_nodes(token.children[i])
            end for
        return token
    elsif token.children != {} then
        for i = 1 to length(token.children) do
            token.children[i] = collapse_group_nodes(token.children[i])
        end for
    end if
    return token
end function
```

---

## 🧠 Why Keep the Original Nodes?

You may want to **retain `node_open` tokens** if:

* You want **full fidelity** to the source expression for rendering or export
* You’re performing **symbolic manipulation**, where group type matters
* You need **explicit boundaries** for precedence during later transforms

Flattening is best reserved for final stages of compilation or interpretation, not during parsing.

---

## ✅ Summary

* WEMDAS is designed to preserve structural intent via `node_open`
* Flattening is optional, safe, and context-sensitive
* A well-isolated post-pass transformer gives you the best of both:

  * Full precision during parsing
  * Simplified form when needed

> "Structure first. Meaning second. Code last." – WEMDAS Philosophy




