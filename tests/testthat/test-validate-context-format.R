test_that("validate_context_format() accepts supported formats", {
    expect_true(validate_context_format("long"))
    expect_true(validate_context_format("wide"))
})

test_that("validate_context_format() rejects invalid formats", {
    expect_error(
        validate_context_format(c("long", "wide")),
        "`format` must be a single non-missing character string"
    )

    expect_error(
        validate_context_format(NA_character_),
        "`format` must be a single non-missing character string"
    )

    expect_error(
        validate_context_format("tidy"),
        "`format` must be one of"
    )
})
