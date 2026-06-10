test_that("tract_failures returns failed rows", {
    x <- tibble::tibble(
        id = 1:3,
        tract_geoid = c("11001980000", NA_character_, "11001006202"),
        .tract_identified = c(TRUE, FALSE, TRUE),
        .tract_state_fips = c("11", "11", "11"),
        .tract_year = c(2020, 2020, 2020)
    )

    out <- tract_failures(x)

    expect_s3_class(out, "tbl_df")
    expect_equal(nrow(out), 1)
    expect_equal(out$id, 2)
})

test_that("tract_failures returns zero rows when all tracts identified", {
    x <- tibble::tibble(
        id = 1:2,
        tract_geoid = c("11001980000", "11001006202"),
        .tract_identified = c(TRUE, TRUE),
        .tract_state_fips = c("11", "11"),
        .tract_year = c(2020, 2020)
    )

    out <- tract_failures(x)

    expect_s3_class(out, "tbl_df")
    expect_equal(nrow(out), 0)
})

test_that("tract_failures requires a data frame", {
    expect_error(
        tract_failures("not a data frame"),
        "`x` must be a data frame"
    )
})

test_that("tract_failures requires tract metadata", {
    x <- tibble::tibble(id = 1:2)

    expect_error(
        tract_failures(x),
        "must contain a `.tract_identified` column"
    )
})
