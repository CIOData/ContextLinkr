test_that("cif_context_url() builds the county context URL", {
    expect_equal(
        cif_context_url("county"),
        "https://cancerinfocus.org/public-data/ContextLinkr/all_county.parquet"
    )
})

test_that("cif_context_url() builds the measures URL", {
    expect_equal(
        cif_context_url("measures"),
        "https://cancerinfocus.org/public-data/ContextLinkr/context_measures.parquet"
    )
})

test_that("cif_context_url() builds tract partition URLs", {
    expect_equal(
        cif_context_url("tract", state_fips = "01"),
        paste0(
            "https://cancerinfocus.org/public-data/ContextLinkr/",
            "all_tract/state_fips=01/part-0.parquet"
        )
    )
})
