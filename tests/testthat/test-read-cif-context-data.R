test_that("read_cif_context_data() can read tract context data", {
    skip_on_cran()
    skip_if_offline("cancerinfocus.org")

    result <- ContextLinkr:::read_cif_context_data("tract")

    expect_s3_class(result, "tbl_df")
    expect_true(nrow(result) > 0)
})

test_that("read_cif_context_data() can read county context data", {
    skip_on_cran()
    skip_if_offline("cancerinfocus.org")

    result <- ContextLinkr:::read_cif_context_data("county")

    expect_s3_class(result, "tbl_df")
    expect_true(nrow(result) > 0)
})
