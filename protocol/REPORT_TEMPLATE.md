# MCQSMoE Paper-Rigor Report

## 1. Scope

- Objective:
- Version/commit:
- Hardware:

## 2. Experimental Protocol

- Protocol file: `foundation_models/paper_mcsqoe/PROTOCOL.md`
- Matrix file: `foundation_models/paper_mcsqoe/EXPERIMENT_MATRIX.yaml`
- Run command:

```bash
cd Agent-GO
./foundation_models/paper_mcsqoe/scripts/40_run_all.sh
```

## 3. Quality/Correctness Results

- Suite status:
- Determinism evidence:
- Routing/specialization observations:
- Artifact: `foundation_models/paper_mcsqoe/results/logs/quality.log`

## 4. Performance Results

- QSMoE forward (small):
- QSMoE forward (large):
- Parallel medium b32:
- Workspace medium b32:
- Artifact: `foundation_models/paper_mcsqoe/results/logs/perf.log`

## 5. Claim Mapping

1. Claim:
- Evidence:
- Artifact:

2. Claim:
- Evidence:
- Artifact:

## 6. Dense Baseline Parity

- Dense baseline status:
- Small-case dense/QSMoE speedup:
- Large-case dense/QSMoE speedup:
- Artifacts:
  - `foundation_models/paper_mcsqoe/results/logs/dense_baseline.log`
  - `foundation_models/paper_mcsqoe/results/dense_baseline_summary.md`

## 7. External Harness Snapshot

- External eval status:
- Dataset:
- Model rows captured:
- Artifact:
  - `foundation_models/paper_mcsqoe/results/logs/external_eval.log`
  - `foundation_models/paper_mcsqoe/results/external_eval/summary.md`

## 8. Statistical Notes

- Quality multi-seed status:
- Quality seed set:
- Perf multi-run status:
- Perf runs:
- Variance/CI method:
- Artifacts:
  - `foundation_models/paper_mcsqoe/results/logs/quality_multiseed.log`
  - `foundation_models/paper_mcsqoe/results/logs/perf_multirun.log`
  - `foundation_models/paper_mcsqoe/results/perf_multirun_summary.md`

## 9. Limitations

- Known gaps:
- External validity notes:

## 10. Reproducibility

- Env snapshot: `foundation_models/paper_mcsqoe/results/env_snapshot.txt`
- Summary: `foundation_models/paper_mcsqoe/results/summary.md`
- Summary JSON: `foundation_models/paper_mcsqoe/results/summary.json`
