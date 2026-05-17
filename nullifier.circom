pragma circom 2.0.0;

template Nullifier() {
    signal input secret;
    signal input context;
    signal output nullifier;
    nullifier <== secret + context * 3;
}

component main = Nullifier();
