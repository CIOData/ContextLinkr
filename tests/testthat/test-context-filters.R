test_that("context_successes() requires a data frame", {
    expect_error(
        context_successes("not a data frame"),
        "`\\.data` must be a data frame"
    )
})

test_that("context_failures() requires a data frame", {
    expect_error(
        context_failures("not a data frame"),
        "`\\.data` must be a data frame"
    )
})

test_that("context_successes() requires .context_joined", {
    expect_error(
        context_successes(tibble::tibble(id = 1)),
        "must contain a `.context_joined` column"
    )
})

test_that("context_failures() requires .context_joined", {
    expect_error(
        context_failures(tibble::tibble(id = 1)),
        "must contain a `.context_joined` column"
    )
})

test_that("context_successes() returns context-joined rows", {
    joined <- tibble::tibble(
        id = 1:4,
        .context_joined = c(TRUE, FALSE, TRUE, NA)
    )

    result <- context_successes(joined)

    expect_s3_class(result, "tbl_df")
    expect_equal(nrow(result), 2)
    expect_equal(result$id, c(1, 3))
    expect_true(all(result$.context_joined))
})

test_that("context_failures() returns rows not context-joined", {
    joined <- tibble::tibble(
        id = 1:4,
        .context_joined = c(TRUE, FALSE, TRUE, NA)
    )

    result <- context_failures(joined)

    expect_s3_class(result, "tbl_df")
    expect_equal(nrow(result), 2)
    expect_equal(result$id, c(2, 4))
})

test_that("context filters preserve additional columns", {
    joined <- tibble::tibble(
        id = 1:3,
        tract_geoid = c("11001980000", "99999999999", "24510040100"),
        deprivation_index = c(0.8, NA, 0.6),
        .context_joined = c(TRUE, FALSE, TRUE)
    )

    successes <- context_successes(joined)
    failures <- context_failures(joined)

    expect_true("tract_geoid" %in% names(successes))
    expect_true("deprivation_index" %in% names(successes))
    expect_true("tract_geoid" %in% names(failures))
    expect_true("deprivation_index" %in% names(failures))
    expect_equal(successes$id, c(1, 3))
    expect_equal(failures$id, 2)
})

test_that("context filters handle zero-row inputs", {
    joined <- tibble::tibble(
        id = integer(),
        .context_joined = logical()
    )

    expect_equal(nrow(context_successes(joined)), 0)
    expect_equal(nrow(context_failures(joined)), 0)
})
