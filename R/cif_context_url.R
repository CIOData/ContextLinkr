cif_context_url <- function(geography = "tract", release = "Current") {
    if (!is.character(geography) || length(geography) != 1 || is.na(geography)) {
        rlang::abort("`geography` must be a single non-missing character string.")
    }

    if (!geography %in% c("county", "tract")) {
        rlang::abort("`geography` must be one of \"county\" or \"tract\".")
    }

    if (!is.character(release) || length(release) != 1 || is.na(release)) {
        rlang::abort("`release` must be a single non-missing character string.")
    }

    if (release == "") {
        rlang::abort("`release` must not be an empty string.")
    }

    file_name <- paste0("all_", geography, ".fst")

    paste0(
        "https://cancerinfocus.org/public-data/",
        release,
        "/",
        file_name
    )
}
