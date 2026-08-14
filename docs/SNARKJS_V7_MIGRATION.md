# snarkjs v0.7 Migration Guide

## Overview

snarkjs v0.7 introduces significant changes to the trusted setup format and proof generation API. This guide covers what changed, why, and how to migrate circuits in this repository from snarkjs v0.6 to v0.7.

## What Changed in v0.7

### 1. New `.zkey` Format (Phase 2 Breaking Change)

snarkjs v0.7 uses a new binary format for `.zkey` (proving key) files. **Phase 2 `.zkey` files generated with v0.6 are not compatible with v0.7.**

| Aspect | v0.6 | v0.7 |
|---|---|---|
| `.zkey` format version | v1 | v2 |
| Backward compatible | — | No |
| File extension | `.zkey` | `.zkey` (same, different internals) |
| ptau compatibility | Works with existing ptau | Requires re-contribution or ptau v8+ |

### 2. Trusted Setup Parameters File (`.ptau`)

The Powers of Tau (ptau) ceremony format is updated. v0.7 requires:
- `hermez-rawFinal.ptau` or ceremony files marked with `v8` protocol.
- Older `.ptau` files from Hermez v1 ceremony need to be converted.

Download compatible ptau files from:
```
https://storage.googleapis.com/zkey-downloads/powersOfTau28_hez_final_XX.ptau
```
where `XX` is the power (e.g., `15` for circuits up to 2^15 = 32,768 constraints).

### 3. API Changes

#### CLI Changes

```bash
# v0.6 — phase2 setup
snarkjs groth16 setup circuit.r1cs pot12_final.ptau circuit_0000.zkey

# v0.7 — same command, but requires v0.7-compatible ptau
snarkjs groth16 setup circuit.r1cs hermez-rawFinal.ptau circuit_0000.zkey
```

#### JavaScript API

```js
// v0.6
const { proof, publicSignals } = await snarkjs.groth16.prove(
    "circuit_final.zkey",
    witness
);

// v0.7 — same API, but .zkey must be generated with v0.7
const { proof, publicSignals } = await snarkjs.groth16.prove(
    "circuit_final.zkey",
    witness
);
```

The JavaScript API surface is largely unchanged, but the internal format expects v0.7 `.zkey` files.

### 4. Verifier Contract Generation

```bash
# v0.6
snarkjs zkey export solidityverifier circuit_final.zkey verifier.sol

# v0.7 — new option for EIP-4844 blob-compatible verifier
snarkjs zkey export solidityverifier circuit_final.zkey verifier.sol --template groth16
```

### 5. Witness Calculator

The wasm witness calculator is unchanged. No update needed for `.wasm` or `witness_calculator.js`.

## Step-by-Step Migration

### Step 1: Install snarkjs v0.7

```bash
npm install snarkjs@latest
# Verify version
npx snarkjs --version  # Should show 0.7.x
```

### Step 2: Download Compatible Powers of Tau

```bash
# For circuits with up to 2^15 constraints (~32k)
wget https://storage.googleapis.com/zkey-downloads/powersOfTau28_hez_final_15.ptau

# For circuits with up to 2^16 constraints (~65k, e.g., membership at deep trees)
wget https://storage.googleapis.com/zkey-downloads/powersOfTau28_hez_final_16.ptau
```

| Circuit | Max Constraints | Recommended ptau power |
|---|---|---|
| Nullifier | ~350 | 9 (2^9 = 512) |
| Identity | ~1,200 | 11 (2^11 = 2,048) |
| Range Proof | ~2,800 | 12 (2^12 = 4,096) |
| Membership | ~6,500 | 13 (2^13 = 8,192) |

### Step 3: Recompile Circuits (No Changes Needed)

Circom circuits themselves do not need modification. Only the trusted setup artifacts change:

```bash
# Recompile (optional if .r1cs already exists)
circom identity.circom --r1cs --wasm --sym -o build/
```

### Step 4: Regenerate Phase 2 Setup

```bash
# Generate initial zkey with v0.7 ptau
snarkjs groth16 setup build/identity.r1cs powersOfTau28_hez_final_11.ptau build/identity_0000.zkey

# Contribute to the ceremony (at least one contribution required)
snarkjs zkey contribute build/identity_0000.zkey build/identity_0001.zkey \
    --name="First Contributor" -v -e="$(openssl rand -hex 32)"

# Export final zkey
cp build/identity_0001.zkey build/identity_final.zkey

# Verify the zkey
snarkjs zkey verify build/identity.r1cs powersOfTau28_hez_final_11.ptau build/identity_final.zkey
```

### Step 5: Export Verification Key and Verifier Contract

```bash
# Export verification key (JSON)
snarkjs zkey export verificationkey build/identity_final.zkey build/identity_verification_key.json

# Export Solidity verifier (if needed)
snarkjs zkey export solidityverifier build/identity_final.zkey contracts/IdentityVerifier.sol
```

### Step 6: Update Makefile / Scripts

Update `Makefile` targets to reference the new ptau files:

```makefile
# Before (v0.6)
PTAU = pot12_final.ptau

# After (v0.7)
PTAU = powersOfTau28_hez_final_13.ptau
```

## Compatibility Matrix

| snarkjs version | Circom version | ptau format | .zkey format |
|---|---|---|---|
| 0.5.x | 1.x | v1 | v1 |
| 0.6.x | 2.0.x | v2 | v1 |
| 0.7.x | 2.1.x | v2 | v2 |

## Common Errors and Fixes

**Error**: `Error: zkey file format not supported`
- **Fix**: Regenerate `.zkey` files with snarkjs v0.7

**Error**: `Ptau file format not supported`
- **Fix**: Download a fresh ptau file from the hermez ceremony (v0.7-compatible)

**Error**: `Circuit size mismatch`
- **Fix**: Use a ptau file with sufficient power (2^power >= circuit constraints)

## References

- snarkjs v0.7 release notes: https://github.com/iden3/snarkjs/releases/tag/v0.7.0
- Hermez Powers of Tau ceremony: https://github.com/hermeznetwork/phase2ceremony
- Circom 2.1.x documentation: https://docs.circom.io
