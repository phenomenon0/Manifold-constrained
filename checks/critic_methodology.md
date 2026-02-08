# Critic Pass A: Methodology Rigor

Severity-ordered findings from supervisor review:

## Critical

1. Missing dense baseline under identical parameter/compute budget.
2. No external task benchmark harness (internal-only evidence).

## Major

1. Multi-seed currently shuffles test order, not model/data randomness.
2. Reference-path fairness controls are under-specified.
3. Performance CI with n=5 is thin and uses normal approximation.
4. Golden parity independence risk if artifacts are not externally generated.

## Minor

1. Hardware noise controls are not pinned.
2. Some benchmarks have NA tok/s fields.
3. Claim boundaries must stay narrower than SOTA framing.
