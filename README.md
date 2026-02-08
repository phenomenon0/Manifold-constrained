# MCQSMoE: Manifold-Constrained Quantized Sparse Mixture-of-Experts

Error-driven sparse routing with shared-anchor expert parameterization and low-bit quantized deltas.

## Model Architecture

MCQSMoE replaces learned router logits with **reconstruction-error routing**: each expert is an encoder-decoder compressor, and tokens are routed to the top-k experts with lowest reconstruction error.

Expert weights use a **shared-anchor + quantized delta** decomposition:

```
W_e = Retract(Anchor + Delta_e)
```

- **Anchor**: layer-level shared weight matrix (fp16, unit-norm rows on sphere manifold)
- **Delta_e**: per-expert low-bit offset (int4 or int2 groupwise symmetric quantization)
- **Retract**: row normalization back onto the manifold after perturbation

Inference decomposes linearly: `Y = X @ Anchor^T + X @ Delta_e^T` -- the anchor term is computed once, then only selected expert deltas are applied.

### Model Configurations

| Config | d_model | d_ff | Experts | Top-K | Bottleneck | Params (total) |
|--------|---------|------|---------|-------|------------|----------------|
| Small  | 256     | 1024 | 4       | 2     | 64         | ~2.1M          |
| Medium | 1024    | 4096 | 8       | 2     | 128        | ~67M           |
| Large  | 4096    | 16384| 8       | 2     | 256        | ~1.1B          |

**Dense-equivalent parameter matching**: for fair comparison, the dense baseline uses `hidden_dim = bottleneck_dim * num_experts` to match total parameter count.

### Memory Footprint

The shared-anchor design achieves **1.94x memory reduction** versus naive per-expert fp16 storage:
- Anchor stored once per layer (fp16): `out * in * 2` bytes
- Each expert delta (int4, group=128): `out * in / 2` bytes + scales
- Total for E experts: `anchor + E * delta` vs `E * (out * in * 2)` for full per-expert

Track T artifact gate reports **12,672 KiB total** for the tested exported model configuration.

## Training and Evaluation

### What Was Trained

- **Expert encoder-decoder pairs**: Kaiming initialization, each expert learns to compress a different subspace of the input
- **Anchor weights**: fp16 shared reference, row-normalized onto unit sphere
- **Quantized deltas**: int4/int2 groupwise symmetric quantization of per-expert perturbations from the anchor

### What Was Tested On

| Track | Dataset / Harness | Seed(s) | Purpose |
|-------|-------------------|---------|---------|
| Q     | Internal correctness suite | deterministic | Layer creation, forward pass, routing determinism, specialization, audit entropy, combine methods (6 tests) |
| QS    | Same as Q, multi-seed | 11, 23, 47, 101, 211 | Robustness to shuffle order across 5 fixed seeds |
| P     | Micro-benchmarks (small/medium/large) | -- | Single-run throughput and latency |
| PS    | Same as P, multi-run | n=5 | Mean, std, 95% CI (1.96 * sigma / sqrt(n)) |
| DB    | Dense matched baseline | -- | Fair comparison under equal parameter/FLOP budget |
| T     | Golden artifact parity | 10 deterministic runs | Numerical fidelity against exported reference shards |
| X     | mmlu-tiny (100 samples) | 424242 | External-style MCQA calibration checkpoint |

### Environment

- CPU: AMD Ryzen 7 7700X (8 cores / 16 threads)
- RAM: 31,184 MiB
- OS: Linux 6.17.12 (Fedora)
- Go: 1.25.5
- No GPU used for these benchmarks (CPU-only paths)

## Performance Results

### Throughput (Multi-Run, n=5)

| Benchmark | Mean ns/op | Std | 95% CI | Mean tok/s | 95% CI tok/s |
|-----------|-----------|-----|--------|-----------|-------------|
| Parallel (b=32, medium) | 60.4M | 1.2M | 1.1M | 529.7 | 9.5 |
| ParallelZeroCopy (b=32, medium) | 62.5M | 2.0M | 1.7M | 512.8 | 13.7 |
| Serial (b=32, medium) | 318.1M | 4.3M | 3.7M | 100.6 | 1.2 |
| QSMoEForward (small) | 9.4M | 125K | 109K | -- | -- |
| QSMoEForwardLarge | 152.8M | 818K | 717K | -- | -- |
| WorkspaceForward (b=32, medium) | 286.0M | 4.1M | 3.6M | -- | -- |

**Parallel vs Serial speedup**: 5.26x (Parallel), 5.10x (ZeroCopy) -- grouped expert dispatch with work-stealing across 16 cores.

### Dense Baseline Comparison (Matched Budget)

| Scale | QSMoE ns/op | Dense Matched ns/op | Speedup (Dense/QSMoE) |
|-------|------------|--------------------|-----------------------|
| Small (d=256, b=64, E=16) | 9,242,506 | 11,571,670 | **1.252x** |
| Large (d=512, b=128, E=32) | 152,577,554 | 182,059,712 | **1.193x** |

