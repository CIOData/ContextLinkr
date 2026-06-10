#' List available Cancer InFocus contextual measures
#'
#' `available_context_measures()` returns a table of contextual measures
#' available from Cancer InFocus data.
#'
#' The returned `def` column contains the measure definitions that can be passed
#' to the `measures` argument of [get_context()].
#'
#' @param geography Optional geographic level to filter to. One of `"county"` or
#'   `"tract"`. If `NULL`, measures for all geographies are returned.
#' @param base_url Base URL for ContextLinkr public Parquet files.
#'
#' @return A tibble containing available contextual measure metadata.
#'
#' @examples
#' \dontrun{
#' available_context_measures()
#' available_context_measures("tract")
#' }
#'
#' @seealso [get_context()]
#'
#' @export
available_context_measures <- function(
        geography = NULL,
        base_url = "https://cancerinfocus.org/public-data/ContextLinkr"
) {
    if (!is.null(geography)) {
        validate_context_geography(geography)
    }

    url <- cif_context_url(
        geography = "measures",
        base_url = base_url
    )

    measures <- tibble::as_tibble(
        arrow::read_parquet(url)
    )

    if (!is.null(geography) && "geography" %in% names(measures)) {
        measures <- measures[measures$geography == geography, , drop = FALSE]
    }

    measures
}
