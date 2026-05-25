#' Summarize Census tract identification results
#'
#' Returns a compact summary of tract identification results created by
#' [id_tract()].
#'
#' @param x A data frame returned by [id_tract()].
#'
#' @return A tibble with tract identification summary information.
#'
#' @examples
#' x <- tibble::tibble(
#'   id = 1:3,
#'   tract_geoid = c("11001980000", NA_character_, "11001006202"),
#'   .tract_identified = c(TRUE, FALSE, TRUE),
#'   .tract_state_fips = c("11", "11", "11"),
#'   .tract_year = c(2020, 2020, 2020)
#' )
#'
#' tract_summary(x)
#'
#' @export
tract_summary <- function(x) {
    check_tract_result(x)

    total <- nrow(x)
    identified <- sum(x$.tract_identified, na.rm = TRUE)
    identification_rate <- if (total > 0) identified / total else NA_real_

    tibble::tibble(
        identified = identified,
        total = total,
        identification_rate = identification_rate,
        identification_rate_pct = round(identification_rate * 100, 1),
        state_fips = paste(unique(stats::na.omit(x$.tract_state_fips)), collapse = ", "),
        year = paste(unique(x$.tract_year), collapse = ", ")
    )
}
