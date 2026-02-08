# MCQSMoE Multi-Run Performance Summary

- timestamp_utc: 2026-02-07T01:36:56Z
- runs: 5
- benchtime: 1s

| Benchmark | N | Mean ns/op | Std ns/op | 95% CI ns/op | Mean tok/s | Std tok/s | 95% CI tok/s |
|---|---:|---:|---:|---:|---:|---:|---:|
| `BenchmarkParallelForward_medium_b32/Parallel` | 5 | 64982566.400 | 2908588.271 | 2549490.028 | 493.220 | 21.466 | 18.816 |
| `BenchmarkParallelForward_medium_b32/ParallelZeroCopy` | 5 | 64298776.600 | 971098.111 | 851205.025 | 497.760 | 7.547 | 6.615 |
| `BenchmarkParallelForward_medium_b32/Serial` | 5 | 332476596.800 | 8571390.808 | 7513155.304 | 96.298 | 2.508 | 2.198 |
| `BenchmarkQSMoEForward` | 5 | 10009599.800 | 204889.517 | 179593.580 | - | - | - |
| `BenchmarkQSMoEForwardLarge` | 5 | 160866233.400 | 3401682.506 | 2981706.182 | - | - | - |
| `BenchmarkWorkspaceForward_medium_b32` | 5 | 291910267.800 | 5431725.527 | 4761117.345 | - | - | - |

Artifacts:
- `foundation_models/paper_mcsqoe/results/perf_multirun_samples.tsv`
- `foundation_models/paper_mcsqoe/results/perf_multirun_stats.csv`
