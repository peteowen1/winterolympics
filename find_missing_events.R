library(tidyverse)
devtools::load_all()

# Get canonical events
canonical <- canonical_events()

# Load and clean current data
db <- read_source_db()
result <- clean_athlete_database(db)

# Get events in current data
current_events <- result$data %>%
  distinct(event) %>%
  pull(event) %>%
  sort()

# Get canonical event list
canonical_event_names <- canonical %>%
  pull(Event_full) %>%
  sort()

# Find missing events
missing <- setdiff(canonical_event_names, current_events)

cat("=== MISSING EVENTS ===\n")
cat("Total missing:", length(missing), "\n\n")
print(missing)

cat("\n\n=== EVENTS IN DATA BUT NOT CANONICAL ===\n")
extra <- setdiff(current_events, canonical_event_names)
print(extra)
