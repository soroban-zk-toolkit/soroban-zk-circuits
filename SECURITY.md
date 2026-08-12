# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| main    | Yes       |

## Reporting a Vulnerability

**Do not open a public issue for security vulnerabilities.**

Please report security issues by emailing **security@soroban-zk-toolkit.dev** with:

1. A description of the vulnerability
2. Steps to reproduce or a proof-of-concept
3. The affected circuit(s)
4. Potential impact

We will acknowledge receipt within 48 hours and aim to provide a fix or mitigation within 14 days for critical issues.

## Scope

In-scope:
- Under-constrained signals in any circuit (soundness vulnerabilities)
- Forged proofs that pass verification
- Witness generation bugs that produce incorrect public outputs
- Trusted setup vulnerabilities

Out of scope:
- Denial-of-service on the proof generation CLI
- Bugs in third-party dependencies (report to upstream)

## Audit Status

| Circuit      | Status       | Auditor      |
|--------------|-------------|--------------|
| identity     | Unaudited   | —            |
| membership   | Unaudited   | —            |
| nullifier    | Unaudited   | —            |
| range_proof  | Unaudited   | —            |

> ⚠️ These circuits have **not yet been professionally audited**. Do not use them in production without an independent security review.
