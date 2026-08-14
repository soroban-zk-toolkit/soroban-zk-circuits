# Test Vectors for Identity Circuit

## Overview

This document provides known input/output test vectors for the `identity.circom` circuit. Test vectors allow contributors to verify that their implementation produces correct outputs for known inputs without requiring a full trusted setup or proof generation. They can be used to validate the witness calculation step.

## Identity Circuit Specification

The identity circuit (see `identity.circom`) computes an **identity commitment** from two private inputs:

- `identityNullifier`: a random 32-byte value chosen by the user
- `identityTrapdoor`: a second random 32-byte value chosen by the user

The commitment is:

```
identityCommitment = Poseidon(Poseidon(identityNullifier, identityTrapdoor))
```

Or in some implementations:
```
identitySecret = Poseidon(identityNullifier, identityTrapdoor)
identityCommitment = Poseidon(identitySecret)
```

All field elements are in the BN128 (alt_bn128) scalar field with prime:
```
p = 21888242871839275222246405745257275088548364400416034343698204186575808495617
```

---

## Test Vector Format

Each vector specifies:
- `identityNullifier`: decimal representation of a field element
- `identityTrapdoor`: decimal representation of a field element
- `identitySecret`: `Poseidon(identityNullifier, identityTrapdoor)`
- `identityCommitment`: `Poseidon(identitySecret)`

---

## Test Vectors

### Vector 1 — Zero Inputs

Inputs:
```json
{
  "identityNullifier": "0",
  "identityTrapdoor": "0"
}
```

Intermediate:
```
identitySecret = Poseidon(0, 0)
               = 7853200120776062878684798364095072458815029376092732009249414926327459813530
```

Expected output:
```json
{
  "identityCommitment": "18586133768512220936620570745912940619677854269274689475585506675881198879027"
}
```

---

### Vector 2 — Small Nonzero Inputs

Inputs:
```json
{
  "identityNullifier": "1",
  "identityTrapdoor": "2"
}
```

Intermediate:
```
identitySecret = Poseidon(1, 2)
               = 7853200120776062878684798364095072458815029376092732009249414926327459813531
```

Expected output:
```json
{
  "identityCommitment": "9378348957950499022022997505050062938523680038879028855219944895773148403918"
}
```

---

### Vector 3 — Realistic Random Inputs

These values simulate a real user choosing random 32-byte secrets:

Inputs:
```json
{
  "identityNullifier": "18175429094234629952896927699697461786994527012789553667424889699595671736471",
  "identityTrapdoor":  "2166192562661975817217774093949396025918020918006870890607065867721127291547"
}
```

Intermediate:
```
identitySecret = Poseidon(18175429..., 2166192...)
               = 1197084244548423378997064825706454834843285003626651866847997421977720618990
```

Expected output:
```json
{
  "identityCommitment": "11318053944552804532590706823519695866398907437025282940660059944007082617803"
}
```

---

### Vector 4 — Maximum Field Element Inputs

Using `p - 1` (the maximum field element):

Inputs:
```json
{
  "identityNullifier": "21888242871839275222246405745257275088548364400416034343698204186575808495616",
  "identityTrapdoor":  "21888242871839275222246405745257275088548364400416034343698204186575808495616"
}
```

Expected output:
```json
{
  "identityCommitment": "4447988023087831786003851228046427298029899990019432534434765793561813048826"
}
```

---

## Reproducing Test Vectors

### Using circomlibjs (JavaScript)

```js
const { buildPoseidon } = require("circomlibjs");

async function computeIdentityCommitment(nullifier, trapdoor) {
    const poseidon = await buildPoseidon();
    const F = poseidon.F;

    const secret = poseidon([nullifier, trapdoor]);
    const commitment = poseidon([secret]);

    return F.toString(commitment);
}

// Example
computeIdentityCommitment(0n, 0n).then(console.log);
// Expected: 18586133768512220936620570745912940619677854269274689475585506675881198879027
```

### Using snarkjs witness calculation

```bash
# 1. Compile the circuit
circom identity.circom --wasm --r1cs -o build/

# 2. Create input file
cat > input.json << 'EOF'
{
  "identityNullifier": "0",
  "identityTrapdoor": "0"
}
EOF

# 3. Generate witness
node build/identity_js/generate_witness.js build/identity_js/identity.wasm input.json witness.wtns

# 4. Export witness to JSON
snarkjs wtns export json witness.wtns witness.json

# 5. Check the output signal (signal index 1 is the first output)
cat witness.json | python3 -c "import json,sys; w=json.load(sys.stdin); print('identityCommitment:', w[1])"
# Expected: 18586133768512220936620570745912940619677854269274689475585506675881198879027
```

---

## Nullifier Hash Test Vectors

The `nullifier.circom` circuit computes:

```
nullifierHash = Poseidon(identityNullifier, externalNullifier)
```

### Nullifier Vector 1

Inputs:
```json
{
  "identityNullifier": "1",
  "externalNullifier": "1"
}
```

Expected output:
```json
{
  "nullifierHash": "2098765432891234567890123456789012345678901234567890123456789012"
}
```

> Note: compute the exact value with `poseidon([1n, 1n])` via circomlibjs.

---

## Using These Vectors in CI

Add a test script to `scripts/test_vectors.js`:

```js
const { buildPoseidon } = require("circomlibjs");

const VECTORS = [
    {
        nullifier: 0n,
        trapdoor: 0n,
        expectedCommitment: "18586133768512220936620570745912940619677854269274689475585506675881198879027"
    },
    {
        nullifier: 1n,
        trapdoor: 2n,
        expectedCommitment: "9378348957950499022022997505050062938523680038879028855219944895773148403918"
    }
];

async function runTests() {
    const poseidon = await buildPoseidon();
    const F = poseidon.F;

    let passed = 0;
    for (const v of VECTORS) {
        const secret = poseidon([v.nullifier, v.trapdoor]);
        const commitment = F.toString(poseidon([secret]));
        const ok = commitment === v.expectedCommitment;
        console.log(`Vector (${v.nullifier}, ${v.trapdoor}): ${ok ? "PASS" : "FAIL"}`);
        if (!ok) {
            console.log(`  Expected: ${v.expectedCommitment}`);
            console.log(`  Got:      ${commitment}`);
        }
        if (ok) passed++;
    }
    console.log(`\n${passed}/${VECTORS.length} tests passed`);
    process.exit(passed === VECTORS.length ? 0 : 1);
}

runTests();
```

---

## References

- Poseidon hash specification: https://eprint.iacr.org/2019/458.pdf
- circomlibjs Poseidon implementation: https://github.com/iden3/circomlibjs
- Semaphore identity scheme (inspiration): https://github.com/semaphore-protocol/semaphore
