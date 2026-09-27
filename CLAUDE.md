# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Package Overview

The `winterolympics` package provides tidyverse-oriented tooling for normalizing athlete-event medal probability datasets for the Milan-Cortina 2026 Winter Olympics. The package ensures data conforms to a canonical list of 116 events, reconciles naming variants, and enforces probability constraints.

**Main Data File**: `olympics2026_athlete_medal_probabilities.csv` - Contains athlete medal probabilities for all 116 events, regularly updated with current season performance data.

## Development Commands

`AGENTS.md` also exists at repo root with build/test/style conventions — the two files diverge in places (neither is a strict subset of the other); check both if something isn't here.

```r
devtools::load_all()      # load for development
devtools::document()      # refresh docs after changing exported APIs
devtools::test()          # run tests before opening a PR
devtools::check()         # full package check (build, lint, tests)
devtools::install()
```

```bash
Rscript inst/scripts/clean_and_check.R        # generate canonicalized tables + diagnostics CSVs
Rscript analysis/clean_medal_probabilities.R  # validate source file, emit clean/detailed outputs
```

## Architecture & Data Flow

### Core Data Pipeline
1. **Data Collection** (`read_source_db()`) → Load athlete probability data from CSV/Excel
2. **Column Standardization** → Apply `janitor::clean_names()` for snake_case columns
3. **Event Normalization** (`normalize_event_names()`) → Map variants to canonical names
4. **Data Cleaning** (`clean_athlete_database()`) → Filter, validate, scale probabilities
5. **Output** (`write_clean_outputs()`) → Export clean data and diagnostics

### Key Functions
- `canonical_events()` - Returns the official 116-event list
- `normalize_event_names()` - Handles event name variations and abbreviations
- `read_source_db()` - Loads data and applies snake_case column names
- `clean_athlete_database()` - Main cleaning pipeline
- `write_clean_outputs()` - Export results

## Key Constraints & Patterns

### Column Naming Convention
**CRITICAL**: All column names MUST use snake_case format — but this applies to the
package's OUTPUT, not necessarily its input. The raw source CSV
(`olympics2026_athlete_medal_probabilities.csv`) ships CamelCase headers
(`Event,AthleteTeam,Country,Prob_Gold,Prob_Silver,Prob_Bronze,Notes`) — it only
becomes snake_case after `read_source_db()` runs `janitor::clean_names()`. Opening
the raw CSV directly and seeing CamelCase is expected, not a bug.
- The package uses `janitor::clean_names()` to standardize all input data
- Expected columns (post-`clean_names()`): `event`, `athlete_team`, `country`, `prob_gold`, `prob_silver`, `prob_bronze`, `notes`
- Internal columns: `event_original` (preserves original event name before normalization)
- Diagnostic columns: `flag_gold_gt1`, `flag_silver_gt1`, `flag_bronze_gt1`
- Never reference columns with capital letters (e.g., use `event` not `Event`)
- **Exception**: `canonical_events()` is the one documented exception — it returns CamelCase columns `Sport`, `EventName`, `Event_full` (the official 116-event reference table), not snake_case.

### Event Name Normalization
The package handles common event naming variations:
- Sport prefix variations: "Freestyle" → "Freestyle Skiing"
- Abbreviations: "Individual NH" → "Men's Individual Normal Hill/10km"
- Style codes: "(CL)" → "(Classic)", "(FR)" → "(Free)"
- All mappings defined in `R/normalize_events.R` alias table

### Probability Validation
- Probabilities must be numeric between 0 and 1
- Per-event sums for each medal type must not exceed 1.0
- Auto-scaling applied if sums > 1.0 (proportional reduction)
- Missing probabilities treated as 0

## Core Functions by Module

### Canonical Events (`canonical_events.R`)
- `canonical_events()` - Returns tibble of 116 official events with Sport, EventName, Event_full columns

### Event Normalization (`normalize_events.R`)
- `normalize_event_names(event)` - Vectorized function to standardize event names

### Data Processing (`clean_database.R`)
- `read_source_db(paths)` - Load CSV/Excel with auto snake_case conversion (defaults to `olympics2026_athlete_medal_probabilities.csv`)
- `clean_athlete_database(db)` - Main cleaning pipeline
- `write_clean_outputs(cleaned)` - Export to CSV
- Internal helpers: `scale_probabilities_if_needed()`, `validate_event_sums()`

**Important**: When updating athlete probabilities based on current season performance:
- Research 2024-25 World Cup/Championship results for each sport
- Update probabilities to reflect current form, not just historical Olympic results
- Add notes column with relevant context (e.g., "2025 World Champion", "2025 WC overall winner")
- Verify probability sums per event remain ≤ 1.0

## Testing Strategy

Tests focus on:
- Event count validation (116 events)
- Name normalization (all variations → canonical)
- Probability scaling (sums ≤ 1.0)
- Error handling (missing columns, invalid events)
- Column naming (snake_case verification)

All test data must use snake_case column names.

## Analysis Scripts

### Structure
- `analysis/` - User-facing scripts demonstrating package functionality
- `inst/scripts/` - Command-line utilities for batch processing

### Guidelines
- Keep scripts simple and concise
- No excessive logging or `cat()` calls (will run in RStudio)
- Use package functions, don't redefine logic in scripts
- Focus on demonstrating workflow, not building new functionality

## Important Notes

- **Column Names**: Always use snake_case. The `janitor::clean_names()` function is applied automatically to all input data.
- **Event Coverage**: Not all data sources will have all 116 events. Missing events are tracked in diagnostics.
- **Probability Scaling**: Automatic scaling ensures valid probability distributions while preserving relative rankings.
- **Data Updates**: The main data file (`olympics2026_athlete_medal_probabilities.csv`) should be updated regularly based on current World Cup/Championship season results to maintain prediction accuracy.

## File Organization

### Key Files
- `olympics2026_athlete_medal_probabilities.csv` - Main source data (regularly updated)
- `olympics2026_116_canonical_events.csv` - Reference list of all official events
- `athlete_medal_probabilities_clean.csv` - Output from cleaning scripts
- `athlete_medal_probabilities_diagnostics.csv` - Validation reports
