# Proof Generation with snarkjs

This guide walks through generating a Groth16 proof for any circuit in this repo.

## Prerequisites

- `circom` installed and on PATH
- `snarkjs` installed (`npm install -g snarkjs`)
- Completed trusted setup (`.zkey` file present in `build/<circuit>/`)

## Step-by-Step

### 1. Prepare Your Input

Each circuit expects a JSON file describing its input signals. Example for `identity`:

```json
{
  "secret": "12345678901234567890",
  "nullifier": "98765432109876543210",
  "trapdoor": "11111111111111111111"
}
```

Save this as `inputs/identity_input.json`.

### 2. Generate the Witness

```bash
node build/identity/identity_js/generate_witness.js \
  build/identity/identity_js/identity.wasm \
  inputs/identity_input.json \
  build/identity/witness.wtns
```

### 3. Generate the Proof

```bash
snarkjs groth16 prove \
  build/identity/identity_final.zkey \
  build/identity/witness.wtns \
  build/identity/proof.json \
  build/identity/public.json
```

`proof.json` contains the proof (π_A, π_B, π_C). `public.json` contains the public signals.

### 4. Verify Locally

```bash
snarkjs groth16 verify \
  build/identity/verification_key.json \
  build/identity/public.json \
  build/identity/proof.json
```

### 5. Export for Soroban

```bash
# Export calldata for on-chain verification
snarkjs zkey export solidityverifier \
  build/identity/identity_final.zkey \
  build/identity/Verifier.sol

# Or export the raw proof as hex for Soroban
snarkjs zkey export soliditycalldata \
  build/identity/public.json \
  build/identity/proof.json
```

## Using the Helper Script

```bash
./scripts/generate-proof.sh identity inputs/identity_input.json
```

## Troubleshooting

| Error | Cause | Fix |
|-------|-------|-----|
| `Error: Assert Failed` | Witness does not satisfy a constraint | Check input values |
| `zkey file not found` | Setup not complete | Run `make setup CIRCUIT=identity` |
| `Invalid proof` | Wrong zkey for circuit | Ensure zkey matches the compiled r1cs |
