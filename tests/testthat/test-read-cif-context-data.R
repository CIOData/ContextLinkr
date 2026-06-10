test_that("read_cif_context_data() requires geographies for tract data", {
    expect_error(
        ContextLinkr:::read_cif_context_data("tract"),
        "`geographies` is required when reading tract context data"
    )
})

test_that("read_cif_context_data() can read county context data", {
    skip_if_no_cif_integration()

    result <- ContextLinkr:::read_cif_context_data("county")

    expect_s3_class(result, "tbl_df")
    expect_true(nrow(result) > 0)
    expect_true("GEOID" %in% names(result))
})

test_that("read_cif_context_data() can read tract context data by partition", {
    skip_if_no_cif_integration()

    result <- ContextLinkr:::read_cif_context_data(
        geography = "tract",
        geographies = "01001020100"
    )

    expect_s3_class(result, "tbl_df")
    expect_true(nrow(result) > 0)
    expect_true("GEOID" %in% names(result))
})
