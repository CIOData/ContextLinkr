#' Summarize contextual data join results
#'
#' `context_summary()` returns a one-row summary of contextual data join
#' performance. For results from [join_context()], it summarizes the
#' `.context_joined` metadata column.
#'
#' @param .data A data frame returned by [join_context()] or another
#'   ContextLinkr workflow containing `.context_joined`.
#'
#' @return A one-row tibble with the number and percentage of rows successfully
#'   joined to contextual data.
#'
#' @examples
#' joined <- tibble::tibble(
#'   id = 1:3,
#'   .context_joined = c(TRUE, FALSE, TRUE)
#' )
#'
#' context_summary(joined)
#'
#' @seealso [join_context()], [link_summary()], [missing_context_keys()],
#'   [context_successes()], [context_failures()]
#'
#' @export
context_summary <- function(.data) {
    if (!is.data.frame(.data)) {
        rlang::abort("`.data` must be a data frame.")
    }

    if (!".context_joined" %in% names(.data)) {
        rlang::abort("`.data` must contain a `.context_joined` column.")
    }

    total <- nrow(.data)
    joined <- sum(.data[[".context_joined"]], na.rm = TRUE)

    join_rate <- if (total > 0) {
        joined / total
    } else {
        NA_real_
    }

    tibble::tibble(
        joined = joined,
        total = total,
        join_rate = join_rate,
        join_rate_pct = round(join_rate * 100, 1)
    )
}
