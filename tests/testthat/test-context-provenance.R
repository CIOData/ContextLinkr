test_that("context_provenance() reports missing provenance", {
    result <- context_provenance(
        tibble::tibble(id = 1)
    )

    expect_s3_class(result, "tbl_df")
    expect_true("has_provenance" %in% names(result))
    expect_false(result$has_provenance)
})

test_that("context_provenance() reports attached provenance", {
    x <- tibble::tibble(id = 1)

    attr(x, "contextlinkr_context_provenance") <- tibble::tibble(
        geography = "tract",
        base_url = "https://example.org",
        use_cache = TRUE,
        refresh_cache = FALSE,
        format = "wide",
        retrieved_at = Sys.time()
    )

    result <- context_provenance(x)

    expect_s3_class(result, "tbl_df")
    expect_equal(result$geography, "tract")
    expect_equal(result$base_url, "https://example.org")
    expect_true(result$use_cache)
    expect_false(result$refresh_cache)
    expect_equal(result$format, "wide")
})
