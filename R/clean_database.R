#' Read athlete medal probability source data
#'
#' Reads athlete-event medal probability data from CSV or Excel files, using
#' a priority order to locate the most recent dataset. By default, looks for
#' files in the current directory following the naming pattern used by the
#' 2026 Winter Olympics prediction project.
#'
#' @param paths Character vector of file paths to try, in priority order.
#'   If NULL (default), uses the standard file names in priority order.
#'
#' @return A tibble containing the source data, with an attribute "source_path"
#'   indicating which file was loaded.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Use default file priority
#' db <- read_source_db()
#'
#' # Specify custom path
#' db <- read_source_db("my_custom_probabilities.csv")
#'
#' # Check which file was loaded
#' attr(db, "source_path")
#' }
#'
#' @importFrom purrr detect
#' @importFrom stringr str_to_lower
#' @importFrom readr read_csv
#' @importFrom tibble as_tibble
#' @importFrom janitor clean_names
read_source_db <- function(paths = NULL) {
  if (is.null(paths)) {
    paths <- c(
      "olympics2026_athlete_medal_probabilities.csv"
    )
  }

  source_path <- purrr::detect(paths, ~ file.exists(.x))
  if (is.null(source_path)) {
    stop("Cannot find source DB file 'olympics2026_athlete_medal_probabilities.csv'. Provide custom path via `paths` argument.")
  }

  ext <- stringr::str_to_lower(tools::file_ext(source_path))
  if (ext == "csv") {
    db <- readr::read_csv(source_path, show_col_types = FALSE, progress = FALSE)
  } else if (ext %in% c("xlsx", "xls")) {
    if (!requireNamespace("readxl", quietly = TRUE)) {
      stop("Package 'readxl' required to read Excel files.")
    }
    db <- readxl::read_excel(source_path)
  } else {
    stop("Unsupported file extension: ", ext)
  }

  db <- tibble::as_tibble(db) |>
    janitor::clean_names()
  attr(db, "source_path") <- source_path
  db
}

#' Scale medal probabilities to ensure per-event sums <= 1
#'
#' Internal helper that normalizes probability columns within each event group.
#' If the sum of probabilities for a given medal type exceeds 1.0 for an event,
#' all probabilities for that medal type are scaled proportionally.
#'
#' @param df A data frame with an Event column and probability columns
#' @param cols Character vector of probability column names to scale
#'
#' @return The input data frame with scaled probability columns
#'
#' @keywords internal
#' @noRd
#'
#' @importFrom dplyr mutate across all_of group_by ungroup
#' @importFrom tidyr replace_na
#' @importFrom readr parse_number
scale_probabilities_if_needed <- function(df, cols = c("prob_gold", "prob_silver", "prob_bronze")) {
  missing_cols <- setdiff(cols, names(df))
  if (length(missing_cols) > 0) {
    df[missing_cols] <- 0
  }

  df |>
    dplyr::mutate(dplyr::across(dplyr::all_of(cols), ~ readr::parse_number(as.character(.x)))) |>
    dplyr::mutate(dplyr::across(dplyr::all_of(cols), ~ tidyr::replace_na(.x, 0))) |>
    dplyr::group_by(event) |>
    dplyr::mutate(dplyr::across(dplyr::all_of(cols), ~ {
      total <- sum(.x, na.rm = TRUE)
      if (!is.na(total) && total > 1 + 1e-12 && total > 0) .x / total else .x
    })) |>
    dplyr::ungroup()
}

#' Validate that event-level probability sums are valid
#'
#' Internal helper that computes per-event sums for each medal type and flags
#' any events where the sum exceeds 1.0 (indicating a data quality issue).
#'
#' @param df A data frame with Event and probability columns
#'
#' @return A summary tibble with one row per event and flag columns
#'
#' @keywords internal
#' @noRd
#'
#' @importFrom dplyr group_by summarise across all_of mutate
validate_event_sums <- function(df) {
  cols <- c("prob_gold", "prob_silver", "prob_bronze")
  missing_cols <- setdiff(cols, names(df))
  if (length(missing_cols) > 0) {
    df[missing_cols] <- 0
  }

  df |>
    dplyr::group_by(event) |>
    dplyr::summarise(
      dplyr::across(dplyr::all_of(cols), ~ sum(as.numeric(.x), na.rm = TRUE)),
      .groups = "drop"
    ) |>
    dplyr::mutate(
      flag_gold_gt1 = prob_gold > 1 + 1e-12,
      flag_silver_gt1 = prob_silver > 1 + 1e-12,
      flag_bronze_gt1 = prob_bronze > 1 + 1e-12
    )
}

