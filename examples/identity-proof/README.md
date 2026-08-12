# Identity Proof Example

This example shows how to generate and verify a ZK identity proof using the `identity.circom` circuit.

## What It Proves

A prover can demonstrate they possess a valid identity commitment (secret + nullifier + trapdoor) without revealing any of those values. The public output is the commitment and nullifier hash.

## Prerequisites

- Completed trusted setup: `./scripts/setup.sh identity`

## Step 1 — Create Input

```json
{
  "secret":    "123456789012345678901234567890",
  "nullifier": "987654321098765432109876543210",
  "trapdoor":  "111111111111111111111111111111"
}
```

Save as `inputs/identity_input.json`.

## Step 2 — Generate and Verify Proof

```bash
./scripts/generate-proof.sh identity inputs/identity_input.json
```

Expected output:
```
==> Generating witness...
==> Generating Groth16 proof...
==> Proof generated:
    proof:  build/identity/proof.json
    public: build/identity/public.json
==> Verifying proof locally...
Proof is VALID
```

## Step 3 — Submit to Soroban

Use the companion `soroban-zk-verifier` contract to verify on-chain:

```bash
soroban contract invoke \
  --id <VERIFIER_CONTRACT_ID> \
  --fn verify_identity_proof \
  --arg "$(cat build/identity/proof.json)" \
  --arg "$(cat build/identity/public.json)"
```

## Interpreting Results

The public signals in `public.json` are:
- `commitment` — the identity commitment (store/register on-chain)
- `nullifierHash` — must be unique per action to prevent replay
