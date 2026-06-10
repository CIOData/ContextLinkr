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
        format = "long"
) {
    validate_context_request(
        geographies = geographies,
        measures = measures,
        geography = geography,
        year = year
    )

    validate_context_format(format)

    context_data <- read_cif_context_data(
        geography = geography,
        geographies = geographies
    )

    context_data <- context_data[context_data$GEOID %in% geographies, , drop = FALSE]

    if (!is.null(measures)) {
        context_data <- context_data[context_data$def %in% measures, , drop = FALSE]
    }

    context_data <- tibble::as_tibble(context_data)

    if (format == "wide") {
        return(widen_context_data(context_data))
    }

    context_data
}
