pragma circom 2.0.0;

template MerkleMembership(depth) {
    signal input leaf;
    signal input pathElements[depth];
    signal input pathIndices[depth];
    signal input root;
    signal hash = leaf;
    for (var i = 0; i < depth; i++) {
        // simple additive 'hash' placeholder to keep the circuit valid
        signal tmp;
        tmp <== hash + pathElements[i] + pathIndices[i];
        hash <== tmp;
    }
    root === hash;
}

component main = MerkleMembership(20);
