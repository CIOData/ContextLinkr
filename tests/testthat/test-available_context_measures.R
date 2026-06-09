test_that("available_context_measures() returns expected columns", {
    result <- available_context_measures()

    expect_s3_class(result, "tbl_df")
    expect_named(
        result,
        c("measure", "label", "geography", "status")
    )
})

test_that("available_context_measures() returns character columns", {
    result <- available_context_measures()

    expect_type(result$measure, "character")
    expect_type(result$label, "character")
    expect_type(result$geography, "character")
    expect_type(result$status, "character")
})

test_that("available_context_measures() includes planned tract measures", {
    result <- available_context_measures()

    expect_true("poverty" %in% result$measure)
    expect_true("rurality" %in% result$measure)
    expect_true(all(result$geography %in% c("tract", "county")))
    expect_true(all(result$status %in% c("planned", "implemented")))
})
