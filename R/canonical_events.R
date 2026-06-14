#' Return the canonical list of 116 Milan-Cortina 2026 Winter Olympic events
#'
#' This function builds a tibble containing the official 116 events for the
#' 2026 Winter Olympics in Milan-Cortina, organized by sport. Each row
#' represents a single event with columns for Sport, EventName, and a combined
#' Event_full identifier.
#'
#' @return A tibble with 116 rows and 3 columns:
#'   \describe{
#'     \item{Sport}{The sport category (e.g., "Alpine", "Biathlon")}
#'     \item{EventName}{The specific event name (e.g., "Men's Downhill")}
#'     \item{Event_full}{Combined format: "Sport - EventName"}
#'   }
#'
#' @export
#'
#' @examples
#' # Get the canonical event list
#' events <- canonical_events()
#' nrow(events)  # 116
#'
#' # View events by sport
#' library(dplyr)
#' events |> count(Sport)
#'
#' @importFrom tibble tibble
#' @importFrom dplyr bind_rows mutate
#' @importFrom stringr str_c
canonical_events <- function() {
  add <- function(sport, items) {
    tibble::tibble(Sport = sport, EventName = items)
  }

  events <- dplyr::bind_rows(
    add("Alpine", c(
      "Men's Downhill", "Men's Super-G", "Men's Giant Slalom", "Men's Slalom", "Men's Team Combined",
      "Women's Downhill", "Women's Super-G", "Women's Giant Slalom", "Women's Slalom", "Women's Team Combined"
    )),
    add("Biathlon", c(
      "Men's Sprint 10km", "Men's Individual 20km", "Men's Pursuit 12.5km", "Men's Mass Start 15km", "Men's 4x7.5km Relay",
      "Women's Sprint 7.5km", "Women's Individual 15km", "Women's Pursuit 10km", "Women's Mass Start 12.5km", "Women's 4x6km Relay",
      "Mixed 4x6km Relay"
    )),
    add("Bobsleigh", c("2-Man", "4-Man", "2-Woman", "Women's Monobob")),
    add("Skeleton", c("Men", "Women", "Mixed Team")),
    add("Luge", c("Men's Singles", "Women's Singles", "Men's Doubles", "Women's Doubles", "Team Relay")),
    add("Cross-Country", c(
      "Men's Sprint (Classic)", "Men's 15km (Free)", "Men's Skiathlon 2x10km", "Men's 50km (Classic)", "Men's Team Sprint (Free)", "Men's 4x10km Relay",
      "Women's Sprint (Classic)", "Women's 10km (Free)", "Women's Skiathlon 2x7.5km", "Women's 50km (Classic)", "Women's Team Sprint (Free)", "Women's 4x5km Relay"
    )),
    add("Curling", c("Men's Tournament", "Women's Tournament", "Mixed Doubles")),
    add("Figure Skating", c("Men's Singles", "Women's Singles", "Pairs", "Ice Dance", "Team")),
    add("Freestyle Skiing", c(
      "Men's Moguls", "Women's Moguls",
      "Men's Dual Moguls", "Women's Dual Moguls",
      "Men's Aerials", "Women's Aerials", "Mixed Team Aerials",
      "Men's Ski Cross", "Women's Ski Cross",
      "Men's Halfpipe (Ski)", "Women's Halfpipe (Ski)",
      "Men's Slopestyle (Ski)", "Women's Slopestyle (Ski)",
      "Men's Big Air (Ski)", "Women's Big Air (Ski)"
    )),
    add("Ice Hockey", c("Men's Tournament", "Women's Tournament")),
    add("Short Track", c(
      "Men's 500m", "Men's 1000m", "Men's 1500m",
      "Women's 500m", "Women's 1000m", "Women's 1500m",
      "Men's 5000m Relay", "Women's 3000m Relay", "Mixed Team Relay"
    )),
    add("Ski Jumping", c(
      "Men's Normal Hill", "Men's Large Hill",
      "Women's Normal Hill", "Women's Large Hill",
      "Men's Team", "Mixed Team"
    )),
    add("Nordic Combined", c(
      "Men's Individual Normal Hill/10km",
      "Men's Individual Large Hill/10km",
      "Men's Team Large Hill/2x7.5km"
    )),
    add("Ski Mountaineering", c("Men's Sprint", "Women's Sprint", "Mixed Relay")),
    add("Snowboard", c(
      "Men's Halfpipe", "Women's Halfpipe",
      "Men's Slopestyle", "Women's Slopestyle",
      "Men's Big Air", "Women's Big Air",
      "Men's Snowboard Cross", "Women's Snowboard Cross", "Mixed Team Snowboard Cross",
      "Men's Parallel Giant Slalom", "Women's Parallel Giant Slalom"
    )),
    add("Speed Skating", c(
      "Men's 500m", "Men's 1000m", "Men's 1500m", "Men's 5000m", "Men's 10000m", "Men's Mass Start", "Men's Team Pursuit",
      "Women's 500m", "Women's 1000m", "Women's 1500m", "Women's 3000m", "Women's 5000m", "Women's Mass Start", "Women's Team Pursuit"
    ))
  ) |>
    dplyr::mutate(Event_full = stringr::str_c(Sport, EventName, sep = " - "))

  stopifnot(nrow(events) == 116)
  events
}
