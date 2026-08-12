# ZK Circuit Architecture

## Overview

This repository contains Circom zero-knowledge circuits for the Soroban ZK Toolkit. Each circuit is designed to be compiled to R1CS and used with the Groth16 proving system via snarkjs.

## Circuit Hierarchy

```
soroban-zk-circuits/
├── identity.circom       — Identity commitment and verification
├── membership.circom     — Merkle-tree membership proof
├── nullifier.circom      — Nullifier generation (double-spend prevention)
└── range_proof.circom    — Range proof for bounded values
```

## Proving System

All circuits use **Groth16** over the BN128 (alt_bn128) curve. This curve is supported by the Stellar/Soroban EVM precompiles and is efficient to verify on-chain.

## Trusted Setup

Each circuit requires a circuit-specific phase-2 trusted setup derived from a Powers of Tau ceremony. See `docs/TRUSTED_SETUP.md` for instructions.

## Signal Convention

| Signal prefix | Meaning                        |
|--------------|-------------------------------|
| `in`         | Public or private input        |
| `out`        | Public output                  |
| `aux`        | Auxiliary / intermediate wire  |
| `root`       | Merkle root (public)           |
| `nullifier`  | Nullifier hash (public output) |

## Constraint Budget

| Circuit       | Approximate constraints |
|---------------|------------------------|
| identity      | ~2 000                 |
| membership    | ~8 000 (depth-20 tree) |
| nullifier     | ~1 500                 |
| range_proof   | ~4 000 (64-bit range)  |

## Integration with Soroban

Generated proofs (`.json`) and verification keys are consumed by the companion `soroban-zk-verifier` Soroban contract, which calls the BN128 pairing precompile to verify Groth16 proofs on-chain.
