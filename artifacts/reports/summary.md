# MCQSMoE Paper-Rigor Summary

- timestamp_utc: 2026-02-07T01:36:56Z
- quality_status: PASS
- quality_tests_passed: 6
- quality_multiseed_status: PASS
- quality_multiseed_seeds: 5
- perf_status: PASS
- benchmark_lines_captured: 6
- perf_multirun_status: PASS
- perf_multirun_runs: 5
- track_t_status: PASS

## Benchmarks

```text
BenchmarkParallelForward_medium_b32/Serial-16         	       4	 325271973 ns/op	         1.651 GFLOPS	        98.38 tok/s	   12864 B/op	     147 allocs/op
BenchmarkParallelForward_medium_b32/Parallel-16       	      18	  68765059 ns/op	         7.807 GFLOPS	       465.4 tok/s	        16.00 workers	  146786 B/op	     178 allocs/op
BenchmarkParallelForward_medium_b32/ParallelZeroCopy-16         	      18	  66496734 ns/op	         8.074 GFLOPS	       481.2 tok/s	        16.00 workers	   14499 B/op	     168 allocs/op
BenchmarkQSMoEForward-16                                        	     122	   9796913 ns/op	  752849 B/op	    1415 allocs/op
BenchmarkQSMoEForwardLarge-16                                   	       7	 158496995 ns/op	 5629200 B/op	    4871 allocs/op
BenchmarkWorkspaceForward_medium_b32-16                         	       4	 295446379 ns/op	         1.817 GFLOPS	   13440 B/op	     146 allocs/op
```

## Artifacts

- `foundation_models/paper_mcsqoe/results/env_snapshot.txt`
- `foundation_models/paper_mcsqoe/results/logs/quality.log`
- `foundation_models/paper_mcsqoe/results/logs/quality_multiseed.log`
- `foundation_models/paper_mcsqoe/results/logs/perf.log`
- `foundation_models/paper_mcsqoe/results/logs/perf_multirun.log`
- `foundation_models/paper_mcsqoe/results/perf_multirun_summary.md`
- `foundation_models/paper_mcsqoe/results/perf_multirun_stats.csv`
- `foundation_models/paper_mcsqoe/results/logs/track_t.log`