#' Clean and normalize athlete medal probability database
#'
#' This is the main data cleaning function. It normalizes event names to the
#' canonical 116-event list, filters to only include recognized events, scales
#' probabilities to ensure valid constraints, and returns both the cleaned
#' data and diagnostic information about the cleaning process.
#'
#' @param db A data frame containing raw athlete-event medal probabilities.
#'   Must have an "Event" column.
#'
#' @return A list with two elements:
#'   \describe{
#'     \item{data}{Cleaned tibble with normalized Event names and scaled probabilities}
#'     \item{diagnostics}{List containing:
#'       \itemize{
#'         \item n_unique_events: Count of unique events in cleaned data
#'         \item missing_events: Events in canonical list but not in data
#'         \item extra_events: Events in data but not in canonical list (after normalization)
#'         \item sums: Per-event probability sums and validation flags
#'       }
#'     }
#'   }
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Load and clean data
#' db <- read_source_db()
#' result <- clean_athlete_database(db)
#'
#' # Check diagnostics
#' result$diagnostics$n_unique_events  # Should be 116
#' result$diagnostics$missing_events   # Events not covered
#'
#' # Use cleaned data
#' clean_data <- result$data
#' }
#'
#' @importFrom dplyr mutate filter distinct arrange pull
#' @importFrom tibble as_tibble
clean_athlete_database <- function(db) {
  ref <- canonical_events()
  canonical <- ref |>
    dplyr::distinct(Event_full) |>
    dplyr::pull(Event_full)

  if (!"event" %in% names(db)) {
    stop("Input DB must have an 'event' column.")
  }

  strict <- db |>
    tibble::as_tibble() |>
    dplyr::mutate(
      event_original = event,
      event = normalize_event_names(event)
    ) |>
    dplyr::filter(event %in% canonical)

  if (nrow(strict) == 0) {
    stop("No rows match canonical 116 events after normalization.")
  }

  strict <- scale_probabilities_if_needed(strict)

  present <- strict |>
    dplyr::distinct(event) |>
    dplyr::arrange(event) |>
    dplyr::pull(event)

  missing <- setdiff(canonical, present)
  extra <- setdiff(present, canonical)

  sums <- validate_event_sums(strict)

  diagnostics <- list(
    n_unique_events = length(present),
    missing_events = missing,
    extra_events = extra,
    sums = sums
  )

  list(
    data = strict,
    diagnostics = diagnostics
  )
}

#' Write cleaned data and diagnostics to CSV files
#'
#' Convenience function to save the cleaned athlete database and diagnostic
#' summary to separate CSV files.
#'
#' @param cleaned The result list from \code{\link{clean_athlete_database}}
#' @param out_csv Path for the main cleaned data output (default: "olympics2026_athlete_medal_probs_STRICT116_SCALED.csv")
#' @param sums_csv Path for the diagnostics/validation output (default: "olympics2026_STRICT116_sumcheck.csv")
#'
#' @return Invisibly returns a named character vector with the output file paths
#'
#' @export
#'
#' @examples
#' \dontrun{
#' db <- read_source_db()
#' cleaned <- clean_athlete_database(db)
#' write_clean_outputs(cleaned)
#'
#' # Custom output names
#' write_clean_outputs(cleaned, out_csv = "my_clean_data.csv")
#' }
#'
#' @importFrom readr write_csv
write_clean_outputs <- function(cleaned,
                                out_csv = "olympics2026_athlete_medal_probs_STRICT116_SCALED.csv",
                                sums_csv = "olympics2026_STRICT116_sumcheck.csv") {
  readr::write_csv(cleaned$data, out_csv)
  readr::write_csv(cleaned$diagnostics$sums, sums_csv)
  invisible(c(out_csv = out_csv, sums_csv = sums_csv))
}
