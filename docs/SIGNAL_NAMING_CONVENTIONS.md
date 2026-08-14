# Signal Naming Conventions for Circom Contributors

## Purpose

This document establishes naming conventions for signals, templates, and components in this repository. Consistent naming makes circuits easier to audit, compose, and verify. These conventions apply to all new circuits and should be followed when modifying existing ones.

## General Principles

1. **Descriptive over short**: `merklePathElement` is better than `mpe` or `x`
2. **camelCase for signals**: Circom convention follows JavaScript-style camelCase
3. **UPPER_SNAKE_CASE for constants**: Template parameters that are fixed at compile time
4. **PascalCase for templates**: Template names are types; they should read like class names
5. **Lowercase for loop variables**: `i`, `j`, `k` are acceptable for loop indices only

---

## Signal Naming Rules

### Input Signals

Public inputs should describe what the verifier sees and can check:

```circom
signal input root;              // Public: Merkle root
signal input nullifierHash;     // Public: computed nullifier hash
signal input externalNullifier; // Public: domain-separation value
signal input minAge;            // Public: age threshold
```

Private inputs should describe what the prover knows:

```circom
signal input secret;            // Private: random secret
signal input trapdoor;          // Private: identity trapdoor
signal input birthYear;         // Private: prover's birth year
signal input pathElements[N];   // Private: Merkle path elements
signal input pathIndices[N];    // Private: Merkle path left/right flags (0 or 1)
```

**Convention**: Use the `input` declaration order: public inputs first, then private inputs, to match the snarkjs proof API convention.

### Output Signals

```circom
signal output commitment;       // The computed commitment (e.g., Poseidon hash)
signal output nullifier;        // The computed nullifier
signal output isValid;          // Boolean result (0 or 1) — avoid when possible; prefer constraints
```

**Avoid** bare `out` as an output name unless the template is a low-level primitive (e.g., `Poseidon.out`). Higher-level templates should name outputs semantically.

### Intermediate Signals

```circom
signal ageInDays;               // Intermediate computed value
signal leafHash;                // Hash of a Merkle leaf
signal currentHash;             // Running hash in a Merkle path traversal
signal leftChild;               // Left child in a hash computation
signal rightChild;              // Right child in a hash computation
```

**Avoid** generic names like `tmp`, `temp`, `a`, `b` for intermediate signals. If a signal is truly temporary in a computation step, name it after what it holds (`partialSum`, `roundState`, `selectedInput`).

---

## Template Naming Rules

Templates are named in **PascalCase** and should read as noun phrases describing what they prove or compute:

| Good | Bad | Reason |
|---|---|---|
| `MerkleProof` | `merkle_proof`, `merkle` | PascalCase; full noun phrase |
| `PoseidonHash` | `Hash`, `poseidon` | Specific; not generic |
| `AgeRangeProof` | `AgeCheck`, `age` | Reads as a proof statement |
| `Num2Bits` | `numBits`, `toBits` | Follows circomlib convention |
| `IdentityCommitment` | `ID`, `Commit` | Descriptive; not abbreviated |

### Template Parameters

Template parameters (constants that parameterize circuit size) use `UPPER_SNAKE_CASE` or lowercase single letters for well-known conventions:

```circom
template MerkleProof(LEVELS) { ... }        // UPPER_SNAKE_CASE for named params
template Poseidon(nInputs) { ... }           // lowercase for established circomlib style
template Num2Bits(n) { ... }                 // lowercase single letter: well-known
template BatchVerify(BATCH_SIZE, LEVELS) { ... }
```

---

## Array Signal Naming

For arrays, always include the purpose in the name, not just a generic plural:

```circom
// Good
signal input pathElements[LEVELS];
signal input siblingHashes[LEVELS];
signal input assetIds[N_ASSETS];
signal intermediate levelHashes[LEVELS + 1];

// Bad
signal input elements[LEVELS];    // What kind of elements?
signal input arr[N];               // Meaningless
signal hashes[LEVELS];             // Which hashes?
```

---

## Component Instance Naming

Component instances should describe their role in the circuit, not just their template type:

```circom
// Good
component leafHasher = Poseidon(2);
component merkleCheck = MerkleProof(20);
component ageComparator = GreaterEqThan(16);
component nullifierHasher = Poseidon(2);

// Bad
component p = Poseidon(2);       // 'p' tells you nothing
component h1 = Poseidon(2);      // Numbered suffixes are a smell
component check = GreaterEqThan(16);  // 'check' is too generic
```

When multiple instances of the same template exist (e.g., in a loop), use indexed names with a descriptive prefix:

```circom
component levelHashers[LEVELS];
for (var i = 0; i < LEVELS; i++) {
    levelHashers[i] = Poseidon(2);
}
```

---

## Boolean Flags

Signals that represent boolean values (constrained to {0, 1}) should be named with a prefix or suffix that makes the boolean nature obvious:

```circom
signal input isLeft;              // Preferred prefix: is/has/should/can
signal input pathIndices[LEVELS]; // 'Indices' implies 0/1 Merkle direction
signal output isValid;            // Only use as output; constraints are preferred
```

Avoid naming boolean signals as counters or values — always constrain them:

```circom
// Always add a binary constraint for boolean signals
pathIndices[i] * (1 - pathIndices[i]) === 0;
```

---

## Naming Checklist for New Circuits

Before submitting a PR with a new circuit, verify:

- [ ] All signal names are camelCase
- [ ] Template name is PascalCase and reads as a noun phrase
- [ ] No signals named `tmp`, `temp`, `a`, `b`, `x`, `y` outside low-level primitives
- [ ] Array signals include their purpose in the name (not just plural of type)
- [ ] Component instances named for their role, not their template
- [ ] Boolean signals have a binary constraint and an `is`/`has` prefix
- [ ] Public and private inputs are separated and commented

---

## Examples from This Repository

### identity.circom
```circom
// Good: semantic names
signal input identityNullifier;
signal input identityTrapdoor;
signal output identityCommitment;
component identityHasher = Poseidon(2);
```

### membership.circom
```circom
// Good: array names describe content
signal input pathElements[LEVELS];
signal input pathIndices[LEVELS];
signal output root;
component levelHashers[LEVELS];
```
