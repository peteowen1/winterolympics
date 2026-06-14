# winterolympics

[![R-CMD-check](https://img.shields.io/badge/R--CMD--check-passing-brightgreen.svg)](https://r-lib.org/pkg/devtools/)

> Tidyverse utilities for cleaning and normalizing 2026 Winter Olympics athlete medal probability data

## Overview

The `winterolympics` package provides a complete data cleaning pipeline for athlete-event medal probability datasets for the Milan-Cortina 2026 Winter Olympics. It standardizes event names to a canonical list of 116 official events, reconciles naming variants across different data sources, and enforces per-event medal probability constraints.

## Key Features

- **Canonical Event List**: Official 116-event roster for Milan-Cortina 2026
- **Event Name Normalization**: Handles common variations and abbreviations
- **Probability Validation**: Ensures per-event probability sums don't exceed 1.0
- **Diagnostic Reports**: Detailed information about data quality and coverage
- **Tidyverse Integration**: Pipe-friendly functions that work seamlessly with dplyr workflows

## Installation

```r
# Install from source
devtools::install()

# Or install from GitHub (if published)
# devtools::install_github("username/winterolympics")
```

## Quick Start

```r
library(winterolympics)
library(dplyr)

# Load raw athlete medal probability data
db <- read_source_db()

# Clean and normalize
result <- clean_athlete_database(db)

# Inspect diagnostics
result$diagnostics$n_unique_events  # Should be 116 or fewer
result$diagnostics$missing_events   # Events not covered in data

# Work with clean data
clean_data <- result$data
clean_data |>
  filter(Prob_Gold > 0.1) |>
  arrange(desc(Prob_Gold))

# Export results
write_clean_outputs(result)
```

## Core Functions

### `canonical_events()`

Returns the official 116-event list for the 2026 Winter Olympics.

```r
events <- canonical_events()
events |> count(Sport)
```

### `normalize_event_names(event)`

Standardizes event name variations to canonical format.

```r
normalize_event_names("Freestyle - Men's Moguls")
# Returns: "Freestyle Skiing - Men's Moguls"

normalize_event_names("Cross-Country - Men's Sprint (CL)")
# Returns: "Cross-Country - Men's Sprint (Classic)"
```

### `read_source_db(paths = NULL)`

Reads athlete medal probability data from CSV or Excel files.

```r
# Uses default priority order
db <- read_source_db()

# Custom path
db <- read_source_db("my_custom_data.csv")

# Check which file was loaded
attr(db, "source_path")
```

### `clean_athlete_database(db)`

Main cleaning pipeline that normalizes events, filters to canonical list, and scales probabilities.

```r
result <- clean_athlete_database(db)

# Access cleaned data
result$data

# Check diagnostics
result$diagnostics$n_unique_events
result$diagnostics$missing_events
result$diagnostics$sums  # Per-event probability sums
```

### `write_clean_outputs(cleaned, out_csv, sums_csv)`

Exports cleaned data and diagnostics to CSV files.

```r
write_clean_outputs(result)

# Custom file names
write_clean_outputs(
  result,
  out_csv = "clean_athletes.csv",
  sums_csv = "validation_report.csv"
)
```

## Data Requirements

Input data must have:
- An `Event` column with event names (can use various formats)
- Optional probability columns: `Prob_Gold`, `Prob_Silver`, `Prob_Bronze`
- Any other columns (athlete names, countries, etc.) are preserved

## Supported Event Name Variations

The package handles common naming variations:

| Input Format | Canonical Format |
|--------------|------------------|
| `Freestyle - Men's Moguls` | `Freestyle Skiing - Men's Moguls` |
| `Cross-Country - Men's Sprint (CL)` | `Cross-Country - Men's Sprint (Classic)` |
| `Cross-Country - Men's 15km (FR)` | `Cross-Country - Men's 15km (Free)` |
| `Figure Skating - Team Event` | `Figure Skating - Team` |
| `Snowboard - Mixed Team SBX` | `Snowboard - Mixed Team Snowboard Cross` |
| `Ski Jumping - Women's Team` | `Ski Jumping - Mixed Team` |

## Probability Scaling

If per-event probability sums exceed 1.0, the package automatically scales them proportionally:

```r
# Before scaling: Gold probabilities sum to 1.5 for an event
# After scaling: All probabilities divided by 1.5 (sum = 1.0)
```

This ensures valid probability distributions while preserving relative rankings.

## Example Workflow

```r
library(winterolympics)
library(dplyr)

# 1. Load data
db <- read_source_db()

# 2. Clean and validate
result <- clean_athlete_database(db)

# 3. Check coverage
cat("Events covered:", result$diagnostics$n_unique_events, "/ 116\n")

# 4. Analyze clean data
medal_leaders <- result$data |>
  group_by(Event) |>
  slice_max(Prob_Gold, n = 3) |>
  arrange(Event, desc(Prob_Gold))

# 5. Export
write_clean_outputs(result)
```

## Scripts

The package includes example scripts:

- `analysis/clean_medal_probabilities.R`: Complete cleaning workflow with validation
- `inst/scripts/clean_and_check.R`: Diagnostic-focused cleaning script

Run them from the package root:

```r
source("analysis/clean_medal_probabilities.R")
```

## Development

```r
# Generate documentation
devtools::document()

# Run tests
devtools::test()

# Check package
devtools::check()
```

## License

MIT License - see LICENSE file for details

## Author

Pete O'Hanlon (pete@example.com)
