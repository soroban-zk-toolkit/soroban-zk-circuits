# Multi-Asset Ownership Proof Circuit

## Overview

A multi-asset ownership proof allows a user to prove that they own a set of assets (e.g., tokens, NFTs, accounts) meeting certain criteria — such as owning at least N different assets, holding a minimum combined balance, or owning specific asset types — all without revealing which specific assets they hold or their individual balances.

## Use Cases

- **Collateralization proof**: Prove total collateral value exceeds a threshold without revealing individual asset positions
- **Portfolio eligibility**: Prove a portfolio contains at least 3 different asset classes without revealing holdings
- **Airdrop qualification**: Prove ownership of assets from a whitelist without revealing which ones
- **Sybil resistance**: Prove you own multiple distinct assets to demonstrate you are not a low-resource bot

## Circuit Architecture

The multi-asset ownership circuit composes several primitives:

```
MultiAssetOwnership
├── AssetCommitment[N]         — commit each (assetId, balance) pair
├── MerkleProof[N]             — prove each asset is in the registry
├── BalanceRangeCheck[N]       — prove each balance > 0 (or > threshold)
├── DistinctAssetCheck         — prove all assetIds are distinct
├── TotalBalanceAccumulator    — sum balances and range-check the total
└── NullifierDerivation        — optional: derive a nullifier to prevent reuse
```

## Circuit Design

### Simplified Multi-Asset Ownership

```circom
pragma circom 2.0.0;

include "poseidon.circom";
include "merkleProof.circom";
include "comparators.circom";

// Proves ownership of N assets each registered in a Merkle tree
template MultiAssetOwnership(N, LEVELS) {
    // Private inputs — the assets the prover owns
    signal input assetIds[N];        // e.g., token contract addresses as field elements
    signal input balances[N];        // private balances for each asset
    signal input salts[N];           // random salts for commitments

    // Merkle path for each asset
    signal input pathElements[N][LEVELS];
    signal input pathIndices[N][LEVELS];

    // Public inputs
    signal input assetRegistryRoot;  // Merkle root of known/valid assets
    signal input minTotalBalance;    // minimum combined balance to prove

    // Outputs
    signal output ownershipCommitment; // Poseidon(assetIds[], balances[], salt)

    // Step 1: Verify each asset is in the registry
    component assetProofs[N];
    for (var i = 0; i < N; i++) {
        assetProofs[i] = MerkleProof(LEVELS);
        assetProofs[i].leaf <== assetIds[i];
        assetProofs[i].root <== assetRegistryRoot;
        for (var j = 0; j < LEVELS; j++) {
            assetProofs[i].pathElements[j] <== pathElements[i][j];
            assetProofs[i].pathIndices[j] <== pathIndices[i][j];
        }
    }

    // Step 2: Range-check each balance is positive
    component balanceChecks[N];
    for (var i = 0; i < N; i++) {
        balanceChecks[i] = GreaterThan(64);  // 64-bit balances
        balanceChecks[i].in[0] <== balances[i];
        balanceChecks[i].in[1] <== 0;
        balanceChecks[i].out === 1;
    }

    // Step 3: Prove total balance >= minTotalBalance
    signal totalBalance;
    var sum = 0;
    for (var i = 0; i < N; i++) {
        sum += balances[i];  // Accumulate in template (not a constraint — use signal)
    }
    // Note: in Circom, arithmetic on signals requires explicit constraints
    // For actual implementation, use a running sum with intermediate signals:
    signal runningBalance[N + 1];
    runningBalance[0] <== 0;
    for (var i = 0; i < N; i++) {
        runningBalance[i + 1] <== runningBalance[i] + balances[i];
    }
    totalBalance <== runningBalance[N];

    component totalCheck = GreaterEqThan(64);
    totalCheck.in[0] <== totalBalance;
    totalCheck.in[1] <== minTotalBalance;
    totalCheck.out === 1;

    // Step 4: Compute ownership commitment
    component commitHasher = Poseidon(3);
    commitHasher.inputs[0] <== assetIds[0];  // Simplified: hash first asset + total + salt
    commitHasher.inputs[1] <== totalBalance;
    commitHasher.inputs[2] <== salts[0];
    ownershipCommitment <== commitHasher.out;
}

component main {public [assetRegistryRoot, minTotalBalance]} = MultiAssetOwnership(3, 20);
```

## Distinct Asset IDs

To prevent the prover from using the same asset ID multiple times (double-counting), enforce distinctness:

```circom
// For small N, O(N^2) pairwise inequality checks:
template AssertDistinct(N) {
    signal input values[N];

    component neChecks[N * (N - 1) / 2];
    var idx = 0;
    for (var i = 0; i < N; i++) {
        for (var j = i + 1; j < N; j++) {
            // values[i] != values[j] iff (values[i] - values[j]) has an inverse
            neChecks[idx] = IsZero();
            neChecks[idx].in <== values[i] - values[j];
            neChecks[idx].out === 0;  // Must NOT be zero (must be distinct)
            idx++;
        }
    }
}
```

For large N, consider sorting the asset IDs and proving each consecutive pair is strictly ordered (requires a comparison circuit per pair but scales as O(N) constraints instead of O(N²)).

## Constraint Count Estimate

For `MultiAssetOwnership(N=3, LEVELS=20)`:

| Component | Count | Constraints Each | Total |
|---|---|---|---|
| MerkleProof(20) | 3 | ~4,860 | ~14,580 |
| GreaterThan(64) per balance | 3 | ~64 | ~192 |
| GreaterEqThan(64) for total | 1 | ~64 | ~64 |
| Running balance accumulation | 3 additions | ~3 | ~9 |
| AssertDistinct(3) | 3 pairs | ~3 | ~9 |
| Poseidon(3) commitment | 1 | ~264 | ~264 |
| **Total** | | | **~15,118** |

For N=5 assets: ~26,000 constraints. For N=10: ~53,000 constraints.

## Scalability

| N (assets) | Constraints | Proving Time (est.) |
|---|---|---|
| 2 | ~10,200 | ~2 seconds |
| 3 | ~15,100 | ~3 seconds |
| 5 | ~25,700 | ~5 seconds |
| 10 | ~51,700 | ~10 seconds |

The cost is dominated by the N Merkle proofs. To reduce cost:
- Use a shallower tree if the asset registry is small
- Batch N assets into a single Merkle proof if the circuit supports it
- Use a set membership proof (e.g., batched Merkle) instead of N individual proofs

## Integration with Soroban

The ownership commitment can be stored on Stellar as a smart contract state variable. A user provides the ZK proof off-chain, and the Soroban contract verifies it using a pre-deployed Groth16 verifier, enabling privacy-preserving collateral management or portfolio attestation.

## References

- Privacy-preserving portfolio proofs: https://eprint.iacr.org/2022/1144.pdf
- circomlib IsZero, GreaterThan: https://github.com/iden3/circomlib
- Batch Merkle membership: https://github.com/privacy-scaling-explorations/zk-kit
