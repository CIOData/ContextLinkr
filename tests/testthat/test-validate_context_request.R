test_that("validate_context_request() accepts valid tract requests", {
    expect_true(
        validate_context_request(
            geographies = c("11001980000", "24510040100"),
            measures = c("poverty", "rurality"),
            geography = "tract"
        )
    )
})

test_that("validate_context_request() accepts NULL measures", {
    expect_true(
        validate_context_request(
            geographies = c("11001980000", "24510040100"),
            measures = NULL,
            geography = "tract"
        )
    )
})

test_that("validate_context_request() accepts county requests", {
    expect_true(
        validate_context_request(
            geographies = c("11001", "24510"),
            measures = "poverty",
            geography = "county"
        )
    )
})

test_that("validate_context_request() requires geographies", {
    expect_error(
        validate_context_request(),
        "`geographies` is required"
    )
})

test_that("validate_context_request() validates geographies", {
    expect_error(
        validate_context_request(geographies = 11001980000),
        "`geographies` must be a character vector"
    )

    expect_error(
        validate_context_request(geographies = character()),
        "`geographies` must contain at least one value"
    )

    expect_error(
        validate_context_request(geographies = c("11001980000", NA_character_)),
        "`geographies` must not contain missing values"
    )

    expect_error(
        validate_context_request(geographies = c("11001980000", "")),
        "`geographies` must not contain empty strings"
    )
})

test_that("validate_context_request() validates measures", {
    expect_error(
        validate_context_request(
            geographies = "11001980000",
            measures = 1
        ),
        "`measures` must be `NULL` or a character vector"
    )

    expect_error(
        validate_context_request(
            geographies = "11001980000",
            measures = character()
        ),
        "`measures` must be `NULL` or contain at least one value"
    )

    expect_error(
        validate_context_request(
            geographies = "11001980000",
            measures = c("poverty", NA_character_)
        ),
        "`measures` must not contain missing values"
    )

    expect_error(
        validate_context_request(
            geographies = "11001980000",
            measures = c("poverty", "")
        ),
        "`measures` must not contain empty strings"
    )
})

test_that("validate_context_request() validates geography", {
    expect_error(
        validate_context_request(
            geographies = "11001980000",
            geography = c("tract", "county")
        ),
        "`geography` must be a single non-missing character string"
    )

    expect_error(
        validate_context_request(
            geographies = "11001980000",
            geography = NA_character_
        ),
        "`geography` must be a single non-missing character string"
    )

    expect_error(
        validate_context_request(
            geographies = "11001980000",
            geography = "state"
        ),
        "`geography` must be one of"
    )
})

test_that("validate_context_request() validates year", {
    expect_error(
        validate_context_request(
            geographies = "11001980000",
            year = "not a year"
        )
    )
})

test_that("validate_context_request() rejects unsupported measures", {
    expect_error(
        validate_context_request(
            geographies = "11001980000",
            measures = "not_a_measure",
            geography = "tract"
        ),
        "`measures` contains unsupported value"
    )
})
