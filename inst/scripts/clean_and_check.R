#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  if (requireNamespace("winterolympics", quietly = TRUE)) {
    library(winterolympics)
  } else if (requireNamespace("devtools", quietly = TRUE)) {
    devtools::load_all(".")
  }
})

# Load and clean
db <- read_source_db()
result <- clean_athlete_database(db)

# Print diagnostics
cat("Unique events:", result$diagnostics$n_unique_events, "\n")
cat("Missing events:", length(result$diagnostics$missing_events), "\n")

if (length(result$diagnostics$missing_events) > 0) {
  cat("First few missing:\n")
  print(head(result$diagnostics$missing_events))
}

# Check probability violations
flags <- result$diagnostics$sums |>
  dplyr::summarise(
    Gold = any(flag_gold_gt1),
    Silver = any(flag_silver_gt1),
    Bronze = any(flag_bronze_gt1)
  )

cat("\nProbability violations:\n")
print(flags)

# Save outputs
outputs <- write_clean_outputs(result)
cat("\nSaved:", outputs, "\n")
