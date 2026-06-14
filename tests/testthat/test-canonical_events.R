test_that("canonical_events returns exactly 116 events", {
  events <- canonical_events()
  expect_equal(nrow(events), 116)
})

test_that("canonical_events has required columns", {
  events <- canonical_events()
  expect_true(all(c("Sport", "EventName", "Event_full") %in% names(events)))
})

test_that("canonical_events has no duplicates", {
  events <- canonical_events()
  expect_equal(nrow(events), nrow(dplyr::distinct(events, Event_full)))
})

test_that("canonical_events Event_full follows format 'Sport - EventName'", {
  events <- canonical_events()
  # Check that Event_full is correctly formatted
  expected <- paste(events$Sport, events$EventName, sep = " - ")
  expect_equal(events$Event_full, expected)
})

test_that("canonical_events includes key sports", {
  events <- canonical_events()
  key_sports <- c("Alpine", "Biathlon", "Figure Skating", "Ice Hockey",
                  "Speed Skating", "Snowboard", "Freestyle Skiing")
  expect_true(all(key_sports %in% events$Sport))
})

test_that("canonical_events is a tibble", {
  events <- canonical_events()
  expect_s3_class(events, "tbl_df")
})
