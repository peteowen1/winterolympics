library(tidyverse)
devtools::load_all()

# Load cleaned data
db <- read_source_db()

# Clean and normalize
result <- clean_athlete_database(db)

# Check for TBDs
tbd_check <- result$data |>
  filter(str_detect(athlete_team, "TBD") | str_detect(country, "TBD"))

cat("=== COVERAGE REPORT ===\n")
cat("Events covered:", result$diagnostics$n_unique_events, "/ 116\n")
cat("TBD entries remaining:", nrow(tbd_check), "\n")
cat("Missing events:", length(result$diagnostics$missing_events), "\n\n")

if (length(result$diagnostics$missing_events) > 0) {
  cat("Missing events:\n")
  print(result$diagnostics$missing_events)
}

# Validate probabilities
violations <- result$diagnostics$sums |>
  summarise(any_violation = any(flag_gold_gt1 | flag_silver_gt1 | flag_bronze_gt1)) |>
  pull(any_violation)

cat("\nProbability violations:", violations, "\n")

# Save final clean output
write_csv(result$data, "athlete_medal_probabilities_clean.csv")
cat("\nSaved clean data to athlete_medal_probabilities_clean.csv\n")
