#' Global variables for NSE (non-standard evaluation)
#'
#' Declare global variables used in tidyverse pipelines to avoid R CMD check NOTEs.
#'
#' @noRd
utils::globalVariables(c(
  # Column names used in dplyr/tidyr operations
  "Sport",
  "EventName",
  "Event_full",
  "event",
  "event_original",
  "prob_gold",
  "prob_silver",
  "prob_bronze",
  "flag_gold_gt1",
  "flag_silver_gt1",
  "flag_bronze_gt1",
  "canonical",
  "pattern",
  "replacement",
  ".x"
))
