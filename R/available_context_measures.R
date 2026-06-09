#' List available Cancer InFocus contextual measures
#'
#' `available_context_measures()` returns a table of contextual measures that
#' ContextLinkr can retrieve or expects to retrieve from Cancer InFocus data.
#'
#' This function is an early metadata scaffold. The initial measure list is
#' intentionally small and will expand as Cancer InFocus retrieval is
#' implemented.
#'
#' @return A tibble with one row per contextual measure and columns:
#'   `measure`, `label`, `geography`, and `status`.
#'
#' @examples
#' available_context_measures()
#'
#' @seealso [get_context()]
#'
#' @export
available_context_measures <- function() {
    tibble::tibble(
        measure = c(
            "poverty",
            "rurality"
        ),
        label = c(
            "Poverty",
            "Rurality"
        ),
        geography = c(
            "tract",
            "tract"
        ),
        status = c(
            "planned",
            "planned"
        )
    )
}
