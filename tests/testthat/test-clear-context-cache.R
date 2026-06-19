test_that("clear_context_cache() validates confirm", {
    expect_error(
        clear_context_cache(),
        "Set `confirm = TRUE` to clear the ContextLinkr cache"
    )

    expect_error(
        clear_context_cache(confirm = NA),
        "`confirm` must be a single non-missing logical value"
    )

    expect_error(
        clear_context_cache(confirm = c(TRUE, FALSE)),
        "`confirm` must be a single non-missing logical value"
    )
})

test_that("clear_context_cache() returns a clearing summary", {
    result <- clear_context_cache(confirm = TRUE)

    expect_s3_class(result, "tbl_df")
    expect_true("cache_dir" %in% names(result))
    expect_true("files_removed" %in% names(result))
    expect_true("cache_exists" %in% names(result))
    expect_equal(nrow(result), 1L)
})

test_that("context_cache_info works when cache is empty", {
    clear_context_cache(confirm = TRUE)

    info <- context_cache_info()

    expect_s3_class(info, "data.frame")
})

test_that("get_context can rebuild cache after clearing", {
    skip_if_not(
        identical(Sys.getenv("CONTEXTLINKR_RUN_CIF_INTEGRATION"), "true"),
        message = "CIF integration tests are opt-in."
    )

    clear_context_cache(confirm = TRUE)

    out <- get_context(
        geographies = "21067003600",
        measures = "Total Population",
        geography = "tract",
        format = "wide",
        use_cache = TRUE,
        refresh_cache = FALSE
    )

    expect_equal(nrow(out), 1L)
    expect_true("Total Population" %in% names(out))

    info <- context_cache_info()
    expect_s3_class(info, "data.frame")
})
