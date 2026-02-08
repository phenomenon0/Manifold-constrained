# MCQSMoE Multi-Run Performance Summary

- timestamp_utc: 2026-02-08T11:25:40Z
- runs: 5
- benchtime: 1s

| Benchmark | N | Mean ns/op | Std ns/op | 95% CI ns/op | Mean tok/s | Std tok/s | 95% CI tok/s |
|---|---:|---:|---:|---:|---:|---:|---:|
| `BenchmarkParallelForward_medium_b32/Parallel` | 5 | 61140659.800 | 818759.392 | 717674.250 | 523.480 | 7.131 | 6.251 |
| `BenchmarkParallelForward_medium_b32/ParallelZeroCopy` | 5 | 62964948.400 | 2680357.539 | 2349436.971 | 508.960 | 21.456 | 18.807 |
| `BenchmarkParallelForward_medium_b32/Serial` | 5 | 324008174.200 | 9562130.403 | 8381576.848 | 98.818 | 2.870 | 2.516 |
| `BenchmarkQSMoEForward` | 5 | 9535480.200 | 303748.864 | 266247.618 | - | - | - |
| `BenchmarkQSMoEForwardLarge` | 5 | 155058012.000 | 1943352.485 | 1703423.558 | - | - | - |
| `BenchmarkWorkspaceForward_medium_b32` | 5 | 285124450.200 | 4896489.125 | 4291961.953 | - | - | - |

Artifacts:
- `foundation_models/paper_mcsqoe/results/perf_multirun_samples.tsv`
- `foundation_models/paper_mcsqoe/results/perf_multirun_stats.csv`
