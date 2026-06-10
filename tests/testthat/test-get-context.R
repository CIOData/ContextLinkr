test_that("get_context() validates requests before retrieval", {
    expect_error(
        get_context(
            geographies = character(),
            measures = "Total Population",
            geography = "tract"
        ),
        "`geographies` must contain at least one value"
    )
})

test_that("get_context() retrieves tract context data", {
    skip_if_no_cif_integration()

    result <- get_context(
        geographies = "01001020100",
        measures = "Total Population",
        geography = "tract"
    )

    expect_s3_class(result, "tbl_df")
    expect_true(nrow(result) > 0)
    expect_true(all(result$GEOID == "01001020100"))
    expect_true(all(result$def == "Total Population"))
})

test_that("get_context() retrieves county context data", {
    skip_if_no_cif_integration()

    result <- get_context(
        geographies = "01001",
        measures = "Total Population",
        geography = "county"
    )

    expect_s3_class(result, "tbl_df")
    expect_true(nrow(result) > 0)
    expect_true(all(result$GEOID == "01001"))
    expect_true(all(result$def == "Total Population"))
})
