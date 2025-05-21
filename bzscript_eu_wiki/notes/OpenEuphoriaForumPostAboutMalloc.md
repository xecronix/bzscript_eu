
Title: LL1 Memory Pattern – Safe, Scalable Object-like Structures Using eumem

Author: Ronald Weidner

This post summarizes a design pattern discussion I had while building an LL(1) token stream structure in OpenEuphoria. The goal was to build a reusable, memory-safe, pointer-driven object without needing full OOP. The result was a fully testable, efficient, and idiomatic structure using `eumem`.



💡 Why This Pattern?

Euphoria passes everything by value. This means that without explicit handling, all state is copied, mutated in isolation, and discarded unless reassigned. To simulate pass-by-reference structures, I built a reusable LL(1) stream backed by `eumem`.

This design allows:
- Pointer-based memory
- Shared state between procedures
- Explicit free and lifecycle control
- Type-safe tagging
- Struct-like layouts



🧱 The Layout

```euphoria
enum
    __TYPE__,       -- must be first
    LL1_INDEX,      -- current stream position
    LL1_DATA,       -- sequence of tokens
    __MYSIZE__      -- must be last
````

```euphoria
constant LL1_ID = "LL1$T54yhwe%^%$^$@3yjhw@$%^"
```

Each LL1 instance is created using:

```euphoria
public function new(sequence tokens)
    return eumem:malloc({LL1_ID, 1, tokens, SIZEOF_LL1})
end function
```

And type validation is performed with:

```euphoria
public type LL1(atom ptr)
    if eumem:valid(ptr, __MYSIZE__) then
        if equal(eumem:ram_space[ptr][__TYPE__], LL1_ID) then
            return 1
        end if
    end if
    return 0
end type
```

---

✅ Safe for Multiple Instances

You **do not need** a dynamic ID. Every LL1 object shares the same `LL1_ID`. That tag is not for uniqueness — it's for **type validation**. Each call to `new()` creates a new memory block with its own pointer, index, and token list. They're separate instances, but all valid for `type LL1`.

---

🧼 What Happens on Free?

When calling:

```euphoria
LL1:free(ptr)
```

All internal fields — including `LL1_INDEX` — are erased. `eumem:free()` deletes the entire struct. After that:

* `eumem:valid(ptr, __MYSIZE__)` will return 0
* `type LL1(ptr)` will fail
* Accessing the freed pointer will result in garbage or error

Caller is responsible for setting the pointer to NULL if needed.

---

🧠 Why This Matters

This pattern has proven valuable in:

* FreeBASIC
* C
* OpenEuphoria

It's simple, scales well, and allows for object-like design without embracing full OOP or class inheritance.

You can use this for:

* ASTs
* Tokenizers
* Stacks
* Symbol tables
* Virtual machines
* Dynamic data structures

---

🔄 Final Thought

Euphoria gives you enough control to simulate objects, but not enough to hide from responsibility. This pattern bridges the gap — it's clean, performant, and honest.

Thanks for reading. Would love to hear how others have solved pass-by-reference or struct emulation in their own projects.

--

Ronald



