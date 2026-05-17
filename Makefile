all: compile

compile:
	circom membership.circom --r1cs --wasm --sym -o build
	circom range_proof.circom --r1cs --wasm --sym -o build
	circom identity.circom --r1cs --wasm --sym -o build
	circom nullifier.circom --r1cs --wasm --sym -o build

clean:
	rm -rf build
