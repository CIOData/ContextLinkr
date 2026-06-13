test_that("is_remote_path() validates path", {
    expect_error(
        is_remote_path(NA_character_),
        "`path` must be a single non-missing character string"
    )

    expect_error(
        is_remote_path(c("a", "b")),
        "`path` must be a single non-missing character string"
    )
})

test_that("is_remote_path() detects http and https URLs", {
    expect_true(is_remote_path("https://example.org/file.parquet"))
    expect_true(is_remote_path("http://example.org/file.parquet"))
    expect_false(is_remote_path("file.parquet"))
    expect_false(is_remote_path("/tmp/file.parquet"))
})
