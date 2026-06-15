#' Search available Cancer InFocus contextual measures
#'
#' `search_context_measures()` searches Cancer InFocus contextual measure
#' metadata by keyword and returns matching measures that can be used with
#' [get_context()], [add_context()], or [link_context()].
#'
#' @param query Character string to search for in measure metadata.
#' @param geography Optional geographic level to filter to. One of `"county"` or
#'   `"tract"`. If `NULL`, measures for all geographies are searched.
#' @param ignore_case Logical. If `TRUE`, search is case-insensitive.
#' @param use_cache Logical. If `TRUE`, hosted Cancer InFocus context files are
#'   cached locally before reading.
#'
#' @return A tibble containing matching contextual measure metadata.
#'
#' @examples
#' \dontrun{
#' search_context_measures("population", geography = "tract")
#' search_context_measures("poverty")
#' }
#'
#' @seealso [available_context_measures()], [get_context()]
#'
#' @export
search_context_measures <- function(
        query,
        geography = NULL,
        ignore_case = TRUE,
        use_cache = TRUE
) {
    if (missing(query)) {
        rlang::abort("`query` is required.")
    }

    if (!is.character(query) || length(query) != 1 || is.na(query)) {
        rlang::abort("`query` must be a single non-missing character string.")
    }

    if (query == "") {
        rlang::abort("`query` must not be an empty string.")
    }

    if (!is.logical(ignore_case) || length(ignore_case) != 1 || is.na(ignore_case)) {
        rlang::abort("`ignore_case` must be a single non-missing logical value.")
    }

    if (!is.logical(use_cache) || length(use_cache) != 1 || is.na(use_cache)) {
        rlang::abort("`use_cache` must be a single non-missing logical value.")
    }

    measures <- available_context_measures(
        geography = geography,
        use_cache = use_cache
    )

    search_cols <- intersect(
        c("cat", "measure", "def", "source"),
        names(measures)
    )

    haystack <- apply(
        measures[, search_cols, drop = FALSE],
        1,
        paste,
        collapse = " "
    )

    if (ignore_case) {
        query <- tolower(query)
        haystack <- tolower(haystack)
    }

    matches <- grepl(
        query,
        haystack,
        fixed = TRUE
    )

    measures[matches, , drop = FALSE]
}
