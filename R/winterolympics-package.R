#' @keywords internal
"_PACKAGE"

## usethis namespace: start
## usethis namespace: end
NULL

#' winterolympics: 2026 Winter Olympics Performance Prediction Utilities
#'
#' The winterolympics package provides tidyverse-oriented tooling for working
#' with athlete-event medal probability datasets for the Milan-Cortina 2026
#' Winter Olympics. It normalizes event names to a canonical list of 116 events,
#' reconciles naming variants across different data sources, and enforces
#' per-event medal probability constraints.
#'
#' @section Main functions:
#' \describe{
#'   \item{\code{\link{canonical_events}}}{Returns the official 116-event list}
#'   \item{\code{\link{normalize_event_names}}}{Standardizes event name variations}
#'   \item{\code{\link{read_source_db}}}{Reads athlete medal probability data}
#'   \item{\code{\link{clean_athlete_database}}}{Main cleaning and validation pipeline}
#'   \item{\code{\link{write_clean_outputs}}}{Exports cleaned data and diagnostics}
#' }
#'
#' @section Workflow:
#' A typical workflow involves:
#' \enumerate{
#'   \item Load raw data: \code{db <- read_source_db()}
#'   \item Clean and normalize: \code{result <- clean_athlete_database(db)}
#'   \item Check diagnostics: \code{result$diagnostics}
#'   \item Export results: \code{write_clean_outputs(result)}
#' }
#'
#' @docType package
#' @name winterolympics-package
NULL
