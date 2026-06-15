test_that("closest_context_measures() validates inputs", {
    available <- tibble::tibble(def = c("Total Population", "Median Income"))

    expect_error(
        closest_context_measures(NA_character_, available),
        "`measure` must be a single non-missing character string"
    )

    expect_error(
        closest_context_measures("", available),
        "`measure` must not be an empty string"
    )

    expect_error(
        closest_context_measures("Population", "not data"),
        "`available_measures` must be a data frame"
    )

    expect_error(
        closest_context_measures("Population", tibble::tibble(measure = "x")),
        "`available_measures` must contain a `def` column"
    )

    expect_error(
        closest_context_measures("Population", available, n = 0),
        "`n` must be a single number greater than or equal to 1"
    )
})

test_that("closest_context_measures() returns closest definitions", {
    available <- tibble::tibble(
        def = c(
            "Total Population",
            "Median Household Income",
            "Adults Age 65 and Older"
        )
    )

    result <- closest_context_measures(
        "Population",
        available,
        n = 2
    )

    expect_type(result, "character")
    expect_length(result, 2)
    expect_true("Total Population" %in% result)
})
