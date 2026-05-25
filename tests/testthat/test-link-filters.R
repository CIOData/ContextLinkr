test_that("link_successes() requires a data frame", {
    expect_error(
        link_successes("not a data frame"),
        "`\\.data` must be a data frame"
    )
})

test_that("link_failures() requires a data frame", {
    expect_error(
        link_failures("not a data frame"),
        "`\\.data` must be a data frame"
    )
})

test_that("link_successes() requires .tract_identified", {
    expect_error(
        link_successes(tibble::tibble(id = 1)),
        "must contain a `.tract_identified` column"
    )
})

test_that("link_failures() requires .tract_identified", {
    expect_error(
        link_failures(tibble::tibble(id = 1)),
        "must contain a `.tract_identified` column"
    )
})

test_that("link_successes() returns tract-identified rows", {
    linked <- tibble::tibble(
        id = 1:4,
        .tract_identified = c(TRUE, FALSE, TRUE, NA)
    )

    result <- link_successes(linked)

    expect_s3_class(result, "tbl_df")
    expect_equal(nrow(result), 2)
    expect_equal(result$id, c(1, 3))
    expect_true(all(result$.tract_identified))
})

test_that("link_failures() returns rows not tract-identified", {
    linked <- tibble::tibble(
        id = 1:4,
        .tract_identified = c(TRUE, FALSE, TRUE, NA)
    )

    result <- link_failures(linked)

    expect_s3_class(result, "tbl_df")
    expect_equal(nrow(result), 2)
    expect_equal(result$id, c(2, 4))
})

test_that("link filters preserve additional columns", {
    linked <- tibble::tibble(
        id = 1:3,
        tract_geoid = c("11001980000", NA, "24510040100"),
        .geocoded = c(TRUE, TRUE, TRUE),
        .tract_identified = c(TRUE, FALSE, TRUE)
    )

    successes <- link_successes(linked)
    failures <- link_failures(linked)

    expect_true("tract_geoid" %in% names(successes))
    expect_true(".geocoded" %in% names(successes))
    expect_true("tract_geoid" %in% names(failures))
    expect_true(".geocoded" %in% names(failures))
})
