# ECDSA Signature Verification Circuit

## Overview

ECDSA (Elliptic Curve Digital Signature Algorithm) signature verification is a fundamental primitive in blockchain systems. Implementing ECDSA verification as a ZK circuit allows proving that a valid signature exists for a message without revealing the private key, and can be used to prove account ownership or authenticate transactions in zero-knowledge.

## ECDSA Signature Scheme (secp256k1)

A standard ECDSA signature over secp256k1 consists of:
- **r, s**: two 256-bit integers (the signature components)
- **pubkey**: a point on the secp256k1 curve (compressed or uncompressed)
- **message hash**: a 256-bit hash of the signed message (typically keccak256)

Verification checks: `r == (k·G).x mod n` and `s == k^-1 · (hash + r·privkey) mod n`, where G is the curve generator and n is the curve order.

## Why ECDSA in ZK is Expensive

ECDSA verification requires:
1. **Field arithmetic over secp256k1**: The curve operates over a 256-bit prime field, but Circom circuits run over BN128 (~254-bit). This mismatch forces "non-native" field arithmetic.
2. **Elliptic curve point operations**: Scalar multiplication `k·G` involves ~256 double-and-add steps.
3. **Modular inversion**: Computing `s^-1 mod n` requires extended Euclidean algorithm constraints.
4. **Large numbers**: 256-bit integers must be split into smaller limbs for circuit compatibility.

Typical constraint count: **~1.5–2 million constraints** for secp256k1 ECDSA.

## Circuit Architecture

The verification circuit is split into modular components:

```
ECDSAVerify
├── Sha256 / Keccak256   (hash message)
├── BigInt arithmetic    (non-native field ops)
│   ├── BigMult          (256-bit multiplication)
│   ├── BigAdd           (256-bit addition)
│   └── BigModInv        (modular inverse)
├── Secp256k1 EC ops
│   ├── Secp256k1Add     (point addition)
│   └── Secp256k1Mul     (scalar multiplication)
└── ECDSAVerifyCore      (combine r, s, pubkey, hash)
```

## Circom Circuit Sketch

```circom
pragma circom 2.0.0;

include "ecdsa.circom";   // from circom-ecdsa library
include "keccak.circom";

// Proves: given (r, s, pubkey), message was signed by owner of pubkey
template ECDSASignatureVerify(n, k) {
    // n = bits per limb (e.g. 64), k = number of limbs (e.g. 4)
    // n * k = 256 bits total

    signal input r[k];          // signature r component (in limbs)
    signal input s[k];          // signature s component (in limbs)
    signal input msghash[k];    // keccak256 of message (in limbs)
    signal input pubkey[2][k];  // (x, y) coordinates of public key

    // Verify the ECDSA signature
    component verify = ECDSAVerifyNoPubkeyCheck(n, k);
    verify.r <== r;
    verify.s <== s;
    verify.msghash <== msghash;
    verify.pubkey <== pubkey;

    // verify.result == 1 iff signature is valid
    verify.result === 1;
}

component main {public [r, s, msghash, pubkey]} = ECDSASignatureVerify(64, 4);
```

## Input Encoding

Inputs are encoded as arrays of 64-bit limbs in little-endian order:

```js
// Convert a hex string to 4 x 64-bit limbs
function toLimbs(hexStr) {
    const n = BigInt("0x" + hexStr);
    const mask = (1n << 64n) - 1n;
    return [
        n & mask,
        (n >> 64n) & mask,
        (n >> 128n) & mask,
        (n >> 192n) & mask,
    ];
}
```

## Constraint Optimization Strategies

| Technique | Impact |
|---|---|
| Use efficient circom-ecdsa (0xPARC) | Baseline ~1.5M constraints |
| Batch verify multiple signatures | Amortize fixed costs |
| Use STARK-based pre-verification | Offload heavy computation |
| Replace secp256k1 with Baby Jubjub | ~10x fewer constraints (but different curve) |

## Recommended Libraries

- **circom-ecdsa** (0xPARC): `https://github.com/0xPARC/circom-ecdsa` — production-grade secp256k1 ECDSA for Circom
- **snarkjs**: Trusted setup and proof generation compatible with circom-ecdsa
- **eth-sig-util**: JavaScript tooling for encoding Ethereum-compatible ECDSA inputs

## Use Cases in Stellar / Soroban Context

- **Wallet ownership proof**: Prove you control an Ethereum address without revealing your private key, useful for cross-chain bridge verification
- **Message authentication**: Prove a Stellar transaction was authorized by a known secp256k1 keypair
- **Account abstraction**: Allow secp256k1-signed operations to be verified by Soroban smart contracts via ZK proofs

## References

- 0xPARC circom-ecdsa: https://github.com/0xPARC/circom-ecdsa
- ECDSA Wikipedia: https://en.wikipedia.org/wiki/Elliptic_Curve_Digital_Signature_Algorithm
- Efficient ECDSA in ZK: https://geometry.xyz/notebook/Efficient-ECDSA-&-proof-of-private-key
