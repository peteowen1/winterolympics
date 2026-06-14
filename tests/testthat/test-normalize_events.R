test_that("normalize_event_names handles Freestyle prefix correctly", {
  input <- "Freestyle - Men's Moguls"
  expected <- "Freestyle Skiing - Men's Moguls"
  expect_equal(normalize_event_names(input), expected)
})

test_that("normalize_event_names handles cross-country abbreviations", {
  expect_equal(
    normalize_event_names("Cross-Country - Men's 15km (FR)"),
    "Cross-Country - Men's 15km (Free)"
  )
  expect_equal(
    normalize_event_names("Cross-Country - Men's Sprint (CL)"),
    "Cross-Country - Men's Sprint (Classic)"
  )
})

test_that("normalize_event_names handles figure skating team event", {
  input <- "Figure Skating - Team Event"
  expected <- "Figure Skating - Team"
  expect_equal(normalize_event_names(input), expected)
})

test_that("normalize_event_names handles snowboard abbreviations", {
  input <- "Snowboard - Mixed Team SBX"
  expected <- "Snowboard - Mixed Team Snowboard Cross"
  expect_equal(normalize_event_names(input), expected)
})

test_that("normalize_event_names handles ski mountaineering", {
  expect_equal(
    normalize_event_names("Ski Mountaineering - Men's Individual"),
    "Ski Mountaineering - Men's Sprint"
  )
  expect_equal(
    normalize_event_names("Ski Mountaineering - Women's Individual"),
    "Ski Mountaineering - Women's Sprint"
  )
})

test_that("normalize_event_names handles ski jumping", {
  input <- "Ski Jumping - Women's Team"
  expected <- "Ski Jumping - Mixed Team"
  expect_equal(normalize_event_names(input), expected)
})

test_that("normalize_event_names is vectorized", {
  inputs <- c(
    "Freestyle - Men's Moguls",
    "Figure Skating - Team Event",
    "Cross-Country - Men's Sprint (CL)"
  )
  expected <- c(
    "Freestyle Skiing - Men's Moguls",
    "Figure Skating - Team",
    "Cross-Country - Men's Sprint (Classic)"
  )
  expect_equal(normalize_event_names(inputs), expected)
})

test_that("normalize_event_names handles NA values", {
  input <- c("Freestyle - Men's Moguls", NA, "Figure Skating - Team Event")
  result <- normalize_event_names(input)
  expect_equal(result[2], "")  # NA becomes empty string
})

test_that("normalize_event_names trims whitespace", {
  input <- "  Freestyle - Men's Moguls  "
  expected <- "Freestyle Skiing - Men's Moguls"
  expect_equal(normalize_event_names(input), expected)
})

test_that("normalize_event_names leaves canonical names unchanged", {
  canonical <- c(
    "Alpine - Men's Downhill",
    "Biathlon - Men's Sprint 10km",
    "Speed Skating - Men's 500m"
  )
  expect_equal(normalize_event_names(canonical), canonical)
})
