# Trusted Setup Ceremony

Groth16 requires a two-phase trusted setup. Phase 1 (Powers of Tau) is universal; Phase 2 is circuit-specific.

## Phase 1 — Powers of Tau

You can use an existing ceremony transcript or run your own:

```bash
# Download an existing Powers of Tau (2^20 constraints max)
wget https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_20.ptau \
     -O ptau/powersOfTau_20.ptau

# Verify integrity
snarkjs powersoftau verify ptau/powersOfTau_20.ptau
```

For production circuits, use a ceremony with at least as many constraints as your largest circuit. Check `docs/ARCHITECTURE.md` for constraint counts.

## Phase 2 — Circuit-Specific Setup

Run phase 2 for each circuit:

```bash
CIRCUIT=identity  # change for each circuit

# 1. Compile
circom ${CIRCUIT}.circom --r1cs --wasm --sym -o build/${CIRCUIT}/

# 2. Start phase 2
snarkjs groth16 setup \
  build/${CIRCUIT}/${CIRCUIT}.r1cs \
  ptau/powersOfTau_20.ptau \
  build/${CIRCUIT}/${CIRCUIT}_0000.zkey

# 3. Contribute randomness (repeat for multiple contributors)
snarkjs zkey contribute \
  build/${CIRCUIT}/${CIRCUIT}_0000.zkey \
  build/${CIRCUIT}/${CIRCUIT}_0001.zkey \
  --name="Contributor 1" -v

# 4. Apply a beacon (optional but recommended)
snarkjs zkey beacon \
  build/${CIRCUIT}/${CIRCUIT}_0001.zkey \
  build/${CIRCUIT}/${CIRCUIT}_final.zkey \
  0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f 10 \
  -n="Final Beacon phase2"

# 5. Export verification key
snarkjs zkey export verificationkey \
  build/${CIRCUIT}/${CIRCUIT}_final.zkey \
  build/${CIRCUIT}/verification_key.json

# 6. Verify the final zkey
snarkjs zkey verify \
  build/${CIRCUIT}/${CIRCUIT}.r1cs \
  ptau/powersOfTau_20.ptau \
  build/${CIRCUIT}/${CIRCUIT}_final.zkey
```

## Automate with make

```bash
make setup CIRCUIT=identity
```

See `scripts/setup.sh` for the full automation script.

## Security Considerations

- **Never reuse** a zkey between circuits.
- The ceremony is only as secure as the weakest contributor — use multi-party MPC in production.
- Archive and publish all contribution transcripts for public auditability.
