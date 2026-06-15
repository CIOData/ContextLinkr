test_that("available_context_measures() returns expected columns", {
    skip_if_no_cif_integration()

    result <- available_context_measures("county")

    expect_s3_class(result, "tbl_df")
    expect_named(
        result,
        c("geography", "cat", "measure", "def", "fmt", "source")
    )
})

test_that("available_context_measures() includes Total Population", {
    skip_if_no_cif_integration()

    result <- available_context_measures()

    expect_true("Total Population" %in% result$def)
    expect_true(all(c("county", "tract") %in% result$geography))
})

test_that("available_context_measures() filters by geography", {
    skip_if_no_cif_integration()

    result <- available_context_measures("tract")

    expect_s3_class(result, "tbl_df")
    expect_true(nrow(result) > 0)
    expect_true(all(result$geography == "tract"))
})

test_that("available_context_measures() validates use_cache", {
    expect_error(
        available_context_measures(use_cache = NA),
        "`use_cache` must be a single non-missing logical value"
    )

    expect_error(
        available_context_measures(use_cache = c(TRUE, FALSE)),
        "`use_cache` must be a single non-missing logical value"
    )
})
