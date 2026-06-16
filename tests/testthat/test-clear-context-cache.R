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
