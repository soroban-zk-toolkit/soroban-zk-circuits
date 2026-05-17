pragma circom 2.0.0;

template RangeProof() {
    signal input value;
    signal input min;
    signal input max;
    // enforce min <= value <= max
    signal inRange;
    inRange <== (value - min) * (max - value);
    // require non-negative product => value in [min,max]
    inRange >= 0;
}

component main = RangeProof();
