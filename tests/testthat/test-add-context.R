test_that("add_context() requires a data frame", {
    expect_error(
        add_context("not data"),
        "`.data` must be a data frame"
    )
})

test_that("add_context() requires the tract column", {
    expect_error(
        add_context(tibble::tibble(id = 1), tract_col = tract_geoid),
        "`.data` must contain the tract column `tract_geoid`"
    )
})

test_that("add_context() handles records with no tract IDs", {
    records <- tibble::tibble(
        id = 1:2,
        tract_geoid = c(NA_character_, "")
    )

    result <- add_context(records)

    expect_s3_class(result, "tbl_df")
    expect_true(".context_joined" %in% names(result))
    expect_equal(result$.context_joined, c(FALSE, FALSE))

    summary_attr <- attr(result, "contextlinkr_context_summary", exact = TRUE)

    expect_type(summary_attr, "list")
    expect_equal(summary_attr$joined, 0L)
    expect_equal(summary_attr$total, 2L)
    expect_equal(summary_attr$join_rate, 0)
})

test_that("add_context() can use a custom tract column", {
    skip_if_no_cif_integration()

    records <- tibble::tibble(
        id = 1,
        my_tract = "01001020100"
    )

    result <- add_context(
        records,
        tract_col = my_tract,
        measures = "Total Population"
    )

    expect_s3_class(result, "tbl_df")
    expect_true("Total Population" %in% names(result))
    expect_true(".context_joined" %in% names(result))
})

test_that("add_context() validates use_cache", {
    expect_error(
        add_context(
            tibble::tibble(id = 1, tract_geoid = "11001006202"),
            use_cache = NA
        ),
        "`use_cache` must be a single non-missing logical value"
    )
})

test_that("add_context() validates refresh_cache", {
    expect_error(
        add_context(
            tibble::tibble(id = 1, tract_geoid = "11001006202"),
            refresh_cache = NA
        ),
        "`refresh_cache` must be a single non-missing logical value"
    )
})

test_that("add_context joins all default context measures without duplicate tract keys", {
    skip_if_not(
        identical(Sys.getenv("CONTEXTLINKR_RUN_CIF_INTEGRATION"), "true"),
        message = "CIF integration tests are opt-in."
    )

    test_records <- data.frame(
        person_id = c("test_001", "test_002"),
        tract_geoid = c("21067003600", "21067004205")
    )

    out <- add_context(
        .data = test_records,
        tract_col = "tract_geoid",
        measures = NULL,
        use_cache = TRUE,
        refresh_cache = FALSE
    )

    expect_equal(nrow(out), nrow(test_records))
    expect_true("person_id" %in% names(out))
    expect_true("tract_geoid" %in% names(out))
    expect_gt(ncol(out), ncol(test_records))
    expect_equal(anyDuplicated(out$tract_geoid), 0L)
})
