cif_context_url <- function(
        geography = "tract",
        state_fips = NULL,
        base_url = "https://cancerinfocus.org/public-data/ContextLinkr"
) {
    if (!is.character(geography) || length(geography) != 1 || is.na(geography)) {
        rlang::abort("`geography` must be a single non-missing character string.")
    }

    if (!geography %in% c("county", "tract", "measures")) {
        rlang::abort("`geography` must be one of \"county\", \"tract\", or \"measures\".")
    }

    if (!is.character(base_url) || length(base_url) != 1 || is.na(base_url)) {
        rlang::abort("`base_url` must be a single non-missing character string.")
    }

    if (base_url == "") {
        rlang::abort("`base_url` must not be an empty string.")
    }

    base_url <- sub("/+$", "", base_url)

    if (geography == "county") {
        return(paste0(base_url, "/all_county.parquet"))
    }

    if (geography == "measures") {
        return(paste0(base_url, "/context_measures.parquet"))
    }

    if (is.null(state_fips)) {
        rlang::abort("`state_fips` is required when `geography = \"tract\"`.")
    }

    if (!is.character(state_fips) || length(state_fips) != 1 || is.na(state_fips)) {
        rlang::abort("`state_fips` must be a single non-missing character string.")
    }

    if (!grepl("^[0-9]{2}$", state_fips)) {
        rlang::abort("`state_fips` must be a two-digit state FIPS code.")
    }

    paste0(
        base_url,
        "/all_tract/state_fips=",
        state_fips,
        "/part-0.parquet"
    )
}
