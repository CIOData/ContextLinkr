test_that("validate_context_request() accepts valid tract requests", {
    skip_if_no_cif_integration()
    expect_true(
        validate_context_request(
            geographies = c("11001980000", "24510040100"),
            measures = "Total Population",
            geography = "tract"
        )
    )
})

test_that("validate_context_request() accepts NULL measures", {
    skip_if_no_cif_integration()
    expect_true(
        validate_context_request(
            geographies = c("11001980000", "24510040100"),
            measures = NULL,
            geography = "tract"
        )
    )
})

test_that("validate_context_request() accepts county requests", {
    skip_if_no_cif_integration()
    expect_true(
        validate_context_request(
            geographies = c("11001", "24510"),
            measures = "Total Population",
            geography = "county"
        )
    )
})

test_that("validate_context_request() rejects unsupported measures", {
    skip_if_no_cif_integration()
    expect_error(
        validate_context_request(
            geographies = "11001980000",
            measures = "not_a_measure",
            geography = "tract"
        ),
        "`measures` contains unsupported value"
    )
})
