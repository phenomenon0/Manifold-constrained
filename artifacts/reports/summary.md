# MCQSMoE Paper-Rigor Summary

- timestamp_utc: 2026-02-08T11:25:51Z
- quality_status: PASS
- quality_tests_passed: 6
- quality_multiseed_status: PASS
- quality_multiseed_seeds: 5
- perf_status: PASS
- benchmark_lines_captured: 6
- perf_multirun_status: PASS
- perf_multirun_runs: 5
- dense_baseline_status: PASS
- dense_small_speedup: 1.2194x
- dense_large_speedup: 1.2069x
- track_t_status: PASS
- external_eval_status: PASS
- external_eval_models: 3

## Benchmarks

```text
BenchmarkParallelForward_medium_b32/Serial-16         	       4	 319607688 ns/op	         1.680 GFLOPS	       100.1 tok/s	   13984 B/op	     149 allocs/op
BenchmarkParallelForward_medium_b32/Parallel-16       	      19	  62754223 ns/op	         8.555 GFLOPS	       509.9 tok/s	        16.00 workers	  146731 B/op	     179 allocs/op
BenchmarkParallelForward_medium_b32/ParallelZeroCopy-16         	      18	  61589650 ns/op	         8.717 GFLOPS	       519.6 tok/s	        16.00 workers	   14874 B/op	     169 allocs/op
BenchmarkQSMoEForward-16                                        	     122	   9906717 ns/op	  752850 B/op	    1415 allocs/op
BenchmarkQSMoEForwardLarge-16                                   	       7	 155476874 ns/op	 5629213 B/op	    4871 allocs/op
BenchmarkWorkspaceForward_medium_b32-16                         	       4	 286068337 ns/op	         1.877 GFLOPS	   13752 B/op	     147 allocs/op
```

## Artifacts

- `foundation_models/paper_mcsqoe/results/env_snapshot.txt`
- `foundation_models/paper_mcsqoe/results/logs/quality.log`
- `foundation_models/paper_mcsqoe/results/logs/quality_multiseed.log`
- `foundation_models/paper_mcsqoe/results/logs/perf.log`
- `foundation_models/paper_mcsqoe/results/logs/perf_multirun.log`
- `foundation_models/paper_mcsqoe/results/perf_multirun_summary.md`
- `foundation_models/paper_mcsqoe/results/perf_multirun_stats.csv`
- `foundation_models/paper_mcsqoe/results/logs/dense_baseline.log`
- `foundation_models/paper_mcsqoe/results/dense_baseline_summary.md`
- `foundation_models/paper_mcsqoe/results/logs/track_t.log`
- `foundation_models/paper_mcsqoe/results/logs/external_eval.log`
- `foundation_models/paper_mcsqoe/results/external_eval/summary.md`
