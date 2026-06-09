test_that("join_context() requires data frames", {
    context <- tibble::tibble(
        tract_geoid = "11001980000",
        deprivation_index = 0.8
    )

    expect_error(
        join_context("not data", context),
        "`\\.data` must be a data frame"
    )

    linked <- tibble::tibble(
        id = 1,
        tract_geoid = "11001980000"
    )

    expect_error(
        join_context(linked, "not context"),
        "`context` must be a data frame"
    )
})

test_that("join_context() validates by", {
    linked <- tibble::tibble(
        id = 1,
        tract_geoid = "11001980000"
    )

    context <- tibble::tibble(
        tract_geoid = "11001980000",
        deprivation_index = 0.8
    )

    expect_error(
        join_context(linked, context, by = character()),
        "`by` must be a single non-missing character string or a named"
    )

    expect_error(
        join_context(linked, context, by = NA_character_),
        "`by` must be a single non-missing character string or a named"
    )

    expect_error(
        join_context(linked, context, by = ""),
        "`by` must specify non-empty join key names"
    )
})

test_that("join_context() requires join key in both data frames", {
    linked <- tibble::tibble(
        id = 1,
        tract_geoid = "11001980000"
    )

    context <- tibble::tibble(
        geoid = "11001980000",
        deprivation_index = 0.8
    )

    expect_error(
        join_context(linked, context),
        "`context` must contain the join key `tract_geoid`"
    )

    expect_error(
        join_context(tibble::tibble(id = 1), context, by = "geoid"),
        "`\\.data` must contain the join key `geoid`"
    )
})

test_that("join_context() joins contextual variables by tract_geoid", {
    linked <- tibble::tibble(
        id = 1:3,
        tract_geoid = c("11001980000", "24510040100", NA)
    )

    context <- tibble::tibble(
        tract_geoid = c("11001980000", "24510040100"),
        deprivation_index = c(0.8, 0.6),
        rurality = c("urban", "urban")
    )

    result <- join_context(linked, context)

    expect_s3_class(result, "tbl_df")
    expect_equal(nrow(result), 3)
    expect_equal(result$id, 1:3)
    expect_equal(result$deprivation_index, c(0.8, 0.6, NA))
    expect_equal(result$rurality, c("urban", "urban", NA))
    expect_equal(result$.context_joined, c(TRUE, TRUE, FALSE))
})

test_that("join_context() preserves unmatched linked records", {
    linked <- tibble::tibble(
        id = 1:2,
        tract_geoid = c("11001980000", "99999999999")
    )

    context <- tibble::tibble(
        tract_geoid = "11001980000",
        deprivation_index = 0.8
    )

    result <- join_context(linked, context)

    expect_equal(nrow(result), 2)
    expect_equal(result$deprivation_index, c(0.8, NA))
    expect_equal(result$.context_joined, c(TRUE, FALSE))
})

test_that("join_context() rejects duplicate context keys", {
    linked <- tibble::tibble(
        id = 1,
        tract_geoid = "11001980000"
    )

    context <- tibble::tibble(
        tract_geoid = c("11001980000", "11001980000"),
        deprivation_index = c(0.8, 0.9)
    )

    expect_error(
        join_context(linked, context),
        "`context` must contain no duplicate values in `tract_geoid`"
    )
})

test_that("join_context() supports a custom join key", {
    linked <- tibble::tibble(
        id = 1:2,
        GEOID = c("11001980000", "24510040100")
    )

    context <- tibble::tibble(
        GEOID = c("11001980000", "24510040100"),
        deprivation_index = c(0.8, 0.6)
    )

    result <- join_context(linked, context, by = "GEOID")

    expect_equal(result$deprivation_index, c(0.8, 0.6))
})

test_that("join_context() handles duplicate non-key column names with suffixes", {
    linked <- tibble::tibble(
        id = 1,
        tract_geoid = "11001980000",
        source = "individual"
    )

    context <- tibble::tibble(
        tract_geoid = "11001980000",
        source = "context",
        deprivation_index = 0.8
    )

    result <- join_context(linked, context)

    expect_true("source" %in% names(result))
    expect_true("source_context" %in% names(result))
    expect_equal(result$source, "individual")
    expect_equal(result$source_context, "context")
})

