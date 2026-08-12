#!/usr/bin/env bash
# setup.sh — Trusted setup helper for soroban-zk-circuits
# Usage: ./scripts/setup.sh <circuit_name> [ptau_file]
set -euo pipefail

CIRCUIT="${1:?Usage: $0 <circuit_name> [ptau_file]}"
PTAU="${2:-ptau/powersOfTau_20.ptau}"
BUILD="build/${CIRCUIT}"

echo "==> Setting up circuit: ${CIRCUIT}"
echo "==> Powers of Tau: ${PTAU}"

mkdir -p "${BUILD}" ptau

# Download ptau if not present
if [[ ! -f "${PTAU}" ]]; then
  echo "==> Downloading Powers of Tau (2^20)..."
  wget -q https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_20.ptau \
       -O "${PTAU}"
fi

# Compile circuit
echo "==> Compiling ${CIRCUIT}.circom..."
circom "${CIRCUIT}.circom" --r1cs --wasm --sym -o "${BUILD}/"

# Phase 2 setup
echo "==> Running phase 2 setup..."
snarkjs groth16 setup \
  "${BUILD}/${CIRCUIT}.r1cs" \
  "${PTAU}" \
  "${BUILD}/${CIRCUIT}_0000.zkey"

# Contribute entropy
echo "==> Contributing entropy..."
snarkjs zkey contribute \
  "${BUILD}/${CIRCUIT}_0000.zkey" \
  "${BUILD}/${CIRCUIT}_final.zkey" \
  --name="Setup contributor" -v -e="$(head -c 64 /dev/urandom | base64)"

# Export verification key
echo "==> Exporting verification key..."
snarkjs zkey export verificationkey \
  "${BUILD}/${CIRCUIT}_final.zkey" \
  "${BUILD}/verification_key.json"

echo "==> Setup complete for ${CIRCUIT}"
echo "    zkey:             ${BUILD}/${CIRCUIT}_final.zkey"
echo "    verification_key: ${BUILD}/verification_key.json"
