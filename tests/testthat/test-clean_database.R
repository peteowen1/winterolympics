test_that("read_source_db stops if no files exist", {
  expect_error(
    read_source_db(paths = "nonexistent_file.csv"),
    "Cannot find any source DB"
  )
})

test_that("clean_athlete_database requires event column", {
  db_no_event <- tibble::tibble(athlete = "Test", prob_gold = 0.5)
  expect_error(
    clean_athlete_database(db_no_event),
    "Input DB must have an 'event' column"
  )
})

test_that("clean_athlete_database returns list with data and diagnostics", {
  # Create minimal test data with canonical event names
  db <- tibble::tibble(
    event = c("Alpine - Men's Downhill", "Biathlon - Men's Sprint 10km"),
    athlete = c("Athlete A", "Athlete B"),
    prob_gold = c(0.3, 0.2),
    prob_silver = c(0.3, 0.3),
    prob_bronze = c(0.2, 0.2)
  )

  result <- clean_athlete_database(db)

  expect_type(result, "list")
  expect_true("data" %in% names(result))
  expect_true("diagnostics" %in% names(result))
})

test_that("clean_athlete_database normalizes event names", {
  # Create test data with non-canonical names
  db <- tibble::tibble(
    event = c("Freestyle - Men's Moguls", "Figure Skating - Team Event"),
    athlete = c("Athlete A", "Athlete B"),
    prob_gold = c(0.3, 0.2),
    prob_silver = c(0.3, 0.3),
    prob_bronze = c(0.2, 0.2)
  )

  result <- clean_athlete_database(db)

  expect_true("Freestyle Skiing - Men's Moguls" %in% result$data$event)
  expect_true("Figure Skating - Team" %in% result$data$event)
  expect_true("event_original" %in% names(result$data))
})

test_that("clean_athlete_database filters to canonical events only", {
  # Mix of canonical and non-canonical events
  db <- tibble::tibble(
    event = c("Alpine - Men's Downhill", "Fake Event - Not Real"),
    athlete = c("Athlete A", "Athlete B"),
    prob_gold = c(0.3, 0.2),
    prob_silver = c(0.3, 0.3),
    prob_bronze = c(0.2, 0.2)
  )

  result <- clean_athlete_database(db)

  expect_equal(nrow(result$data), 1)
  expect_equal(result$data$event[1], "Alpine - Men's Downhill")
})

test_that("clean_athlete_database diagnostics include expected fields", {
  db <- tibble::tibble(
    event = c("Alpine - Men's Downhill"),
    athlete = c("Athlete A"),
    prob_gold = c(0.3),
    prob_silver = c(0.3),
    prob_bronze = c(0.2)
  )

  result <- clean_athlete_database(db)
  diag <- result$diagnostics

  expect_true("n_unique_events" %in% names(diag))
  expect_true("missing_events" %in% names(diag))
  expect_true("extra_events" %in% names(diag))
  expect_true("sums" %in% names(diag))
})

test_that("clean_athlete_database detects missing events", {
  # Only provide 1 event when 116 are canonical
  db <- tibble::tibble(
    event = c("Alpine - Men's Downhill"),
    athlete = c("Athlete A"),
    prob_gold = c(0.3),
    prob_silver = c(0.3),
    prob_bronze = c(0.2)
  )

  result <- clean_athlete_database(db)

  expect_equal(result$diagnostics$n_unique_events, 1)
  expect_equal(length(result$diagnostics$missing_events), 115)
})

test_that("clean_athlete_database stops if no matching events", {
  db <- tibble::tibble(
    event = c("Completely Fake Event"),
    athlete = c("Athlete A"),
    prob_gold = c(0.3)
  )

  expect_error(
    clean_athlete_database(db),
    "No rows match canonical 116 events"
  )
})

test_that("write_clean_outputs creates expected output structure", {
  # Create minimal cleaned result
  db <- tibble::tibble(
    event = c("Alpine - Men's Downhill"),
    athlete = c("Athlete A"),
    prob_gold = c(0.3),
    prob_silver = c(0.3),
    prob_bronze = c(0.2)
  )

  result <- clean_athlete_database(db)

  # Test that function returns paths invisibly
  output <- write_clean_outputs(
    result,
    out_csv = tempfile(fileext = ".csv"),
    sums_csv = tempfile(fileext = ".csv")
  )

  expect_type(output, "character")
  expect_equal(length(output), 2)
  expect_true("out_csv" %in% names(output))
  expect_true("sums_csv" %in% names(output))

  # Check files were created
  expect_true(file.exists(output["out_csv"]))
  expect_true(file.exists(output["sums_csv"]))

  # Clean up
  file.remove(output["out_csv"])
  file.remove(output["sums_csv"])
})
