#' Report ContextLinkr context provenance
#'
#' `context_provenance()` reports provenance metadata attached to ContextLinkr
#' context outputs.
#'
#' @param x A ContextLinkr context output, such as a result from [get_context()],
#'   [add_context()], or [link_context()] with `include_context = TRUE`.
#'
#' @return A tibble containing available provenance metadata.
#'
#' @examples
#' \dontrun{
#' context <- get_context(
#'   geographies = "11001006202",
#'   measures = "Total Population",
#'   geography = "tract"
#' )
#'
#' context_provenance(context)
#' }
#'
#' @export
context_provenance <- function(x) {
    provenance <- attr(x, "contextlinkr_context_provenance", exact = TRUE)

    if (is.null(provenance)) {
        return(
            tibble::tibble(
                has_provenance = FALSE
            )
        )
    }

    tibble::as_tibble(provenance)
}
