# Poseidon Hash Circuit for Merkle Tree Construction

## Overview

Poseidon is a cryptographic hash function designed specifically for zero-knowledge proof systems. Unlike general-purpose hashes such as SHA-256 or Keccak, Poseidon operates natively over prime fields, dramatically reducing the number of constraints required in arithmetic circuits.

## Why Poseidon Over SHA-256?

| Property | SHA-256 | Poseidon |
|---|---|---|
| Constraints per hash | ~25,000 (R1CS) | ~220–300 |
| Field-native | No | Yes |
| ZK-friendliness | Poor | Excellent |
| Security basis | Bit operations | Algebraic structure |

SHA-256 was designed for efficient hardware/software execution using bitwise operations (XOR, AND, rotations). These operations are expensive to represent as arithmetic constraints over a prime field. Poseidon avoids this by using field additions and low-degree power maps (e.g., x^5) as its core operations.

## Poseidon Permutation

The Poseidon permutation operates on a state vector of width `t` field elements. It applies alternating **full rounds** and **partial rounds**:

- **Full rounds**: Apply the S-box `x^alpha` to every state element.
- **Partial rounds**: Apply the S-box only to the first element; leave others linear.
- **MDS matrix**: After each round, multiply the state by a Maximum Distance Separable matrix to provide diffusion.

Round constants are precomputed and field-specific (e.g., BN128 or BLS12-381).

## Circuit Design for Merkle Trees

A Poseidon-based Merkle tree circuit for 2-to-1 hashing:

```circom
pragma circom 2.0.0;

include "poseidon.circom";

template PoseidonMerkleHash() {
    signal input left;
    signal input right;
    signal output hash;

    component h = Poseidon(2);
    h.inputs[0] <== left;
    h.inputs[1] <== right;
    hash <== h.out;
}
```

The `Poseidon(2)` component takes 2 inputs and produces 1 output, suitable for combining left and right child hashes in a binary Merkle tree.

## Merkle Proof Circuit

```circom
pragma circom 2.0.0;

include "poseidon.circom";

template MerkleProof(levels) {
    signal input leaf;
    signal input pathElements[levels];
    signal input pathIndices[levels];
    signal output root;

    component hashers[levels];
    signal hashes[levels + 1];
    hashes[0] <== leaf;

    for (var i = 0; i < levels; i++) {
        hashers[i] = Poseidon(2);
        // pathIndices[i] == 0 means current node is left child
        hashers[i].inputs[0] <== hashes[i] * (1 - pathIndices[i]) + pathElements[i] * pathIndices[i];
        hashers[i].inputs[1] <== hashes[i] * pathIndices[i] + pathElements[i] * (1 - pathIndices[i]);
        hashes[i + 1] <== hashers[i].out;
    }

    root <== hashes[levels];
}
```

## Constraint Count

For a Merkle tree of depth `d`:
- Each Poseidon(2) instance uses approximately 243 constraints (for BN128, alpha=5, t=3).
- Total constraints for proof verification: `d × 243` — e.g., 20-level tree ≈ **4,860 constraints**.
- Compare with SHA-256 Merkle proof: `d × 25,000` ≈ **500,000 constraints**.

This is roughly a **100x reduction** in constraints.

## Security Parameters

- Recommended minimum: 8 full rounds + 56 partial rounds for 128-bit security on BN128.
- Parameters are field-dependent and should not be reused across different elliptic curves.
- Reference implementation: [iden3/circomlib poseidon.circom](https://github.com/iden3/circomlib/blob/master/circuits/poseidon.circom)

## References

- Grassi et al., "Poseidon: A New Hash Function for Zero-Knowledge Proof Systems" (USENIX Security 2021)
- iden3 circomlib — battle-tested Poseidon implementation for Circom
- Tornado Cash — production usage of Poseidon Merkle trees
