test_that("link_summary() requires a data frame", {
    expect_error(
        link_summary("not a data frame"),
        "`\\.data` must be a data frame"
    )
})

test_that("link_summary() requires link status columns", {
    expect_error(
        link_summary(tibble::tibble(id = 1)),
        "requires `.geocoded` and/or `.tract_identified`"
    )
})

test_that("link_summary() summarizes geocoding and tract identification", {
    linked <- tibble::tibble(
        id = 1:3,
        .geocoded = c(TRUE, TRUE, FALSE),
        .tract_identified = c(TRUE, TRUE, FALSE),
        .tract_state_fips = c("11", "11", NA),
        .tract_year = c(2023, 2023, 2023)
    )

    result <- link_summary(linked)

    expect_s3_class(result, "tbl_df")
    expect_equal(result$total, 3)
    expect_equal(result$geocoded, 2)
    expect_equal(result$geocode_rate, 2 / 3)
    expect_equal(result$geocode_rate_pct, 66.7)
    expect_equal(result$tract_identified, 2)
    expect_equal(result$tract_identification_rate, 2 / 3)
    expect_equal(result$tract_identification_rate_pct, 66.7)
    expect_equal(result$state_fips, "11")
    expect_equal(result$year, "2023")
})

test_that("link_summary() works for coordinate-only tract results", {
    linked <- tibble::tibble(
        id = 1:2,
        .tract_identified = c(TRUE, FALSE),
        .tract_state_fips = c("11", NA),
        .tract_year = c(2023, 2023)
    )

    result <- link_summary(linked)

    expect_equal(result$total, 2)
    expect_true(is.na(result$geocoded))
    expect_true(is.na(result$geocode_rate))
    expect_true(is.na(result$geocode_rate_pct))
    expect_equal(result$tract_identified, 1)
    expect_equal(result$tract_identification_rate, 0.5)
    expect_equal(result$tract_identification_rate_pct, 50)
    expect_equal(result$state_fips, "11")
    expect_equal(result$year, "2023")
})

test_that("link_summary() works for geocoding-only results", {
    linked <- tibble::tibble(
        id = 1:2,
        .geocoded = c(TRUE, FALSE)
    )

    result <- link_summary(linked)

    expect_equal(result$total, 2)
    expect_equal(result$geocoded, 1)
    expect_equal(result$geocode_rate, 0.5)
    expect_equal(result$geocode_rate_pct, 50)
    expect_true(is.na(result$tract_identified))
    expect_true(is.na(result$tract_identification_rate))
    expect_true(is.na(result$tract_identification_rate_pct))
})

test_that("link_summary() handles zero-row linked results", {
    linked <- tibble::tibble(
        id = integer(),
        .geocoded = logical(),
        .tract_identified = logical(),
        .tract_state_fips = character(),
        .tract_year = numeric()
    )

    result <- link_summary(linked)

    expect_equal(result$total, 0)
    expect_equal(result$geocoded, 0)
    expect_true(is.na(result$geocode_rate))
    expect_true(is.na(result$geocode_rate_pct))
    expect_equal(result$tract_identified, 0)
    expect_true(is.na(result$tract_identification_rate))
    expect_true(is.na(result$tract_identification_rate_pct))
    expect_true(is.na(result$state_fips))
    expect_true(is.na(result$year))
})
