#' Summarize geocoding results
#'
#' Returns a compact summary of geocoding results created by [gc_address()].
#'
#' @param x A data frame returned by [gc_address()].
#'
#' @return A tibble with geocoding summary information.
#'
#' @examples
#' x <- sample_addresses
#' attr(x, "contextlinkr_geocode_summary") <- list(
#'   matched = 5,
#'   total = 5,
#'   match_rate = 1,
#'   geocoder = "osm"
#' )
#'
#' geocode_summary(x)
#'
#' @export
geocode_summary <- function(x) {
    summary <- attr(x, "contextlinkr_geocode_summary", exact = TRUE)

    if (is.null(summary)) {
        stop(
            "`x` does not contain ContextLinkr geocoding summary metadata.",
            call. = FALSE
        )
    }

    tibble::tibble(
        matched = summary$matched,
        total = summary$total,
        match_rate = summary$match_rate,
        match_rate_pct = round(summary$match_rate * 100, 1),
        geocoder = paste(summary$geocoder, collapse = ", ")
    )
}
