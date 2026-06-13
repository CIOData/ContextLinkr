test_that("read_context_parquet() validates path", {
    expect_error(
        read_context_parquet(NA_character_),
        "`path` must be a single non-missing character string"
    )

    expect_error(
        read_context_parquet(c("a.parquet", "b.parquet")),
        "`path` must be a single non-missing character string"
    )

    expect_error(
        read_context_parquet(""),
        "`path` must not be an empty string"
    )
})

test_that("read_context_parquet() gives a friendly error for unreadable files", {
    expect_error(
        read_context_parquet("not-a-real-file.parquet"),
        "Cancer InFocus context data could not be read"
    )
})

test_that("read_context_parquet() validates use_cache", {
    expect_error(
        read_context_parquet("file.parquet", use_cache = NA),
        "`use_cache` must be a single non-missing logical value"
    )

    expect_error(
        read_context_parquet("file.parquet", use_cache = c(TRUE, FALSE)),
        "`use_cache` must be a single non-missing logical value"
    )
})
