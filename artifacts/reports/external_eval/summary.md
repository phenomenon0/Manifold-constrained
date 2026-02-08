# External Evaluation Summary

- timestamp_utc: 2026-02-08T11:25:51Z
- dataset: mmlu-tiny
- seed: 424242

| Model | N | Accuracy | ECE | Brier | AUROC | Confident-Wrong@0.8 |
|---|---:|---:|---:|---:|---:|---:|
| `ar_baseline` | 100 | 0.5200 | 0.0844 | 0.2091 | 0.2823 | 0.1538 |
| `diffusion_baseline` | 100 | 0.3500 | 0.6492 | 0.6489 | 0.6873 | 0.6500 |
| `self_consistency` | 100 | 0.6500 | 0.1162 | 0.1811 | 0.1591 | 0.0000 |
