test_that("context_summary() requires a data frame", {
    expect_error(
        context_summary("not a data frame"),
        "`\\.data` must be a data frame"
    )
})

test_that("context_summary() requires .context_joined", {
    expect_error(
        context_summary(tibble::tibble(id = 1)),
        "must contain a `.context_joined` column"
    )
})

test_that("context_summary() summarizes context join results", {
    joined <- tibble::tibble(
        id = 1:4,
        .context_joined = c(TRUE, FALSE, TRUE, FALSE)
    )

    result <- context_summary(joined)

    expect_s3_class(result, "tbl_df")
    expect_equal(result$joined, 2)
    expect_equal(result$total, 4)
    expect_equal(result$join_rate, 0.5)
    expect_equal(result$join_rate_pct, 50)
})

test_that("context_summary() treats NA context status as not joined", {
    joined <- tibble::tibble(
        id = 1:4,
        .context_joined = c(TRUE, FALSE, TRUE, NA)
    )

    result <- context_summary(joined)

    expect_equal(result$joined, 2)
    expect_equal(result$total, 4)
    expect_equal(result$join_rate, 0.5)
    expect_equal(result$join_rate_pct, 50)
})

test_that("context_summary() handles zero-row inputs", {
    joined <- tibble::tibble(
        id = integer(),
        .context_joined = logical()
    )

    result <- context_summary(joined)

    expect_equal(result$joined, 0)
    expect_equal(result$total, 0)
    expect_true(is.na(result$join_rate))
    expect_true(is.na(result$join_rate_pct))
})
