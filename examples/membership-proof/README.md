# Membership Proof Example

This example demonstrates proving that an address commitment exists in a Merkle tree without revealing which leaf it is.

## What It Proves

Given a Merkle root and a commitment, the prover shows they know a valid path from their leaf to the root — proving membership without leaking their position.

## Prerequisites

- Completed trusted setup: `./scripts/setup.sh membership`
- A Merkle tree built over known commitments

## Building a Merkle Tree

Use the helper in `scripts/` (or any Poseidon-based Merkle tree library):

```js
const { MerkleTree } = require("merkletreejs");
const { buildPoseidon } = require("circomlibjs");

const poseidon = await buildPoseidon();
const leaves = [commitment1, commitment2, /* ... */];
const tree = new MerkleTree(leaves, (x) => poseidon([x]));

const root = tree.getRoot();
const proof = tree.getProof(myCommitment);
```

## Input JSON

```json
{
  "leaf": "<my commitment>",
  "pathElements": ["<sibling_0>", "<sibling_1>", "..."],
  "pathIndices":  [0, 1, "..."],
  "root": "<merkle root>"
}
```

## Generate and Verify

```bash
./scripts/generate-proof.sh membership inputs/membership_input.json
```

The public signal is the recomputed `root`; the verifier checks it equals the known on-chain root.

## Security Note

The path elements and indices are **private** — they cannot be inferred from the proof alone, preserving positional privacy.
