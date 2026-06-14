library(tidyverse)
devtools::load_all()

# Get canonical 116 events
canonical <- canonical_events()

# Save as CSV
write_csv(canonical, "olympics2026_116_canonical_events.csv")

cat("Created olympics2026_116_canonical_events.csv with", nrow(canonical), "events\n")
