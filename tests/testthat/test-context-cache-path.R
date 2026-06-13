test_that("context_cache_path() validates url", {
    expect_error(
        context_cache_path(NA_character_),
        "`url` must be a single non-missing character string"
    )

    expect_error(
        context_cache_path(c("a", "b")),
        "`url` must be a single non-missing character string"
    )

    expect_error(
        context_cache_path(""),
        "`url` must not be an empty string"
    )
})

test_that("context_cache_path() creates a stable cache path", {
    url <- "https://cancerinfocus.org/public-data/ContextLinkr/context_measures.parquet"

    path_1 <- context_cache_path(url)
    path_2 <- context_cache_path(url)

    expect_type(path_1, "character")
    expect_length(path_1, 1)
    expect_identical(path_1, path_2)
    expect_true(grepl("ContextLinkr", path_1, fixed = TRUE))
    expect_true(grepl("context_measures.parquet", path_1, fixed = TRUE))
})
