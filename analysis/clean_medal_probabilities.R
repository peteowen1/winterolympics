library(tidyverse)
devtools::load_all()

# Load data
db <- read_source_db()

# Clean and normalize
result <- clean_athlete_database(db)

# Show coverage
cat("Events covered:", result$diagnostics$n_unique_events, "/ 116\n")
if (length(result$diagnostics$missing_events) > 0) {
  cat("Missing events:", length(result$diagnostics$missing_events), "\n")
}

# Validate probabilities
violations <- result$diagnostics$sums |>
  summarise(any_violation = any(flag_gold_gt1 | flag_silver_gt1 | flag_bronze_gt1)) |>
  pull(any_violation)

stopifnot(!violations)

# Save outputs
write_csv(result$data, "athlete_medal_probabilities_clean.csv")
write_csv(result$diagnostics$sums, "athlete_medal_probabilities_diagnostics.csv")

cat("Saved clean data and diagnostics\n")

result$data %>% group_by(event) %>% summarise(gld = sum(prob_gold)) %>% arrange(-gld)
result$data %>% group_by(country) %>% summarise(gld = sum(prob_gold)) %>% arrange(-gld)
