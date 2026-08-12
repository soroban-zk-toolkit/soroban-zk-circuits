#!/usr/bin/env bash
# verify-proof.sh — Local proof verification helper
# Usage: ./scripts/verify-proof.sh <circuit_name> [proof_json] [public_json]
set -euo pipefail

CIRCUIT="${1:?Usage: $0 <circuit_name> [proof_json] [public_json]}"
PROOF="${2:-build/${CIRCUIT}/proof.json}"
PUBLIC="${3:-build/${CIRCUIT}/public.json}"
VKEY="build/${CIRCUIT}/verification_key.json"

echo "==> Verifying proof for circuit: ${CIRCUIT}"
echo "    proof:            ${PROOF}"
echo "    public signals:   ${PUBLIC}"
echo "    verification key: ${VKEY}"

if [[ ! -f "${VKEY}" ]]; then
  echo "Error: verification key not found: ${VKEY}"
  echo "Run: ./scripts/setup.sh ${CIRCUIT}"
  exit 1
fi

snarkjs groth16 verify "${VKEY}" "${PUBLIC}" "${PROOF}"
