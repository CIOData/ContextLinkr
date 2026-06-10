test_that("geocode_failures returns failed rows", {
    x <- tibble::tibble(
        id = 1:3,
        latitude = c(38.9, NA_real_, 40.7),
        longitude = c(-77.0, NA_real_, -74.0),
        .geocoded = c(TRUE, FALSE, TRUE),
        .geocode_input = c("components", "components", "components")
    )

    out <- geocode_failures(x)

    expect_s3_class(out, "tbl_df")
    expect_equal(nrow(out), 1)
    expect_equal(out$id, 2)
})

test_that("geocode_failures returns zero rows when all records geocode", {
    x <- tibble::tibble(
        id = 1:2,
        latitude = c(38.9, 40.7),
        longitude = c(-77.0, -74.0),
        .geocoded = c(TRUE, TRUE),
        .geocode_input = c("components", "components")
    )

    out <- geocode_failures(x)

    expect_s3_class(out, "tbl_df")
    expect_equal(nrow(out), 0)
})

test_that("geocode_failures requires a data frame", {
    expect_error(
        geocode_failures("not a data frame"),
        "`x` must be a data frame"
    )
})

test_that("geocode_failures requires .geocoded column", {
    x <- tibble::tibble(id = 1:2)

    expect_error(
        geocode_failures(x),
        "must contain a `.geocoded` column"
    )
})
