# Changelog

All notable changes to this project are documented here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
This project uses [Semantic Versioning](https://semver.org/).

---

## [Unreleased]

### Added
- `docs/ARCHITECTURE.md` — ZK circuit architecture overview
- `docs/CIRCOM_GUIDE.md` — Circom intro for Stellar developers
- `docs/TRUSTED_SETUP.md` — Trusted setup ceremony instructions
- `docs/PROOF_GENERATION.md` — Proof generation guide
- `docs/CIRCUIT_REFERENCE.md` — Full circuit reference
- `SECURITY.md` — Security policy
- `CHANGELOG.md` — This file
- `ROADMAP.md` — Project roadmap
- GitHub issue templates and pull request template
- Helper scripts: `setup.sh`, `generate-proof.sh`, `verify-proof.sh`
- Example walkthroughs for identity, membership, and range-proof circuits

---

## [0.1.0-alpha] — 2026-08-12

### Added
- `identity.circom` — Identity commitment circuit
- `membership.circom` — Merkle-tree membership proof circuit
- `nullifier.circom` — Nullifier generation circuit
- `range_proof.circom` — Range proof circuit
- `Makefile` — Build automation
- `package.json` — Node.js dependencies (snarkjs)
- `.github/` — CI workflows and code owners
- `CONTRIBUTING.md` — Contribution guidelines
- `.gitignore` and `.env.example`
