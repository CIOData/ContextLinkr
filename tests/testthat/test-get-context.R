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

    source_data <- read_cif_context_data(
        geography = "tract",
        geographies = "01001020100"
    )

    expect_true(nrow(source_data) > 0)

    test_geoid <- source_data$GEOID[[1]]
    test_measure <- source_data$def[[1]]

    result <- get_context(
        geographies = test_geoid,
        measures = test_measure,
        geography = "tract"
    )

    expect_s3_class(result, "tbl_df")
    expect_true(nrow(result) > 0)
    expect_true("GEOID" %in% names(result))

    provenance <- context_provenance(result)

    expect_s3_class(provenance, "tbl_df")
    expect_equal(provenance$geography, "tract")
    expect_true("base_url" %in% names(provenance))
    expect_true("retrieved_at" %in% names(provenance))
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

test_that("get_context() validates format", {
    expect_error(
        get_context(
            geographies = character(),
            measures = "Total Population",
            geography = "tract",
            format = "tidy"
        ),
        "`geographies` must contain at least one value|`format` must be one of"
    )
})

test_that("get_context() can return wide context data", {
    skip_if_no_cif_integration()

    result <- get_context(
        geographies = "01001",
        measures = "Total Population",
        geography = "county",
        format = "wide"
    )

    expect_s3_class(result, "tbl_df")
    expect_equal(nrow(result), 1)
    expect_true("GEOID" %in% names(result))
    expect_true("Total Population" %in% names(result))
})

test_that("get_context() validates use_cache", {
    expect_error(
        get_context(
            geographies = "11001006202",
            measures = "Total Population",
            geography = "tract",
            use_cache = NA
        ),
        "`use_cache` must be a single non-missing logical value"
    )
})

test_that("get_context() validates refresh_cache", {
    expect_error(
        get_context(
            geographies = "11001006202",
            measures = "Total Population",
            geography = "tract",
            refresh_cache = NA
        ),
        "`refresh_cache` must be a single non-missing logical value"
    )
})

test_that("get_context wide output returns one row per tract GEOID", {
    skip_if_not(
        identical(Sys.getenv("CONTEXTLINKR_RUN_CIF_INTEGRATION"), "true"),
        message = "CIF integration tests are opt-in."
    )

    tracts <- c("21067003600", "21067004205")

    out <- get_context(
        geographies = tracts,
        geography = "tract",
        measures = NULL,
        format = "wide",
        use_cache = TRUE,
        refresh_cache = FALSE
    )

    expect_equal(nrow(out), length(tracts))
    expect_true("GEOID" %in% names(out))
    expect_equal(anyDuplicated(out$GEOID), 0L)
})

test_that("get_context errors clearly for malformed tract GEOIDs", {
    expect_error(
        get_context(
            geographies = "not_a_geoid",
            geography = "tract",
            format = "wide",
            use_cache = TRUE,
            refresh_cache = FALSE
        ),
        "11-digit Census tract GEOIDs"
    )
})

test_that("get_context errors clearly for unsupported tract state FIPS", {
    expect_error(
        get_context(
            geographies = "99999999999",
            geography = "tract",
            format = "wide",
            use_cache = TRUE,
            refresh_cache = FALSE
        ),
        "unsupported state FIPS code"
    )
})
