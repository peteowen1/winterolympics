#' Normalize event names to the canonical Milan-Cortina 2026 format
#'
#' This function takes a character vector of event names (which may use various
#' naming conventions or abbreviations) and standardizes them to match the
#' canonical 116-event list. It handles common prefix variations (e.g.,
#' "Freestyle" vs "Freestyle Skiing") and event name aliases (e.g., "Team Event"
#' vs "Team" for Figure Skating).
#'
#' @param event A character vector of event names to normalize
#'
#' @return A character vector of the same length with normalized event names
#'
#' @export
#'
#' @examples
#' # Normalize freestyle event names
#' normalize_event_names("Freestyle - Men's Moguls")
#' # Returns: "Freestyle Skiing - Men's Moguls"
#'
#' # Handle cross-country abbreviations
#' normalize_event_names("Cross-Country - Men's 15km (FR)")
#' # Returns: "Cross-Country - Men's 15km (Free)"
#'
#' # Vectorized operation
#' events <- c(
#'   "Freestyle - Men's Moguls",
#'   "Figure Skating - Team Event",
#'   "Cross-Country - Men's Sprint (CL)"
#' )
#' normalize_event_names(events)
#'
#' @importFrom tibble tibble
#' @importFrom dplyr if_else mutate left_join coalesce pull
#' @importFrom tidyr replace_na
#' @importFrom stringr str_trim str_starts str_replace
#' @importFrom purrr reduce2
normalize_event_names <- function(event) {
  prefix <- c(
    "Freestyle - " = "Freestyle Skiing - ",
    "Short Track Speed Skating - " = "Short Track - ",
    "Alpine - " = "Alpine - ",
    "Biathlon - " = "Biathlon - ",
    "Bobsleigh - " = "Bobsleigh - ",
    "Skeleton - " = "Skeleton - ",
    "Luge - " = "Luge - ",
    "Cross-Country - " = "Cross-Country - ",
    "Curling - " = "Curling - ",
    "Figure Skating - " = "Figure Skating - ",
    "Ice Hockey - " = "Ice Hockey - ",
    "Short Track - " = "Short Track - ",
    "Ski Jumping - " = "Ski Jumping - ",
    "Ski Mountaineering - " = "Ski Mountaineering - ",
    "Snowboard - " = "Snowboard - ",
    "Speed Skating - " = "Speed Skating - ",
    "Nordic Combined - " = "Nordic Combined - ",
    "Freestyle Skiing - " = "Freestyle Skiing - "
  )

  alias <- c(
    # Snowboard abbreviations
    "Snowboard - Mixed Team SBX" = "Snowboard - Mixed Team Snowboard Cross",
    "Snowboard - Men's SBX" = "Snowboard - Men's Snowboard Cross",
    "Snowboard - Women's SBX" = "Snowboard - Women's Snowboard Cross",
    "Snowboard - Men's PGS" = "Snowboard - Men's Parallel Giant Slalom",
    "Snowboard - Women's PGS" = "Snowboard - Women's Parallel Giant Slalom",
    # Figure Skating
    "Figure Skating - Team Event" = "Figure Skating - Team",
    # Cross-Country abbreviations
    "Cross-Country - Men's 15km (FR)" = "Cross-Country - Men's 15km (Free)",
    "Cross-Country - Women's 10km (FR)" = "Cross-Country - Women's 10km (Free)",
    "Cross-Country - Men's Sprint (CL)" = "Cross-Country - Men's Sprint (Classic)",
    "Cross-Country - Women's Sprint (CL)" = "Cross-Country - Women's Sprint (Classic)",
    "Cross-Country - Women's 30km (CL)" = "Cross-Country - Women's 50km (Classic)",
    "Cross-Country - Men's 30km (CL)" = "Cross-Country - Men's 50km (Classic)",
    "Cross-Country - Men's 50km (CL)" = "Cross-Country - Men's 50km (Classic)",
    "Cross-Country - Women's 50km (CL)" = "Cross-Country - Women's 50km (Classic)",
    "Cross-Country - Men's Skiathlon" = "Cross-Country - Men's Skiathlon 2x10km",
    "Cross-Country - Women's Skiathlon" = "Cross-Country - Women's Skiathlon 2x7.5km",
    "Cross-Country - Men's Team Sprint" = "Cross-Country - Men's Team Sprint (Free)",
    "Cross-Country - Women's Team Sprint" = "Cross-Country - Women's Team Sprint (Free)",
    # Ski Mountaineering
    "Ski Mountaineering - Men's Individual" = "Ski Mountaineering - Men's Sprint",
    "Ski Mountaineering - Women's Individual" = "Ski Mountaineering - Women's Sprint",
    # Nordic Combined
    "Nordic Combined - Individual NH" = "Nordic Combined - Men's Individual Normal Hill/10km",
    "Nordic Combined - Individual LH" = "Nordic Combined - Men's Individual Large Hill/10km",
    "Nordic Combined - Team (4x5km)" = "Nordic Combined - Men's Team Large Hill/2x7.5km",
    # Biathlon distance specifications
    "Biathlon - Men's Sprint" = "Biathlon - Men's Sprint 10km",
    "Biathlon - Women's Sprint" = "Biathlon - Women's Sprint 7.5km",
    "Biathlon - Men's Pursuit" = "Biathlon - Men's Pursuit 12.5km",
    "Biathlon - Women's Pursuit" = "Biathlon - Women's Pursuit 10km",
    "Biathlon - Men's Mass Start" = "Biathlon - Men's Mass Start 15km",
    "Biathlon - Women's Mass Start" = "Biathlon - Women's Mass Start 12.5km",
    # Bobsleigh naming
    "Bobsleigh - Monobob (Women)" = "Bobsleigh - Women's Monobob",
    # Freestyle Skiing prefix
    "Freestyle - Men's Moguls" = "Freestyle Skiing - Men's Moguls",
    "Freestyle - Women's Moguls" = "Freestyle Skiing - Women's Moguls",
    "Freestyle - Men's Dual Moguls" = "Freestyle Skiing - Men's Dual Moguls",
    "Freestyle - Women's Dual Moguls" = "Freestyle Skiing - Women's Dual Moguls",
    "Freestyle - Men's Aerials" = "Freestyle Skiing - Men's Aerials",
    "Freestyle - Women's Aerials" = "Freestyle Skiing - Women's Aerials",
    "Freestyle - Mixed Team Aerials" = "Freestyle Skiing - Mixed Team Aerials",
    "Freestyle - Men's Ski Cross" = "Freestyle Skiing - Men's Ski Cross",
    "Freestyle - Women's Ski Cross" = "Freestyle Skiing - Women's Ski Cross",
    "Freestyle - Men's Halfpipe (Ski)" = "Freestyle Skiing - Men's Halfpipe (Ski)",
    "Freestyle - Women's Halfpipe (Ski)" = "Freestyle Skiing - Women's Halfpipe (Ski)",
    "Freestyle - Men's Slopestyle (Ski)" = "Freestyle Skiing - Men's Slopestyle (Ski)",
    "Freestyle - Women's Slopestyle (Ski)" = "Freestyle Skiing - Women's Slopestyle (Ski)",
    "Freestyle - Men's Big Air (Ski)" = "Freestyle Skiing - Men's Big Air (Ski)",
    "Freestyle - Women's Big Air (Ski)" = "Freestyle Skiing - Women's Big Air (Ski)",
    # Ski Jumping
    "Ski Jumping - Women's Team" = "Ski Jumping - Mixed Team"
  )

  events_tbl <- tibble::tibble(event = as.character(event)) |>
    tidyr::replace_na(list(event = "")) |>
    dplyr::mutate(event = stringr::str_trim(event))

  prefix_tbl <- tibble::tibble(
    pattern = names(prefix),
    replacement = unname(prefix)
  )

  events_tbl <- purrr::reduce2(
    .x = prefix_tbl$pattern,
    .y = prefix_tbl$replacement,
    .init = events_tbl,
    .f = function(tbl, pattern, replacement) {
      tbl |>
        dplyr::mutate(event = dplyr::if_else(
          stringr::str_starts(event, stringr::fixed(pattern)),
          stringr::str_replace(event, stringr::fixed(pattern), replacement),
          event
        ))
    }
  )

  alias_tbl <- tibble::tibble(
    event = names(alias),
    canonical = unname(alias)
  )

  events_tbl |>
    dplyr::left_join(alias_tbl, by = "event") |>
    dplyr::mutate(event = dplyr::coalesce(canonical, event)) |>
    dplyr::pull(event)
}
