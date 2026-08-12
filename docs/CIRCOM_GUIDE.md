# Intro to Circom for Stellar Developers

## What is Circom?

Circom is a domain-specific language for writing arithmetic circuits. A circuit defines a set of constraints over a finite field; a prover uses a witness (private inputs) to satisfy those constraints and generate a compact proof that can be verified by anyone without learning the witness.

## Installation

```bash
# Install circom (requires Rust)
curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh
git clone https://github.com/iden3/circom.git
cd circom && cargo build --release
cp target/release/circom /usr/local/bin/

# Install snarkjs
npm install -g snarkjs
```

## Compiling a Circuit

```bash
circom identity.circom --r1cs --wasm --sym -o build/
```

This produces:
- `build/identity.r1cs` — constraint system
- `build/identity_js/identity.wasm` — witness generator
- `build/identity.sym` — symbol map for debugging

## Generating a Witness

Create `input.json` with your circuit's input signals, then:

```bash
node build/identity_js/generate_witness.js \
  build/identity_js/identity.wasm \
  input.json \
  build/witness.wtns
```

## Generating a Proof

```bash
snarkjs groth16 prove \
  build/identity.zkey \
  build/witness.wtns \
  build/proof.json \
  build/public.json
```

## Verifying Locally

```bash
snarkjs groth16 verify \
  build/verification_key.json \
  build/public.json \
  build/proof.json
```

## Key Concepts

### Signals
Signals are the wires of the circuit. They can be:
- **input** — provided by the prover (private) or verifier (public)
- **output** — derived from inputs, always public
- **intermediate** — internal computation wires

### Constraints
A constraint is an equation of the form `A * B = C` where A, B, C are linear combinations of signals. The prover must find a valid assignment (witness) for all signals.

### Templates
Circom templates are reusable circuit components, similar to functions:

```circom
template IsEqual() {
    signal input in[2];
    signal output out;
    component isz = IsZero();
    isz.in <== in[1] - in[0];
    out <== isz.out;
}
```

## Further Reading

- [Circom documentation](https://docs.circom.io)
- [snarkjs README](https://github.com/iden3/snarkjs)
- [ZK-learning.org](https://zk-learning.org)
