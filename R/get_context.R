#' Retrieve Cancer InFocus contextual data
#'
#' `get_context()` will retrieve contextual variable values from Cancer InFocus
#' data for specified geographic identifiers.
#'
#' This function is planned but not yet implemented. Future versions will use
#' Cancer InFocus data as the primary source of contextual variables for
#' individual-level linkage workflows.
#'
#' @param geographies A character vector of geographic identifiers, such as
#'   Census tract GEOIDs.
#' @param measures Optional character vector of contextual measures to retrieve.
#'   If `NULL`, a default set of measures may be returned in future versions.
#' @param geography Geographic level. Currently planned values include
#'   `"tract"` and `"county"`.
#' @param year Optional year or data vintage.
#' @param format Output format. Use `"long"` to return Cancer InFocus rows as
#'   stored in the source data, or `"wide"` to return one row per geography with
#'   one column per contextual measure definition.
#' @param use_cache Logical. If `TRUE`, hosted Cancer InFocus context files are
#'   cached locally before reading.
#' @param refresh_cache Logical. If `TRUE`, hosted files are downloaded again
#'   even when cached copies exist. Ignored when `use_cache = FALSE`.
#'
#' @return Currently aborts with an informative message because Cancer InFocus
#'   retrieval is not yet implemented.
#'
#' @examples
#' \dontrun{
#' get_context(
#'   geographies = c("11001980000", "24510040100"),
#'   measures = c("poverty", "rurality"),
#'   geography = "tract"
#' )
#' }
#'
#' @export
get_context <- function(
        geographies,
        measures = NULL,
        geography = "tract",
        year = NULL,
        format = "long",
        use_cache = TRUE,
        refresh_cache = FALSE
) {
    validate_context_request(
        geographies = geographies,
        measures = measures,
        geography = geography,
        year = year,
        use_cache = use_cache,
        refresh_cache = refresh_cache
    )

    validate_context_format(format)

    validate_context_state(
        geographies = geographies,
        geography = geography
    )

    if (!is.logical(use_cache) || length(use_cache) != 1 || is.na(use_cache)) {
        rlang::abort("`use_cache` must be a single non-missing logical value.")
    }

    if (!is.logical(refresh_cache) || length(refresh_cache) != 1 || is.na(refresh_cache)) {
        rlang::abort("`refresh_cache` must be a single non-missing logical value.")
    }

    context_data <- read_cif_context_data(
        geography = geography,
        geographies = geographies,
        use_cache = use_cache,
        refresh_cache = refresh_cache
    )

    context_data <- context_data[context_data$GEOID %in% geographies, , drop = FALSE]

    if (!is.null(measures)) {
        context_data <- context_data[context_data$def %in% measures, , drop = FALSE]
    }

    context_data <- tibble::as_tibble(context_data)

    if (format == "wide") {
        context_data <- widen_context_data(context_data)
    }

    add_context_provenance(
        context_data,
        geography = geography,
        base_url = "https://cancerinfocus.org/public-data/ContextLinkr",
        use_cache = use_cache,
        refresh_cache = refresh_cache,
        format = format
    )
}
