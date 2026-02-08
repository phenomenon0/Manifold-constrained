# MCQSMoE ArXiv-Style Release Bundle

This directory is a publication bundle for the MCQSMoE rigor-parity work.

It packages:
- an arXiv-style paper source (`paper/`)
- protocol + experiment matrix (`protocol/`, `configs/`)
- executable rigor scripts (`scripts/`)
- frozen evidence artifacts from the latest run (`artifacts/`)
- pre-submission critic checklists (`checks/`)

## Scope Statement

This bundle proves internal rigor for the claim set in `protocol/PROTOCOL.md`.
It does **not** claim SOTA quality on public task benchmarks yet.

Current protocol adds two critic-driven upgrades:
- `Track DB`: dense matched baseline under aligned parameter/compute budget.
- `Track X`: external-style MCQA harness snapshot (`mmlu-tiny`) with fixed seed.

## Reproduce The Current Artifact Set

From repository root (`Agent-GO`):

```bash
./foundation_models/paper_mcsqoe/scripts/40_run_all.sh
```

Then refresh this bundle snapshot:

```bash
./foundation_models/paper_mcsqoe/github_release/scripts/sync_artifacts.sh
```

## Build The Paper Locally

Requires a TeX toolchain (`pdflatex` + `bibtex` or `latexmk`).

```bash
cd foundation_models/paper_mcsqoe/github_release/paper
pdflatex main.tex
bibtex main
pdflatex main.tex
pdflatex main.tex
```

## Publish As Standalone Repo

From `Agent-GO` root, create a split branch containing only this bundle:

```bash
./foundation_models/paper_mcsqoe/github_release/scripts/subtree_publish.sh
```

Push directly to a target GitHub repo (URL or configured remote name both work):

```bash
./foundation_models/paper_mcsqoe/github_release/scripts/subtree_publish.sh \
  --remote git@github.com:YOUR_ORG/mcsqoe-paper-release.git \
  --remote-branch main
```

If `git subtree` is unavailable on your machine, the helper prints an equivalent `git-filter-repo` fallback sequence.

## Directory Map

- `paper/main.tex`: manuscript entrypoint
- `paper/sections/`: paper sections
- `paper/tables/`: publication tables
- `paper/figures/`: publication figures (LaTeX figure blocks)
- `protocol/`: rigor protocol docs
- `configs/EXPERIMENT_MATRIX.yaml`: track definitions
- `scripts/`: reproducibility scripts + bundle helper
- `artifacts/`: run evidence copied from `../results`
- `checks/`: critic findings and pre-submission checklist
- `.github/workflows/ci.yml`: CI draft for reproducibility gate
