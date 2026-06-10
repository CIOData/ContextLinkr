test_that("geocode_summary returns a one-row tibble", {
    x <- tibble::tibble(id = 1:5)

    attr(x, "contextlinkr_geocode_summary") <- list(
        matched = 5,
        total = 5,
        match_rate = 1,
        geocoder = "osm"
    )

    out <- geocode_summary(x)

    expect_s3_class(out, "tbl_df")
    expect_equal(nrow(out), 1)
    expect_equal(out$matched, 5)
    expect_equal(out$total, 5)
    expect_equal(out$match_rate, 1)
    expect_equal(out$match_rate_pct, 100)
    expect_equal(out$geocoder, "osm")
})

test_that("geocode_summary collapses multiple geocoders", {
    x <- tibble::tibble(id = 1:5)

    attr(x, "contextlinkr_geocode_summary") <- list(
        matched = 5,
        total = 5,
        match_rate = 1,
        geocoder = c("census_batch", "census_single")
    )

    out <- geocode_summary(x)

    expect_equal(out$geocoder, "census_batch, census_single")
})

test_that("geocode_summary errors when metadata are missing", {
    x <- tibble::tibble(id = 1:5)

    expect_error(
        geocode_summary(x),
        "does not contain ContextLinkr geocoding summary metadata"
    )
})
