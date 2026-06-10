skip_if_no_cif_integration <- function() {
    testthat::skip_if_not(
        identical(Sys.getenv("CONTEXTLINKR_RUN_CIF_INTEGRATION"), "true"),
        paste(
            "Set CONTEXTLINKR_RUN_CIF_INTEGRATION=true to run live",
            "Cancer InFocus integration tests."
        )
    )

    testthat::skip_if_offline("cancerinfocus.org")
}
