Perfect — and here's your clarified version, cleanly structured for the wiki:

---

## 🧠 **AST Construction Rule Set — Final Clarification**

No more voodoo. Just rules.

---

### 🔁 **Expression Boundaries**

An **expression** is:

```text
Everything from the start of a block **up to the next `;`**
```

> (Or, equivalently: from one `;` to the next — if you’re scanning sequentially.)

---

### 🌿 **Token Roles in AST**

| Token Type                           | AST Role                             |
| ------------------------------------ | ------------------------------------ |
| Variable                             | **Leaf**                             |
| Literal                              | **Leaf**                             |
| Open Pair `(` `{` `[`                | **Parent**                           |
| Close Pair `)` `}` `]`               | **Sibling** to open or **skipped**   |
| Semicolon `;`                        | **Starts a new block-level sibling** |
| All else (operators, keywords, etc.) | **Parent**                           |

---

### 🔠 **AST Construction Logic (Per Expression)**

1. **Start a new AST fragment** at the beginning of the expression
2. **Apply precedence rules in reverse** (F•PEMDAS•BL) to determine parent hierarchy
3. **Construct parents bottom-up**, so **lowest-precedence ops are highest in the tree**
4. **Add variables/literals as children**
5. **Treat closing pairs as siblings to their opener** (or skip them)
6. **When `;` is hit**, seal the expression and move to the next

---

### 🧾 **Result**

You get a **clean, deterministic, and navigable AST**.
No AST hints required. Just structure and precedence.

> **“Create parents in reverse PEMDAS order — and that’s what it means to be an AST tree.”**

---

Ready to drop this into the wiki, captain.
