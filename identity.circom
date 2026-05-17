pragma circom 2.0.0;

template IdentityProof() {
    signal input secret;
    signal input pub;
    // simple equality check of a hash-like function
    signal computed;
    computed <== secret * 7 + 3;
    computed === pub;
}

component main = IdentityProof();
