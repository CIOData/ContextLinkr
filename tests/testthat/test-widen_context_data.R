test_that("widen_context_data() converts long context data to wide format", {
    context_data <- tibble::tibble(
        GEOID = c("01001", "01001", "01003", "01003"),
        County = c("Autauga County", "Autauga County", "Baldwin County", "Baldwin County"),
        State = c("Alabama", "Alabama", "Alabama", "Alabama"),
        def = c("Total Population", "Median Household Income", "Total Population", "Median Household Income"),
        value = c(59947, 66444, 246989, 72409)
    )

    result <- widen_context_data(context_data)

    expect_s3_class(result, "tbl_df")
    expect_equal(nrow(result), 2)
    expect_true("Total Population" %in% names(result))
    expect_true("Median Household Income" %in% names(result))
})

test_that("widen_context_data() requires a data frame", {
    expect_error(
        widen_context_data("not data"),
        "`context_data` must be a data frame"
    )
})

test_that("widen_context_data() requires key columns", {
    expect_error(
        widen_context_data(tibble::tibble(GEOID = "01001")),
        "`context_data` must contain required column"
    )
})
