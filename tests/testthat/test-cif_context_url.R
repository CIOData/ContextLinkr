test_that("cif_context_url() builds the tract context URL by default", {
    expect_equal(
        cif_context_url(),
        "https://cancerinfocus.org/public-data/Current/all_tract.fst"
    )
})

test_that("cif_context_url() builds the county context URL", {
    expect_equal(
        cif_context_url("county"),
        "https://cancerinfocus.org/public-data/Current/all_county.fst"
    )
})

test_that("cif_context_url() supports custom releases", {
    expect_equal(
        cif_context_url("tract", release = "Archive"),
        "https://cancerinfocus.org/public-data/Archive/all_tract.fst"
    )
})

test_that("cif_context_url() validates geography", {
    expect_error(
        cif_context_url(geography = c("tract", "county")),
        "`geography` must be a single non-missing character string"
    )

    expect_error(
        cif_context_url(geography = NA_character_),
        "`geography` must be a single non-missing character string"
    )

    expect_error(
        cif_context_url(geography = "state"),
        "`geography` must be one of"
    )
})

test_that("cif_context_url() validates release", {
    expect_error(
        cif_context_url(release = c("Current", "Archive")),
        "`release` must be a single non-missing character string"
    )

    expect_error(
        cif_context_url(release = NA_character_),
        "`release` must be a single non-missing character string"
    )

    expect_error(
        cif_context_url(release = ""),
        "`release` must not be an empty string"
    )
})
