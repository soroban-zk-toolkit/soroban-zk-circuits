# Roadmap

## v0.1.0 — Core Circuits (Target: October 2026)

- [x] Identity commitment circuit
- [x] Merkle membership proof circuit
- [x] Nullifier generation circuit
- [x] Range proof circuit
- [ ] Trusted setup ceremony (Powers of Tau)
- [ ] Groth16 test vectors for all circuits
- [ ] snarkjs unit test suite
- [ ] Makefile targets for setup, witness, proof, verify

## v0.2.0 — Audit Ready (Target: January 2027)

- [ ] Independent security audit of all circuits
- [ ] Optimised constraint counts
- [ ] Age verification circuit (ZK age > 18)
- [ ] Batch membership proof circuit
- [ ] WASM compilation for browser-side proving
- [ ] Powers of Tau verification script
- [ ] Complete API documentation

## v0.3.0 — Ecosystem Integration (Target: Q2 2027)

- [ ] Integration tests with `soroban-zk-verifier` contract
- [ ] End-to-end proof-verify on Stellar testnet
- [ ] SDK wrapper for proof generation (TypeScript)
- [ ] Soroban contract integration examples
- [ ] Devnet and mainnet deployment guides

## Future Ideas

- Recursive SNARK support (Nova / Plonky2)
- Confidential token transfer circuit
- Threshold signature circuit
- ZK reputation system