test_that("join_context() adds context join status", {
    linked <- tibble::tibble(
        id = 1:3,
        tract_geoid = c("11001980000", "24510040100", NA)
    )

    context <- tibble::tibble(
        tract_geoid = c("11001980000", "24510040100"),
        deprivation_index = c(0.8, 0.6)
    )

    result <- join_context(linked, context)

    expect_true(".context_joined" %in% names(result))
    expect_equal(result$.context_joined, c(TRUE, TRUE, FALSE))
})

test_that("join_context() preserves input row order", {
    linked <- tibble::tibble(
        id = 1:3,
        tract_geoid = c("24510040100", "11001980000", "99999999999")
    )

    context <- tibble::tibble(
        tract_geoid = c("11001980000", "24510040100"),
        deprivation_index = c(0.8, 0.6)
    )

    result <- join_context(linked, context)

    expect_equal(result$id, 1:3)
    expect_equal(result$deprivation_index, c(0.6, 0.8, NA))
    expect_equal(result$.context_joined, c(TRUE, TRUE, FALSE))
})

test_that("join_context() requires at least one non-key context column", {
    linked <- tibble::tibble(
        id = 1,
        tract_geoid = "11001980000"
    )

    context <- tibble::tibble(
        tract_geoid = "11001980000"
    )

    expect_error(
        join_context(linked, context),
        "`context` must contain at least one non-key column"
    )
})

test_that("join_context() rejects pre-existing .context_joined column", {
    linked <- tibble::tibble(
        id = 1,
        tract_geoid = "11001980000",
        .context_joined = FALSE
    )

    context <- tibble::tibble(
        tract_geoid = "11001980000",
        deprivation_index = 0.8
    )

    expect_error(
        join_context(linked, context),
        "`\\.data` must not already contain `\\.context_joined`"
    )
})

test_that("join_context() supports different data and context join key names", {
    linked <- tibble::tibble(
        id = 1:3,
        tract_geoid = c("11001980000", "24510040100", "99999999999")
    )

    context <- tibble::tibble(
        GEOID = c("11001980000", "24510040100"),
        deprivation_index = c(0.8, 0.6)
    )

    result <- join_context(
        linked,
        context,
        by = c("tract_geoid" = "GEOID")
    )

    expect_equal(result$id, 1:3)
    expect_equal(result$tract_geoid, linked$tract_geoid)
    expect_false("GEOID" %in% names(result))
    expect_equal(result$deprivation_index, c(0.8, 0.6, NA))
    expect_equal(result$.context_joined, c(TRUE, TRUE, FALSE))
})

test_that("join_context() validates named join key columns", {
    linked <- tibble::tibble(
        id = 1,
        tract_geoid = "11001980000"
    )

    context <- tibble::tibble(
        GEOID = "11001980000",
        deprivation_index = 0.8
    )

    expect_error(
        join_context(linked, context, by = c("missing_key" = "GEOID")),
        "`\\.data` must contain the join key `missing_key`"
    )

    expect_error(
        join_context(linked, context, by = c("tract_geoid" = "missing_key")),
        "`context` must contain the join key `missing_key`"
    )
})

test_that("join_context() rejects empty named join keys", {
    linked <- tibble::tibble(
        id = 1,
        tract_geoid = "11001980000"
    )

    context <- tibble::tibble(
        GEOID = "11001980000",
        deprivation_index = 0.8
    )

    expect_error(
        join_context(
            linked,
            context,
            by = stats::setNames("GEOID", "")
        ),
        "`by` must specify non-empty join key names"
    )

    expect_error(
        join_context(
            linked,
            context,
            by = c("tract_geoid" = "")
        ),
        "`by` must specify non-empty join key names"
    )
})

test_that("join_context() stores context join summary attribute", {
    linked <- tibble::tibble(
        id = 1:3,
        tract_geoid = c("11001980000", "24510040100", "99999999999")
    )

    context <- tibble::tibble(
        tract_geoid = c("11001980000", "24510040100"),
        deprivation_index = c(0.8, 0.6)
    )

    result <- join_context(linked, context)

    summary_attr <- attr(result, "contextlinkr_context_summary", exact = TRUE)

    expect_type(summary_attr, "list")
    expect_equal(summary_attr$joined, 2)
    expect_equal(summary_attr$total, 3)
    expect_equal(summary_attr$join_rate, 2 / 3)
    expect_equal(summary_attr$by, "tract_geoid")
})
