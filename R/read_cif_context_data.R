#' Read Cancer InFocus context data
#'
#' Reads Cancer InFocus county- or tract-level context data from public Parquet
#' files. Tract data are read from state-level partitions inferred from tract
#' GEOIDs.
#'
#' @param geography Geographic level to read. One of `"tract"` or `"county"`.
#' @param geographies Optional character vector of GEOIDs. Required for
#'   `geography = "tract"` so the needed state partitions can be inferred.
#' @param base_url Base URL for ContextLinkr public Parquet files.
#'
#' @return A tibble containing Cancer InFocus context data.
#'
#' @keywords internal
#' @importFrom arrow read_parquet
read_cif_context_data <- function(
        geography = "tract",
        geographies = NULL,
        base_url = "https://cancerinfocus.org/public-data/ContextLinkr"
) {
    validate_context_geography(geography)

    if (geography == "county") {
        url <- cif_context_url(
            geography = "county",
            base_url = base_url
        )

        return(tibble::as_tibble(
            arrow::read_parquet(url)
        ))
    }

    if (is.null(geographies)) {
        rlang::abort("`geographies` is required when reading tract context data.")
    }

    if (!is.character(geographies)) {
        rlang::abort("`geographies` must be a character vector.")
    }

    if (length(geographies) == 0) {
        rlang::abort("`geographies` must contain at least one value.")
    }

    if (anyNA(geographies)) {
        rlang::abort("`geographies` must not contain missing values.")
    }

    if (any(geographies == "")) {
        rlang::abort("`geographies` must not contain empty strings.")
    }

    state_fips <- unique(substr(geographies, 1, 2))

    urls <- vapply(
        state_fips,
        function(.state_fips) {
            cif_context_url(
                geography = "tract",
                state_fips = .state_fips,
                base_url = base_url
            )
        },
        character(1)
    )

    context_data <- lapply(
        urls,
        read_context_parquet
    )

    context_data <- do.call(rbind, context_data)

    tibble::as_tibble(context_data)
}
