test_that("tract_summary returns a one-row tibble", {
    x <- tibble::tibble(
        id = 1:3,
        tract_geoid = c("11001980000", NA_character_, "11001006202"),
        .tract_identified = c(TRUE, FALSE, TRUE),
        .tract_state_fips = c("11", NA_character_, "11"),
        .tract_year = c(2020, 2020, 2020)
    )

    out <- tract_summary(x)

    expect_s3_class(out, "tbl_df")
    expect_equal(nrow(out), 1)
    expect_equal(out$identified, 2)
    expect_equal(out$total, 3)
    expect_equal(out$identification_rate, 2 / 3)
    expect_equal(out$identification_rate_pct, 66.7)
    expect_equal(out$state_fips, "11")
    expect_equal(out$year, "2020")
})

test_that("tract_summary errors when metadata are missing", {
    x <- tibble::tibble(id = 1:2)

    expect_error(
        tract_summary(x),
        "must contain a `.tract_identified` column"
    )
})

test_that("tract_summary requires a data frame", {
    expect_error(
        tract_summary("not a data frame"),
        "`x` must be a data frame"
    )
})
