test_that("tract_successes returns successful rows", {
    x <- tibble::tibble(
        id = 1:3,
        tract_geoid = c("11001980000", NA_character_, "11001006202"),
        .tract_identified = c(TRUE, FALSE, TRUE),
        .tract_state = c("DC", "DC", "DC"),
        .tract_year = c(2020, 2020, 2020)
    )

    out <- tract_successes(x)

    expect_s3_class(out, "tbl_df")
    expect_equal(nrow(out), 2)
    expect_equal(out$id, c(1, 3))
})

test_that("tract_successes returns zero rows when no tracts identified", {
    x <- tibble::tibble(
        id = 1:2,
        tract_geoid = c(NA_character_, NA_character_),
        .tract_identified = c(FALSE, FALSE),
        .tract_state = c("DC", "DC"),
        .tract_year = c(2020, 2020)
    )

    out <- tract_successes(x)

    expect_s3_class(out, "tbl_df")
    expect_equal(nrow(out), 0)
})

test_that("tract_successes requires a data frame", {
    expect_error(
        tract_successes("not a data frame"),
        "`x` must be a data frame"
    )
})

test_that("tract_successes requires tract metadata", {
    x <- tibble::tibble(id = 1:2)

    expect_error(
        tract_successes(x),
        "must contain a `.tract_identified` column"
    )
})
