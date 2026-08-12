#!/usr/bin/env bash
# generate-proof.sh — Proof generation helper for soroban-zk-circuits
# Usage: ./scripts/generate-proof.sh <circuit_name> <input_json>
set -euo pipefail

CIRCUIT="${1:?Usage: $0 <circuit_name> <input_json>}"
INPUT="${2:?Usage: $0 <circuit_name> <input_json>}"
BUILD="build/${CIRCUIT}"

echo "==> Generating proof for circuit: ${CIRCUIT}"
echo "==> Input file: ${INPUT}"

if [[ ! -f "${BUILD}/${CIRCUIT}_final.zkey" ]]; then
  echo "Error: zkey not found at ${BUILD}/${CIRCUIT}_final.zkey"
  echo "Run: ./scripts/setup.sh ${CIRCUIT}"
  exit 1
fi

# Generate witness
echo "==> Generating witness..."
node "${BUILD}/${CIRCUIT}_js/generate_witness.js" \
  "${BUILD}/${CIRCUIT}_js/${CIRCUIT}.wasm" \
  "${INPUT}" \
  "${BUILD}/witness.wtns"

# Generate proof
echo "==> Generating Groth16 proof..."
snarkjs groth16 prove \
  "${BUILD}/${CIRCUIT}_final.zkey" \
  "${BUILD}/witness.wtns" \
  "${BUILD}/proof.json" \
  "${BUILD}/public.json"

echo "==> Proof generated:"
echo "    proof:  ${BUILD}/proof.json"
echo "    public: ${BUILD}/public.json"

# Quick local verification
echo "==> Verifying proof locally..."
snarkjs groth16 verify \
  "${BUILD}/verification_key.json" \
  "${BUILD}/public.json" \
  "${BUILD}/proof.json" && echo "Proof is VALID"
