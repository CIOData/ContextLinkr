test_that("format_context_measure_suggestions() validates inputs", {
    expect_error(
        format_context_measure_suggestions(1),
        "`suggestions` must be a character vector"
    )
})

test_that("format_context_measure_suggestions() formats empty suggestions", {
    result <- format_context_measure_suggestions(character())

    expect_type(result, "character")
    expect_match(result, "available_context_measures")
    expect_match(result, "search_context_measures")
})

test_that("format_context_measure_suggestions() formats non-empty suggestions", {
    result <- format_context_measure_suggestions(
        c("Total Population", "Median Household Income")
    )

    expect_type(result, "character")
    expect_match(result, "Closest matches include")
    expect_match(result, "Total Population")
    expect_match(result, "Median Household Income")
})
