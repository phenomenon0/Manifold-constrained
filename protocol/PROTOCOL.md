# MCQSMoE Paper-Rigor Protocol

Date: 2026-02-06

## Objective

Demonstrate paper-grade rigor for MCQSMoE claims through controlled tests,
ablations, and reproducible artifact generation on current hardware.

## Claims Under Test

1. MCQSMoE routing and composition are deterministic and stable.
2. MCQSMoE forward path provides throughput gains over selected reference paths.
3. Compression/quantization components preserve functional correctness within expected tolerance.

## Methodology Requirements

1. Fixed command lines, seeds, and runtime options per run.
2. No claim from single number only; keep raw logs and summaries.
3. Every claim maps to:
- one primary metric,
- one verification test,
- one artifact path.

## Experimental Tracks

### Track Q: Quality/Correctness

- Run focused QSMoE correctness tests:
- `TestQSMoELayerCreation`
- `TestQSMoEForwardBasic`
- `TestQSMoERoutingDeterminism`
- `TestQSMoESpecialization`
- `TestQSMoEAuditEntropy`
- `TestQSMoECombineMethods`

Primary outputs:
- pass/fail
- audit logs for entropy/specialization behavior

### Track QS: Quality Multi-Seed Robustness

- Run the same quality suite across fixed shuffle seeds:
- `MCSQOE_QUALITY_SEEDS` default: `11 23 47 101 211`
- command base:
- `go test -v -count=1 -shuffle=<seed> -timeout=20m -run 'TestQSMoE(...)$' ./foundation_models`

Primary outputs:
- per-seed pass/fail
- strict status (`QUALITY_MULTI_SEED_STATUS`)
- seed coverage count

### Track P: Performance

- Run targeted benchmarks:
- `BenchmarkQSMoEForward`
- `BenchmarkQSMoEForwardLarge`
- `BenchmarkParallelForward_medium_b32`
- `BenchmarkWorkspaceForward_medium_b32`

Primary outputs:
- ns/op
- GFLOPS
- tok/s (where emitted)
- allocs/op

### Track PS: Performance Multi-Run Statistics

- Run Track P benchmark command multiple times (`MCSQOE_MULTI_RUNS`, default `5`).
- For each benchmark target, collect per-run samples and compute:
- mean
- sample standard deviation
- 95% confidence interval (`1.96 * std / sqrt(n)`)

Primary outputs:
- `results/perf_multirun_samples.tsv`
- `results/perf_multirun_stats.csv`
- `results/perf_multirun_summary.md`
- strict status (`PERF_MULTI_RUN_STATUS`)

### Track DB: Dense Matched Baseline

- Run QSMoE and dense matched baselines under a matched parameter/compute setup:
- `BenchmarkQSMoEForward`
- `BenchmarkQSMoEForwardLarge`
- `BenchmarkDenseMatchedForward`
- `BenchmarkDenseMatchedForwardLarge`

Primary outputs:
- `results/logs/dense_baseline.log`
- `results/dense_baseline_summary.md`
- `results/dense_baseline_summary.json`
- strict status (`DENSE_BASELINE_STATUS`)

### Track T: Trained-Artifact Parity Gate

- Purpose: prevent paper-parity claims when trained/exported artifacts are absent.
- Hard precheck (must exist):
- `examples/toy_mcqsmoe/exports/moe_v2_optimized/manifest.json`
- `examples/toy_mcqsmoe/exports/run_001/manifest.json`
- `examples/toy_mcqsmoe/exports/proof/manifest.json`
- `examples/toy_mcqsmoe/exports/proof/golden/golden_manifest.json`
- `testdata/golden_qmln.shard`

- Tests executed only after precheck:
- `TestLoadExportedModel`
- `TestExportedModelInference`
- `TestImportRealPyTorchExport`
- `TestImportFullFFN`
- `TestGoldenPyTorchComparison`
- `TestManifoldInvariants`
- `TestGoldenDeterminism`
- `TestE2EPyTorchGolden`

- Gate behavior:
- missing required artifacts => immediate FAIL
- any skip in Track T run => FAIL
- all required tests pass with no skips => PASS

### Track X: External Evaluation Harness

- Run a fixed external-style MCQA harness using `diffusion_jeep` on `mmlu-tiny`.
- Evaluate baseline models with fixed seed:
- `ar_baseline`
- `diffusion_baseline`
- `self_consistency`

Primary outputs:
- `results/logs/external_eval.log`
- `results/external_eval/summary.md`
- `results/external_eval/summary.json`
- strict status (`EXTERNAL_EVAL_STATUS`)

## Acceptance Gates

1. `Gate A`: quality suite passes fully.
2. `Gate B`: quality multi-seed suite passes for all configured seeds.
3. `Gate C`: performance suite completes and emits benchmark lines for all targets.
4. `Gate D`: performance multi-run suite passes with full target coverage.
5. `Gate E`: dense matched baseline suite passes with full benchmark coverage.
6. `Gate F`: Track T passes (trained artifacts present, no skip, tests pass).
7. `Gate G`: external evaluation harness writes complete summary artifacts.
8. `Gate H`: summary artifacts are generated (`summary.md` and `summary.json`).

## Known Current Gaps (to close next)

1. External benchmark currently uses tiny synthetic proxies; add real public leaderboard datasets.
2. Robustness still focuses on test-order seeds; add model/data stochasticity controls.
3. Hardware noise controls (thermal/power state pinning) for tighter CI stability.
