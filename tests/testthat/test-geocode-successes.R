test_that("geocode_successes returns successful rows", {
    x <- tibble::tibble(
        id = 1:3,
        latitude = c(38.9, NA_real_, 40.7),
        longitude = c(-77.0, NA_real_, -74.0),
        .geocoded = c(TRUE, FALSE, TRUE),
        .geocode_input = c("components", "components", "components")
    )

    out <- geocode_successes(x)

    expect_s3_class(out, "tbl_df")
    expect_equal(nrow(out), 2)
    expect_equal(out$id, c(1, 3))
})

test_that("geocode_successes returns zero rows when no records geocode", {
    x <- tibble::tibble(
        id = 1:2,
        latitude = c(NA_real_, NA_real_),
        longitude = c(NA_real_, NA_real_),
        .geocoded = c(FALSE, FALSE),
        .geocode_input = c("components", "components")
    )

    out <- geocode_successes(x)

    expect_s3_class(out, "tbl_df")
    expect_equal(nrow(out), 0)
})

test_that("geocode_successes requires a data frame", {
    expect_error(
        geocode_successes("not a data frame"),
        "`x` must be a data frame"
    )
})

test_that("geocode_successes requires .geocoded column", {
    x <- tibble::tibble(id = 1:2)

    expect_error(
        geocode_successes(x),
        "must contain a `.geocoded` column"
    )
})
