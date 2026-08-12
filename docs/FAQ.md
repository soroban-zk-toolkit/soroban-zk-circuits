# Frequently Asked Questions

## General

**Q: What proving system do these circuits use?**
A: Groth16 over BN128. It produces constant-size proofs (~200 bytes) and fast on-chain verification.

**Q: Are these circuits audited?**
A: No. They are unaudited research-grade circuits. Do not use in production without an independent security audit.

**Q: What is the minimum Powers of Tau size I need?**
A: The largest circuit (membership, depth 20) requires ~8 000 constraints. A 2^13 (8 192) ptau file is the minimum; we recommend 2^20 for headroom.

---

## Setup

**Q: Can I use an existing Powers of Tau file?**
A: Yes. Download from the Hermez or Iden3 ceremony archives. Verify the file hash before use.

**Q: How long does setup take?**
A: Phase 1 is reused. Phase 2 per circuit takes 10–60 seconds on a modern laptop.

**Q: Do I need to redo setup after changing a circuit?**
A: Yes. Any change to the circuit's r1cs invalidates the zkey. Re-run `./scripts/setup.sh <circuit>`.

---

## Proof Generation

**Q: Why is witness generation slow?**
A: The WASM witness generator is single-threaded. For production throughput, use a native C++ witness generator (compiled from circom with `--c`).

**Q: Can I generate proofs in the browser?**
A: Yes, using the WASM witness generator and snarkjs in the browser. See issue #11 for WASM packaging progress.

**Q: How large are the proof files?**
A: A Groth16 proof JSON is ~1 KB. The verification key is ~2 KB.

---

## Soroban Integration

**Q: How do I verify a proof on Soroban?**
A: Use the companion `soroban-zk-verifier` contract. Submit the proof and public signals via `verify_<circuit>_proof`.

**Q: What does the verifier contract cost in fees?**
A: Groth16 verification uses the BN128 pairing precompile. Fee estimates will be published with testnet integration.

---

## Contributing

**Q: How do I propose a new circuit?**
A: Open a GitHub issue using the feature request template and describe the circuit's inputs, outputs, and use case.

**Q: What is the review process for new circuits?**
A: All circuits must pass the security checklist in `docs/SECURITY_CHECKLIST.md` and receive at least one review from a maintainer before merge.