QSMoE is faster than the matched dense baseline in both tested regimes. The sparse path avoids computing through dead experts (tokens only activate top-k), while the delta dequantization overhead is amortized by reduced memory traffic.

### Numerical Fidelity (Track T)

| Check | Result |
|-------|--------|
| Golden parity (layer 0) | max_abs=0.000732, rmse=0.000185, nrmse=0.02% |
| Golden parity (layer 5) | max_abs=0.000784, rmse=0.000182, nrmse=0.02% |
| Manifold invariant (norm error) | range 0.000024 -- 0.000069 |
| Deterministic replay | Identical outputs across 10 runs |
| Memory savings | 1.94x vs per-expert fp16 |

### External Evaluation Snapshot (mmlu-tiny, seed=424242)

| Model | N | Accuracy | ECE | Brier | AUROC | Confident-Wrong@0.8 |
|-------|---|----------|-----|-------|-------|---------------------|
| ar_baseline | 100 | 0.50 | 0.077 | 0.228 | 0.331 | 0.00 |
| diffusion_baseline | 100 | 0.41 | 0.589 | 0.589 | 0.637 | 0.59 |
| self_consistency | 100 | 0.65 | 0.116 | 0.181 | 0.159 | 0.00 |

This is a small-scale calibration checkpoint, not a final generalization claim.

## Ablations

### Routing: Error-Driven vs Learned Router

MCQSMoE uses `err_e = ||x - decode_e(encode_e(x))||^2` for routing instead of learned logits `x @ W_router`. Tested properties:

- **Determinism**: identical input always selects identical experts (no stochastic gating). Verified across 10 replay runs with zero divergence.
- **Specialization**: with hand-crafted subspace experts, routing correctly selects the expert whose subspace matches the active input dimensions (4/4 cases in controlled test).
- **Entropy**: routing entropy at 55.1% of maximum (1.654 / 3.000 bits for 8 experts), indicating meaningful specialization without collapse. Some dead experts observed under random init -- expected behavior that resolves with training.
- **Combine methods**: softmin weighting (`T=0.1`), best-only, and uniform averaging all tested. Softmin is the default; best-only used for specialization verification.

### Quantization: int4 vs int2 Deltas

Both int4 and int2 groupwise symmetric quantization paths are implemented and tested:

- **int4** (group_size=128): default path. Track T shows max absolute error <=7.84e-4 against fp16 golden reference, nrmse ~0.02%.
- **int2**: more aggressive compression, higher quantization noise. Suitable when delta magnitudes are small relative to the anchor.
- **Group size**: 128 is the tested default. Smaller groups improve accuracy but increase scale storage overhead.

### Shared Anchor vs Per-Expert Weights

| Storage Model | Memory (E=8, 1024x4096 layer) | Speed |
|---------------|-------------------------------|-------|
| Per-expert fp16 | E * out * in * 2 = 64 MB | Baseline |
| Shared anchor + int4 deltas | anchor(8MB) + E * delta(2MB) = 24 MB | 1.2x faster |
| Savings | **2.67x** | -- |

The anchor is computed once per batch; only top-k deltas are dequantized per token. This is the core efficiency mechanism.

### Parallel vs Serial Expert Dispatch

- **Serial**: process experts one at a time. 100.6 tok/s (medium, b=32).
- **Parallel**: group tokens by expert assignment, dispatch to worker pool. 529.7 tok/s. **5.26x speedup**.
- **ParallelZeroCopy**: same as parallel but avoids intermediate buffer allocation. 512.8 tok/s. **5.10x speedup** (slight regression from allocation savings not outweighing coordination overhead at this scale).

### Manifold Retraction

Row normalization (`W_e` rows projected onto unit sphere) is applied after anchor+delta combination. Track T manifold invariant checks confirm norm error stays in range [0.000024, 0.000069], verifying the retraction preserves the constraint through quantization noise.

## Known Limitations

- External evaluation is a small snapshot (mmlu-tiny, 100 samples) -- not a full public benchmark suite
- Throughput numbers are micro-benchmark scoped, not end-to-end serving under production traffic
- Training-cost comparisons (wall-clock convergence, energy) are not yet established
- Multi-run CI uses n=5 with normal approximation -- variance estimates may be optimistic
- Hardware state (thermal, scheduler) is not pinned during benchmarks

## Reproduce

```bash
# Run all evaluation tracks
./scripts/40_run_all.sh

# Build the paper
cd paper && pdflatex main.tex && bibtex main && pdflatex main.tex && pdflatex main.tex
```

## Directory Map

- `paper/` -- manuscript source (LaTeX)
- `protocol/` -- rigor protocol and report template
- `configs/EXPERIMENT_MATRIX.yaml` -- track definitions
- `scripts/` -- reproducibility scripts
- `artifacts/` -- frozen evidence from latest run
- `checks/` -- critic findings and pre-submission checklist
