test_that("add_context_provenance() requires a data frame", {
    expect_error(
        add_context_provenance(
            x = "not data",
            geography = "tract",
            base_url = "https://example.org",
            use_cache = TRUE,
            refresh_cache = FALSE,
            format = "wide"
        ),
        "`x` must be a data frame"
    )
})

test_that("add_context_provenance() attaches provenance metadata", {
    x <- tibble::tibble(id = 1)

    result <- add_context_provenance(
        x = x,
        geography = "tract",
        base_url = "https://example.org",
        use_cache = TRUE,
        refresh_cache = FALSE,
        format = "wide"
    )

    provenance <- attr(result, "contextlinkr_context_provenance", exact = TRUE)

    expect_s3_class(result, "tbl_df")
    expect_s3_class(provenance, "tbl_df")
    expect_equal(provenance$geography, "tract")
    expect_equal(provenance$base_url, "https://example.org")
    expect_true(provenance$use_cache)
    expect_false(provenance$refresh_cache)
    expect_equal(provenance$format, "wide")
})
