# Age Range Proof Circuit

## Overview

An age range proof allows a user to prove that their age satisfies a minimum threshold (e.g., age ≥ 18) without revealing their exact date of birth or age. This is a classic application of zero-knowledge range proofs, useful for KYC compliance, age-gated content, and privacy-preserving identity verification.

## Problem Statement

Given:
- A user's birth date (private input)
- The current date (public input)
- An age threshold (public input, e.g., 18 years)

Prove: `currentDate - birthDate >= threshold * daysPerYear`

Without revealing: the exact birth date or computed age.

## Approach: Range Proof via Bit Decomposition

The core technique is to prove that a value `v` satisfies `v >= 0` (i.e., is non-negative) by decomposing it into bits. If `v = ageInDays - 18*365`, then proving all bits of `v` are 0 or 1 (and `v` fits in N bits) proves `v >= 0`, which means age >= 18.

### Key Circom Primitives

- `Num2Bits(n)`: Decomposes a field element into `n` bits (implicitly proves 0 ≤ value < 2^n)
- `LessThan(n)`: Proves one value is strictly less than another
- `GreaterEqThan(n)`: Proves one value is greater than or equal to another

## Circuit Design

```circom
pragma circom 2.0.0;

include "comparators.circom";  // from circomlib

// Proves age >= minAge without revealing exact birthdate
template AgeRangeProof() {
    // Private inputs
    signal input birthYear;      // e.g., 1995
    signal input birthMonth;     // 1-12
    signal input birthDay;       // 1-31

    // Public inputs
    signal input currentYear;    // e.g., 2024
    signal input currentMonth;   // 1-12
    signal input currentDay;     // 1-31
    signal input minAge;         // e.g., 18

    // Compute approximate age in years (simplified: using year difference)
    // For production: use full date arithmetic with month/day adjustment
    signal ageInYears;
    ageInYears <== currentYear - birthYear;

    // Prove ageInYears >= minAge
    // GreaterEqThan(n) requires n bits to represent the values
    component ageCheck = GreaterEqThan(8);  // 8 bits supports values 0-255
    ageCheck.in[0] <== ageInYears;
    ageCheck.in[1] <== minAge;

    // This constraint fails if ageInYears < minAge
    ageCheck.out === 1;
}

component main {public [currentYear, currentMonth, currentDay, minAge]} = AgeRangeProof();
```

## More Precise Date Arithmetic

For production accuracy (avoiding off-by-one errors around birthdays):

```circom
pragma circom 2.0.0;

include "comparators.circom";

// Convert (year, month, day) to a day count for comparison
// Using a simplified Julian Day Number approach
template DateToDays() {
    signal input year;
    signal input month;
    signal input day;
    signal output totalDays;

    // Approximate: days = year * 365 + month * 30 + day
    // (Production code should use a lookup table for accurate month lengths)
    totalDays <== year * 365 + month * 30 + day;
}

template PreciseAgeRangeProof() {
    signal input birthYear;
    signal input birthMonth;
    signal input birthDay;

    signal input currentYear;
    signal input currentMonth;
    signal input currentDay;
    signal input minAgeInDays;   // e.g., 18 * 365 = 6570

    component birthDays = DateToDays();
    birthDays.year <== birthYear;
    birthDays.month <== birthMonth;
    birthDays.day <== birthDay;

    component currentDays = DateToDays();
    currentDays.year <== currentYear;
    currentDays.month <== currentMonth;
    currentDays.day <== currentDay;

    // ageInDays = currentDays - birthDays; must be >= minAgeInDays
    component ageCheck = GreaterEqThan(16); // 16 bits for up to ~179 years
    ageCheck.in[0] <== currentDays.totalDays - birthDays.totalDays;
    ageCheck.in[1] <== minAgeInDays;

    ageCheck.out === 1;
}

component main {public [currentYear, currentMonth, currentDay, minAgeInDays]} = PreciseAgeRangeProof();
```

## Commitment to Birth Date

In a real system, the birth date is committed to a public value (e.g., stored in an ID credential). The circuit proves the committed birth date satisfies the age constraint without revealing it:

```circom
// birthDateHash = Poseidon(birthYear, birthMonth, birthDay, salt)
// Public input: birthDateHash (from the credential)
// Private inputs: birthYear, birthMonth, birthDay, salt

component hashCheck = Poseidon(4);
hashCheck.inputs[0] <== birthYear;
hashCheck.inputs[1] <== birthMonth;
hashCheck.inputs[2] <== birthDay;
hashCheck.inputs[3] <== salt;
hashCheck.out === birthDateHash;  // Verifies the private date matches the commitment
```

## Constraint Count

| Component | Constraints |
|---|---|
| DateToDays (×2) | ~20 |
| GreaterEqThan(16) | ~64 |
| Poseidon(4) commitment | ~300 |
| **Total** | **~384** |

This is extremely cheap compared to SHA-based approaches.

## Security Considerations

1. **Salt the commitment**: Without a salt, birth date commitments are vulnerable to brute-force (only ~36,500 possibilities for adults).
2. **Current date trust**: The verifier must trust or anchor the current date (e.g., from a blockchain timestamp).
3. **Off-by-one in birthday**: Simplified year arithmetic may grant age 18 before the actual birthday; use full day-count arithmetic for precision.
4. **Overflow protection**: Ensure bit widths in comparators are sufficient to prevent wrap-around exploits.

## References

- circomlib comparators: https://github.com/iden3/circomlib/blob/master/circuits/comparators.circom
- Semaphore identity protocol — uses similar commitment + range proof patterns
- ZK-identity age proofs: https://eprint.iacr.org/2022/695.pdf
