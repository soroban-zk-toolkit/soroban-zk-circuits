# Circuit Reference

Complete reference for all circuits: inputs, outputs, and constraint counts.

---

## identity.circom

Generates a commitment to a secret identity and produces a nullifier.

### Inputs

| Signal      | Visibility | Description                         |
|-------------|-----------|-------------------------------------|
| `secret`    | Private   | Secret scalar (field element)       |
| `nullifier` | Private   | Random nullifier scalar             |
| `trapdoor`  | Private   | Trapdoor for commitment hiding      |

### Outputs

| Signal       | Visibility | Description                    |
|--------------|-----------|-------------------------------|
| `commitment` | Public    | Pedersen commitment to secret  |
| `nullifierHash` | Public | Hash of nullifier + secret    |

### Constraints

~2 000 R1CS constraints.

---

## membership.circom

Proves that a commitment exists in a Merkle tree without revealing its position.

### Inputs

| Signal            | Visibility | Description                                |
|-------------------|-----------|-------------------------------------------|
| `leaf`            | Private   | The leaf value (commitment)               |
| `pathElements[n]` | Private   | Sibling hashes along the Merkle path      |
| `pathIndices[n]`  | Private   | 0/1 indicating left/right at each level   |
| `root`            | Public    | Expected Merkle root                      |

### Outputs

| Signal   | Visibility | Description                              |
|----------|-----------|------------------------------------------|
| `root`   | Public    | Recomputed root (must equal input `root`)|

### Parameters

- `n` — tree depth (default: 20)

### Constraints

~8 000 R1CS constraints (depth 20).

---

## nullifier.circom

Derives a unique nullifier to prevent double-spending.

### Inputs

| Signal      | Visibility | Description                   |
|-------------|-----------|-------------------------------|
| `secret`    | Private   | Secret scalar                 |
| `externalNullifier` | Public | Domain-separator / epoch |

### Outputs

| Signal          | Visibility | Description              |
|-----------------|-----------|--------------------------|
| `nullifierHash` | Public    | Poseidon(secret, extNull)|

### Constraints

~1 500 R1CS constraints.

---

## range_proof.circom

Proves that a committed value `v` satisfies `low <= v < high` without revealing `v`.

### Inputs

| Signal   | Visibility | Description                           |
|----------|-----------|---------------------------------------|
| `value`  | Private   | The value to range-check              |
| `low`    | Public    | Lower bound (inclusive)               |
| `high`   | Public    | Upper bound (exclusive)               |

### Outputs

| Signal    | Visibility | Description                              |
|-----------|-----------|------------------------------------------|
| `inRange` | Public    | 1 if `low <= value < high`, else 0       |

### Constraints

~4 000 R1CS constraints (64-bit range).
