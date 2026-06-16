test_that("read_context_manifest() validates base_url", {
    expect_error(
        read_context_manifest(NA_character_),
        "`base_url` must be a single non-missing character string"
    )

    expect_error(
        read_context_manifest(c("a", "b")),
        "`base_url` must be a single non-missing character string"
    )

    expect_error(
        read_context_manifest(""),
        "`base_url` must not be an empty string"
    )
})

test_that("read_context_manifest() reads hosted manifest", {
    skip_if_no_cif_integration()

    result <- read_context_manifest()

    expect_type(result, "list")
    expect_true(length(result) > 0)
})
