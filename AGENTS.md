# Repository Guidelines

## Project Structure & Module Organization
- Purpose: tidyverse utilities for harmonizing 2026 Winter Olympics athlete-event datasets, enforcing probability constraints, and exporting clean analytics tables.
- `R/`: core functions (`canonical_events.R`, `normalize_events.R`, `clean_database.R`) built around `dplyr`, `tibble`, and friends.
- `inst/scripts/`: reproducible command-line workflows (`clean_and_check.R`) for data normalization and diagnostics.
- `analysis/`: analyst-facing scripts (`clean_medal_probabilities.R`) that orchestrate package functions for deliverables.
- `man/`, `DESCRIPTION`, `NAMESPACE`, `winterolympics.Rproj`: documentation stubs and package metadata—keep aligned with `roxygen2` output and dependency changes.
- Store raw CSV/XLSX medal probability sources at the project root so loaders can resolve the default priority order.

## Build, Test, and Development Commands
- `R -e "devtools::document()"`: refresh documentation after updating exported APIs.
- `R -e "devtools::check()"`: run full package checks (build, lint, tests) before submitting patches.
- `Rscript inst/scripts/clean_and_check.R`: generate canonicalized athlete tables plus diagnostics CSVs.
- `Rscript analysis/clean_medal_probabilities.R`: validate the preferred source file and emit clean/detailed outputs for modeling.

## Coding Style & Naming Conventions
- Write in tidyverse style: pipe-heavy workflows, `dplyr::mutate()` chains, 2-space indentation, minimal temporary variables.
- Prefer snake_case names (`clean_athlete_database`, `scale_probabilities_if_needed`) and keep functions pure/pipe-friendly.
- Always reference packages explicitly with `pkg::fun` inside package code and scripts; declare dependencies in `DESCRIPTION`.
- Accept path vectors instead of hard-coded locations; rely on tibbles for tabular structures.

## Testing Guidelines
- Place unit tests in `tests/testthat/`, naming files `test-<feature>.R` (e.g., `test-normalize-events.R`).
- Cover canonical event completeness, name normalization, and probability scaling edge cases.
- Execute `R -e "devtools::test()"` before opening a PR; include regression-style fixtures when adjusting data rules.

## Commit & Pull Request Guidelines
- Format commits as `<scope>: <imperative summary>` (e.g., `cleanup: refactor probability scaling pipeline`).
- Summaries must mention affected data artifacts or scripts; link GitHub issues when available.
- PR descriptions should outline motivation, highlight new outputs, and note verification commands; attach tables or screenshots only if they clarify analyst-facing results.
