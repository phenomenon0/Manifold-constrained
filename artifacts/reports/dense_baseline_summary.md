# Dense Matched Baseline Summary

- timestamp_utc: 2026-02-08T11:25:47Z
- benchmark_mode: matched_parameter_budget
- q_small_ns_per_op: 9384330
- dense_small_ns_per_op: 11443170
- q_large_ns_per_op: 153667814
- dense_large_ns_per_op: 185456935
- speedup_small_dense_over_q: 1.2194x
- speedup_large_dense_over_q: 1.2069x

| Case | QSMoE ns/op | Dense Matched ns/op | Dense/QSMoE Speedup |
|---|---:|---:|---:|
| small | 9384330 | 11443170 | 1.2194x |
| large | 153667814 | 185456935 | 1.2069x |

Artifacts:
- `foundation_models/paper_mcsqoe/results/logs/dense_baseline.log`
- `foundation_models/paper_mcsqoe/results/dense_baseline_summary.md`
- `foundation_models/paper_mcsqoe/results/dense_baseline_summary.json`
