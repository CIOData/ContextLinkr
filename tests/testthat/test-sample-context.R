test_that("sample_context has expected columns", {
    expect_s3_class(sample_context, "tbl_df")

    expect_named(
        sample_context,
        c(
            "tract_geoid",
            "deprivation_index",
            "rurality",
            "median_household_income",
            "pct_uninsured"
        )
    )
})

test_that("sample_context has valid tract GEOIDs", {
    expect_true(all(nchar(sample_context$tract_geoid) == 11))
    expect_false(anyNA(sample_context$tract_geoid))
    expect_equal(anyDuplicated(sample_context$tract_geoid), 0)
})

test_that("sample_context works with join_context()", {
    linked <- tibble::tibble(
        id = 1:3,
        tract_geoid = c("11001980000", "24510040100", "99999999999")
    )

    result <- join_context(linked, sample_context)

    expect_equal(nrow(result), 3)
    expect_true("deprivation_index" %in% names(result))
    expect_true("median_household_income" %in% names(result))
    expect_equal(result$.context_joined, c(TRUE, TRUE, FALSE))
})
