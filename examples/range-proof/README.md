# Range Proof Example

This example shows how to prove that a value (e.g. an XLM amount) lies within a range without revealing the value itself.

## What It Proves

The prover demonstrates `low <= value < high` for some secret `value`, given public bounds `low` and `high`. This is useful for:
- Proving a balance exceeds a threshold without revealing the balance
- Proving a transaction amount is below a regulatory limit

## Prerequisites

- Completed trusted setup: `./scripts/setup.sh range_proof`

## Input JSON

```json
{
  "value": "5000000",
  "low":   "0",
  "high":  "18446744073709551616"
}
```

`value` must satisfy `low <= value < high`. All values are field elements (non-negative integers).

## Generate and Verify

```bash
./scripts/generate-proof.sh range_proof inputs/range_input.json
```

The public signal `inRange` will be `1` if the value is in range.

## On-chain Use

When submitting to Soroban, the verifier checks:
1. The proof is valid (Groth16 pairing check)
2. `inRange == 1` (enforced in the contract)

This allows gating contract actions on range conditions without learning the user's actual value.

## Constraint Note

The circuit uses a 64-bit binary decomposition, giving ~4 000 constraints. For smaller ranges you can reduce the bit width by modifying the `range_proof.circom` template parameter.
