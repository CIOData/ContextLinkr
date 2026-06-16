#' Attach ContextLinkr context provenance
#'
#' Attaches standardized ContextLinkr context provenance metadata to a data
#' frame.
#'
#' @param x A data frame.
#' @param geography Geographic level used for context retrieval.
#' @param base_url Base URL for ContextLinkr public data files.
#' @param use_cache Logical. Whether cache use was enabled.
#' @param refresh_cache Logical. Whether cache refresh was requested.
#' @param format Output format requested.
#'
#' @return `x` with a `contextlinkr_context_provenance` attribute.
#'
#' @keywords internal
add_context_provenance <- function(
        x,
        geography,
        base_url,
        use_cache,
        refresh_cache,
        format
) {
    if (!is.data.frame(x)) {
        rlang::abort("`x` must be a data frame.")
    }

    provenance <- tibble::tibble(
        geography = geography,
        base_url = base_url,
        use_cache = use_cache,
        refresh_cache = refresh_cache,
        format = format,
        retrieved_at = Sys.time()
    )

    attr(x, "contextlinkr_context_provenance") <- provenance

    x
}
