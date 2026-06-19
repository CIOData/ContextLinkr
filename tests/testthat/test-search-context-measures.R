test_that("search_context_measures() validates query", {
    expect_error(
        search_context_measures(),
        "`query` is required"
    )

    expect_error(
        search_context_measures(c("population", "poverty")),
        "`query` must be a single non-missing character string"
    )

    expect_error(
        search_context_measures(NA_character_),
        "`query` must be a single non-missing character string"
    )

    expect_error(
        search_context_measures(""),
        "`query` must not be an empty string"
    )
})

test_that("search_context_measures() validates ignore_case", {
    expect_error(
        search_context_measures("population", ignore_case = NA),
        "`ignore_case` must be a single non-missing logical value"
    )

    expect_error(
        search_context_measures("population", ignore_case = c(TRUE, FALSE)),
        "`ignore_case` must be a single non-missing logical value"
    )
})

test_that("search_context_measures() finds matching Cancer InFocus measures", {
    skip_if_no_cif_integration()

    result <- search_context_measures(
        "population",
        geography = "tract"
    )

    expect_s3_class(result, "tbl_df")
    expect_true(nrow(result) > 0)
    expect_true("def" %in% names(result))

    search_text <- apply(
        result[, intersect(c("cat", "measure", "def", "source"), names(result)), drop = FALSE],
        1,
        paste,
        collapse = " "
    )

    expect_true(
        any(grepl("population", tolower(search_text), fixed = TRUE))
    )
})

test_that("search_context_measures() validates use_cache", {
    expect_error(
        search_context_measures("population", use_cache = NA),
        "`use_cache` must be a single non-missing logical value"
    )
})

test_that("search_context_measures() validates refresh_cache", {
    expect_error(
        search_context_measures("population", refresh_cache = NA),
        "`refresh_cache` must be a single non-missing logical value"
    )
})

test_that("search_context_measures returns an empty result for no matches", {
    skip_if_not(
        identical(Sys.getenv("CONTEXTLINKR_RUN_CIF_INTEGRATION"), "true"),
        message = "Set CONTEXTLINKR_RUN_CIF_INTEGRATION=true to run live Cancer InFocus integration tests."
    )

    out <- search_context_measures("zzzz_not_a_real_measure")

    expect_s3_class(out, "data.frame")
    expect_equal(nrow(out), 0L)
})
