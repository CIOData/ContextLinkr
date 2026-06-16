test_that("context_data_sources() reports hosted source metadata", {
    skip_if_no_cif_integration()

    result <- context_data_sources()

    expect_s3_class(result, "tbl_df")
    expect_true("base_url" %in% names(result))
    expect_true("manifest_fields" %in% names(result))
    expect_true("generated_at" %in% names(result))
    expect_true("source" %in% names(result))
    expect_true("files" %in% names(result))
    expect_equal(nrow(result), 1L)
})
