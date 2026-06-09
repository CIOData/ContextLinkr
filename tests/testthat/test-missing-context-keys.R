test_that("missing_context_keys() requires data frames", {
    context <- tibble::tibble(
        tract_geoid = "11001980000",
        deprivation_index = 0.8
    )

    expect_error(
        missing_context_keys("not data", context),
        "`\\.data` must be a data frame"
    )

    linked <- tibble::tibble(
        id = 1,
        tract_geoid = "11001980000"
    )

    expect_error(
        missing_context_keys(linked, "not context"),
        "`context` must be a data frame"
    )
})

test_that("missing_context_keys() requires join keys in both data frames", {
    linked <- tibble::tibble(
        id = 1,
        tract_geoid = "11001980000"
    )

    context <- tibble::tibble(
        GEOID = "11001980000",
        deprivation_index = 0.8
    )

    expect_error(
        missing_context_keys(linked, context),
        "`context` must contain the join key `tract_geoid`"
    )

    expect_error(
        missing_context_keys(tibble::tibble(id = 1), context, by = "GEOID"),
        "`\\.data` must contain the join key `GEOID`"
    )
})

test_that("missing_context_keys() returns keys present in data but missing from context", {
    linked <- tibble::tibble(
        id = 1:5,
        tract_geoid = c(
            "11001980000",
            "24510040100",
            "99999999999",
            "99999999999",
            NA
        )
    )

    context <- tibble::tibble(
        tract_geoid = c("11001980000", "24510040100"),
        deprivation_index = c(0.8, 0.6)
    )

    result <- missing_context_keys(linked, context)

    expect_s3_class(result, "tbl_df")
    expect_equal(nrow(result), 1)
    expect_equal(result$tract_geoid, "99999999999")
})

test_that("missing_context_keys() returns zero rows when all keys are present", {
    linked <- tibble::tibble(
        id = 1:2,
        tract_geoid = c("11001980000", "24510040100")
    )

    context <- tibble::tibble(
        tract_geoid = c("11001980000", "24510040100"),
        deprivation_index = c(0.8, 0.6)
    )

    result <- missing_context_keys(linked, context)

    expect_s3_class(result, "tbl_df")
    expect_equal(nrow(result), 0)
    expect_equal(names(result), "tract_geoid")
})

test_that("missing_context_keys() supports different join key names", {
    linked <- tibble::tibble(
        id = 1:3,
        tract_geoid = c("11001980000", "24510040100", "99999999999")
    )

    context <- tibble::tibble(
        GEOID = c("11001980000", "24510040100"),
        deprivation_index = c(0.8, 0.6)
    )

    result <- missing_context_keys(
        linked,
        context,
        by = c("tract_geoid" = "GEOID")
    )

    expect_equal(names(result), "tract_geoid")
    expect_equal(result$tract_geoid, "99999999999")
})

test_that("missing_context_keys() ignores missing keys", {
    linked <- tibble::tibble(
        id = 1:3,
        tract_geoid = c("11001980000", NA, NA)
    )

    context <- tibble::tibble(
        tract_geoid = "11001980000",
        deprivation_index = 0.8
    )

    result <- missing_context_keys(linked, context)

    expect_equal(nrow(result), 0)
})
