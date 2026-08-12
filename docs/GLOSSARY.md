# ZK and Cryptography Glossary

A reference for terms used throughout this repository.

---

**Arithmetic circuit**
A computation expressed as additions and multiplications over a finite field. Circom compiles templates to arithmetic circuits.

**BN128 (alt_bn128)**
An elliptic curve used by Ethereum and Soroban for efficient pairing operations. All circuits in this repo target BN128.

**Circom**
A domain-specific language for writing arithmetic circuits. Compiles to R1CS.

**Commitment scheme**
A cryptographic primitive that lets a prover commit to a value without revealing it, then later reveal it. Commitments are binding (can't change the value) and hiding (conceals the value).

**Constraint**
An arithmetic equation that a witness must satisfy. In R1CS the form is A·B = C.

**Groth16**
A zk-SNARK proving system with constant-size proofs and efficient verification. Requires a trusted setup per circuit.

**Merkle tree**
A binary tree where each node is a hash of its children. Merkle proofs allow proving membership in O(log n) hashes.

**Nullifier**
A unique value derived from a secret that prevents double-spending. Once a nullifier is published on-chain, the associated secret cannot be reused.

**Poseidon hash**
A ZK-friendly hash function optimised for arithmetic circuits. Used in identity, membership, and nullifier circuits.

**Powers of Tau**
A universal trusted setup ceremony for zk-SNARKs. The output ptau file is the input to circuit-specific phase-2 setup.

**Proof**
A compact piece of data (π_A, π_B, π_C) that convinces a verifier a computation was performed correctly without revealing the private inputs.

**Public signal**
A circuit output or designated input that is revealed to the verifier. Appears in `public.json` after proof generation.

**R1CS (Rank-1 Constraint System)**
The constraint representation produced by Circom. A system of equations A·B = C over a field.

**Snarkjs**
A JavaScript/WASM library for Groth16 proof generation and verification. Used by this repo's scripts.

**Soundness**
A property of a proof system: a dishonest prover cannot produce a valid proof for a false statement (except with negligible probability).

**Trusted setup**
A one-time ceremony that generates cryptographic parameters for a proving system. If the toxic waste from setup is not destroyed, proofs can be forged.

**Verification key**
Public parameters (derived from trusted setup) that the verifier uses to check a proof. Safe to publish.

**Witness**
A valid assignment of values to all signals in a circuit (public and private) that satisfies all constraints.

**Zero-knowledge**
A property of a proof system: the proof reveals nothing about the private inputs beyond what is implied by the public outputs.

**zk-SNARK**
Zero-Knowledge Succinct Non-Interactive Argument of Knowledge. A proof system with small proofs, fast verification, and the zero-knowledge property.

**zkey**
The circuit-specific proving key generated during phase-2 trusted setup. Contains both the proving and (indirectly) the verification key.
